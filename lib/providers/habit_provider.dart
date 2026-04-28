import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/quest.dart';
import '../services/storage_service.dart';
import 'quest_provider.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final QuestProvider _questProvider;

  List<Habit> _habits = [];
  bool _isLoading = true;

  HabitProvider(this._questProvider);

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;

  List<Habit> get activeHabits => _habits
      .where((h) => h.status == HabitStatus.active && !h.isExpired && h.isDueToday)
      .toList();

  List<Habit> get allHabits => _habits
      .where((h) => h.status == HabitStatus.active)
      .toList();

  List<Habit> get archivedHabits => _habits
      .where((h) => h.status == HabitStatus.archived || h.isExpired)
      .toList();

  List<Habit> get completedToday =>
      activeHabits.where((h) => h.isCompletedToday).toList();

  List<Habit> get pendingToday =>
      activeHabits.where((h) => !h.isCompletedToday).toList();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _storage.init();
    _habits = await _storage.loadHabits();
    if (_habits.isEmpty) _habits = _defaultHabits();

    // Check for missed days and spawn penalties
    await _checkMissedDaysAndSpawnPenalties();

    _isLoading = false;
    notifyListeners();
  }

  // ── Missed day detection ───────────────────────────────────
  Future<void> _checkMissedDaysAndSpawnPenalties() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool changed = false;

    for (int i = 0; i < _habits.length; i++) {
      final h = _habits[i];

      // Only check active habits with penalty enabled
      if (h.status != HabitStatus.active || !h.hasPenalty || h.isExpired) continue;

      // Was it due yesterday?
      final yesterday = today.subtract(const Duration(days: 1));
      if (!h.repeatConfig.isDueToday(yesterday)) continue;

      // Was it completed yesterday?
      if (h.lastCompletedDate == null) {
        // Never completed — if created before today, it was missed yesterday
        final createdDay = DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day);
        if (createdDay.isBefore(today)) {
          _spawnHabitPenalty(h);
          _habits[i] = h.copyWith(totalMissedDays: h.totalMissedDays + 1);
          changed = true;
        }
        continue;
      }

      final lastDay = DateTime(
        h.lastCompletedDate!.year,
        h.lastCompletedDate!.month,
        h.lastCompletedDate!.day,
      );

      // If last completed was NOT yesterday (or today), it was missed
      if (lastDay != yesterday && lastDay != today) {
        _spawnHabitPenalty(h);
        _habits[i] = h.copyWith(totalMissedDays: h.totalMissedDays + 1);
        changed = true;
      }
    }

    if (changed) {
      await _storage.saveHabits(_habits);
      await _questProvider.persistHunter();
    }
  }

  void _spawnHabitPenalty(Habit habit) {
    final penaltyDesc = habit.penaltyDescription?.trim().isNotEmpty == true
        ? habit.penaltyDescription!.trim()
        : 'Make up for missed "${habit.title}"';

    // Deduct XP immediately if configured
    if (habit.penaltyXpDeduction != null && habit.penaltyXpDeduction! > 0) {
      final hunter = _questProvider.hunter;
      hunter.currentXp =
          (hunter.currentXp - habit.penaltyXpDeduction!).clamp(0, 999999999);
    }

    // Spawn penalty quest — identical structure to quest penalties
    final penaltyQuest = Quest(
      title: '⚠ PENALTY: $penaltyDesc',
      description:
          'You missed "${habit.title}" yesterday. The system demands compensation. '
          'Complete this penalty within 24 hours to avoid further consequences.',
      xpReward: (habit.xpReward * 0.25).ceil(),
      deadline: DateTime.now().add(const Duration(hours: 24)),
      rarity: QuestRarity.common,
      status: QuestStatus.penalty,
      tags: ['PENALTY', 'HABIT'],
      hasPenalty: false,
    );

    _questProvider.addQuest(penaltyQuest);
  }

  // ── CRUD ───────────────────────────────────────────────────
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> updateHabit(Habit updated) async {
    final idx = _habits.indexWhere((h) => h.id == updated.id);
    if (idx != -1) {
      _habits[idx] = updated;
      await _storage.saveHabits(_habits);
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> archiveHabit(String id) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx != -1) {
      _habits[idx] = _habits[idx].copyWith(status: HabitStatus.archived);
      await _storage.saveHabits(_habits);
      notifyListeners();
    }
  }

  // ── Complete habit for today ───────────────────────────────
  Future<LevelUpResult> completeHabit(String id) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) {
      return LevelUpResult(didLevelUp: false, newLevel: _questProvider.hunter.level);
    }

    final habit = _habits[idx];
    if (habit.isCompletedToday) {
      return LevelUpResult(didLevelUp: false, newLevel: _questProvider.hunter.level);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Streak logic
    int newStreak = habit.currentStreak;
    final yesterday = today.subtract(const Duration(days: 1));
    if (habit.lastCompletedDate != null) {
      final lastDay = DateTime(
        habit.lastCompletedDate!.year,
        habit.lastCompletedDate!.month,
        habit.lastCompletedDate!.day,
      );
      if (lastDay == yesterday) {
        newStreak++;
      } else if (lastDay != today) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final newLongest =
        newStreak > habit.longestStreak ? newStreak : habit.longestStreak;

    _habits[idx] = habit.copyWith(
      lastCompletedDate: now,
      currentStreak: newStreak,
      longestStreak: newLongest,
      totalCompletions: habit.totalCompletions + 1,
      completionHistory: [...habit.completionHistory, today],
    );

    _questProvider.hunter.addXp(habit.xpReward);

    bool didLevelUp = false;
    int newLevel = _questProvider.hunter.level;
    while (_questProvider.hunter.canLevelUp()) {
      _questProvider.hunter.levelUp();
      didLevelUp = true;
      newLevel = _questProvider.hunter.level;
    }

    await _storage.saveHabits(_habits);
    await _questProvider.persistHunter();
    notifyListeners();

    return LevelUpResult(didLevelUp: didLevelUp, newLevel: newLevel);
  }

  // ── Defaults ───────────────────────────────────────────────
  List<Habit> _defaultHabits() => [
        Habit(
          title: '💧 Drink 2L Water',
          description:
              'Stay hydrated. The body is the temple. The system demands you maintain it.',
          xpReward: 50,
          rarity: QuestRarity.common,
          tags: ['HEALTH'],
          repeatConfig: const RepeatConfig(frequency: RepeatFrequency.daily),
          hasPenalty: false,
        ),
        Habit(
          title: '🧘 10min Meditation',
          description:
              'Clear your mind. Mental fortitude is the foundation of all strength.',
          xpReward: 80,
          rarity: QuestRarity.rare,
          tags: ['MENTAL', 'HEALTH'],
          repeatConfig: const RepeatConfig(
            frequency: RepeatFrequency.weekly,
            weekdays: [1, 2, 3, 4, 5],
          ),
          hasPenalty: false,
        ),
      ];
}

import 'package:flutter/foundation.dart';
import '../models/quest.dart';
import '../models/hunter.dart';
import '../services/storage_service.dart';

class QuestProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Quest> _quests = [];
  Hunter _hunter = Hunter(name: 'Hunter');
  bool _isLoading = true;

  List<Quest> get quests => List.unmodifiable(_quests);
  Hunter get hunter => _hunter;
  bool get isLoading => _isLoading;

  // Filtered views
  List<Quest> get activeQuests => _quests
      .where((q) => q.status == QuestStatus.active && (q.unlockLevel == null || q.unlockLevel! <= _hunter.level))
      .toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));

  List<Quest> get penaltyQuests => _quests
      .where((q) => q.status == QuestStatus.penalty)
      .toList();

  List<Quest> get completedQuests => _quests
      .where((q) => q.status == QuestStatus.completed)
      .toList()
    ..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));

  List<Quest> get failedQuests => _quests
      .where((q) => q.status == QuestStatus.failed)
      .toList();

  List<Quest> get lockedQuests => _quests
      .where((q) => q.unlockLevel != null && q.unlockLevel! > _hunter.level)
      .toList();

  List<Quest> get allQuestsForManagement => List.unmodifiable(_quests);

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _storage.init();
    _hunter = await _storage.loadHunter() ?? Hunter(name: 'Hunter');
    _quests = await _storage.loadQuests();

    if (_quests.isEmpty) {
      _quests = _defaultQuests();
    }

    _checkOverdueQuests();
    _isLoading = false;
    notifyListeners();
  }

  void _checkOverdueQuests() {
    bool changed = false;
    for (int i = 0; i < _quests.length; i++) {
      final q = _quests[i];
      if (q.status == QuestStatus.active && q.deadline.isBefore(DateTime.now())) {
        _quests[i] = q.copyWith(status: QuestStatus.failed);
        if (q.hasPenalty) {
          _spawnPenaltyQuest(q);
        }
        changed = true;
      }
    }
    if (changed) _persist();
  }

  // ── Quest CRUD ─────────────────────────────────────────────
  Future<void> addQuest(Quest quest) async {
    _quests.add(quest);
    await _persist();
    notifyListeners();
  }

  Future<void> updateQuest(Quest updated) async {
    final idx = _quests.indexWhere((q) => q.id == updated.id);
    if (idx != -1) {
      _quests[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteQuest(String id) async {
    _quests.removeWhere((q) => q.id == id);
    await _persist();
    notifyListeners();
  }

  // ── Complete Quest ─────────────────────────────────────────
  Future<LevelUpResult> completeQuest(String id) async {
    final idx = _quests.indexWhere((q) => q.id == id);
    if (idx == -1) return LevelUpResult(didLevelUp: false, newLevel: _hunter.level);

    final quest = _quests[idx];
    _quests[idx] = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
    );

    _hunter.totalQuestsCompleted++;
    _hunter.addXp(quest.xpReward);

    bool didLevelUp = false;
    int newLevel = _hunter.level;

    while (_hunter.canLevelUp()) {
      _hunter.levelUp();
      didLevelUp = true;
      newLevel = _hunter.level;
    }

    _checkAndGrantAchievements();
    await _persist();
    notifyListeners();

    return LevelUpResult(didLevelUp: didLevelUp, newLevel: newLevel);
  }

  // ── Fail Quest ─────────────────────────────────────────────
  Future<void> failQuest(String id) async {
    final idx = _quests.indexWhere((q) => q.id == id);
    if (idx == -1) return;

    final quest = _quests[idx];
    _quests[idx] = quest.copyWith(status: QuestStatus.failed);
    _hunter.totalPenaltiesFaced++;

    if (quest.hasPenalty) {
      _spawnPenaltyQuest(quest);
    }

    // XP penalty
    if (quest.penaltyXp != null) {
      final deduction = quest.penaltyXp!;
      _hunter.currentXp = (_hunter.currentXp - deduction).clamp(0, double.maxFinite.toInt());
    }

    await _persist();
    notifyListeners();
  }

  void _spawnPenaltyQuest(Quest failedQuest) {
    if (failedQuest.penaltyDescription == null) return;
    final penaltyQuest = Quest(
      title: '⚠ PENALTY: ${failedQuest.penaltyDescription}',
      description: 'You failed "${failedQuest.title}". The system demands compensation. Complete this to avoid further XP loss.',
      xpReward: (failedQuest.xpReward * 0.25).toInt(),
      deadline: DateTime.now().add(const Duration(hours: 24)),
      rarity: QuestRarity.common,
      status: QuestStatus.penalty,
      tags: ['PENALTY'],
      hasPenalty: false,
    );
    _quests.add(penaltyQuest);
  }

  // ── Hunter Profile ─────────────────────────────────────────
  Future<void> updateHunterName(String name) async {
    _hunter.name = name;
    await _persist();
    notifyListeners();
  }

  Future<void> updateHunterTitle(String? title) async {
    _hunter.title = title;
    await _persist();
    notifyListeners();
  }

  Future<void> updateProfileImage(String? path) async {
    _hunter.profileImagePath = path;
    await _persist();
    notifyListeners();
  }

  // ── Achievements ───────────────────────────────────────────
  void _checkAndGrantAchievements() {
    final existingIds = _hunter.achievements.map((a) => a.id).toSet();

    final checks = [
      _AchievementCheck('first_quest', 'First Blood', 'Complete your first quest', '⚔',
          _hunter.totalQuestsCompleted >= 1, 50),
      _AchievementCheck('ten_quests', 'Seasoned Hunter', 'Complete 10 quests', '🗡',
          _hunter.totalQuestsCompleted >= 10, 200),
      _AchievementCheck('fifty_quests', 'Veteran Hunter', 'Complete 50 quests', '💀',
          _hunter.totalQuestsCompleted >= 50, 500),
      _AchievementCheck('level_10', 'Awakened', 'Reach Level 10', '✨',
          _hunter.level >= 10, 300),
      _AchievementCheck('level_25', 'D-Rank Promoted', 'Reach Level 25', '🔵',
          _hunter.level >= 25, 500),
      _AchievementCheck('level_50', 'C-Rank Promoted', 'Reach Level 50', '💚',
          _hunter.level >= 50, 1000),
      _AchievementCheck('streak_7', '7-Day Streak', 'Maintain a 7-day streak', '🔥',
          _hunter.streakDays >= 7, 350),
    ];

    for (final check in checks) {
      if (check.condition && !existingIds.contains(check.id)) {
        _hunter.achievements.add(Achievement(
          id: check.id,
          title: check.title,
          description: check.desc,
          icon: check.icon,
          unlockedAt: DateTime.now(),
          xpBonus: check.xpBonus,
        ));
        _hunter.addXp(check.xpBonus);
      }
    }
  }

  // ── Persist ────────────────────────────────────────────────
  Future<void> _persist() async {
    await _storage.saveHunter(_hunter);
    await _storage.saveQuests(_quests);
  }

  // ── Default Quest Seeds ────────────────────────────────────
  List<Quest> _defaultQuests() {
    final now = DateTime.now();
    return [
      Quest(
        title: '⚔ Deep Work Session',
        description: 'Complete 4 hours of focused deep work. No distractions allowed. The system watches your every move.',
        xpReward: 500,
        deadline: DateTime(now.year, now.month, now.day, 23, 59),
        rarity: QuestRarity.epic,
        tags: ['FOCUS', 'PRODUCTIVITY'],
        hasPenalty: true,
        penaltyXp: 100,
        penaltyDescription: '2 hour deep work session as reparation',
      ),
      Quest(
        title: '⚡ Morning Exercise',
        description: 'Complete 45-minute workout. Strength and endurance will be rewarded upon completion.',
        xpReward: 250,
        deadline: now.add(const Duration(days: 1)),
        rarity: QuestRarity.rare,
        tags: ['HEALTH', 'FITNESS'],
        hasPenalty: true,
        penaltyXp: 50,
        penaltyDescription: '100 pushups within 24 hours',
      ),
      Quest(
        title: '📖 Read 30 Pages',
        description: 'Read at least 30 pages of any educational material. Knowledge is the greatest weapon.',
        xpReward: 100,
        deadline: DateTime(now.year, now.month, now.day, 23, 59),
        rarity: QuestRarity.common,
        tags: ['SKILL', 'KNOWLEDGE'],
        hasPenalty: false,
      ),
      Quest(
        title: '🏆 Shadow Sovereign Challenge',
        description: 'Complete a 30-day streak of daily tasks. Only the strongest may claim this title.',
        xpReward: 5000,
        deadline: now.add(const Duration(days: 30)),
        rarity: QuestRarity.legendary,
        tags: ['CHALLENGE', 'STREAK'],
        hasPenalty: false,
        unlockLevel: 20,
      ),
    ];
  }
}

class LevelUpResult {
  final bool didLevelUp;
  final int newLevel;
  const LevelUpResult({required this.didLevelUp, required this.newLevel});
}

class _AchievementCheck {
  final String id, title, desc, icon;
  final bool condition;
  final int xpBonus;
  const _AchievementCheck(this.id, this.title, this.desc, this.icon, this.condition, this.xpBonus);
}

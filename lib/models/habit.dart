import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'quest.dart';

enum RepeatFrequency { daily, weekly, monthly, custom }

enum HabitStatus { active, completedToday, archived }

class RepeatConfig {
  final RepeatFrequency frequency;

  /// For weekly: list of weekday ints (1=Mon … 7=Sun)
  final List<int> weekdays;

  /// For custom: every N days
  final int? everyNDays;

  /// Time of day for the reset (default midnight)
  final TimeOfDay resetTime;

  /// null = repeat forever, otherwise stop on this date
  final DateTime? endDate;

  const RepeatConfig({
    this.frequency = RepeatFrequency.daily,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.everyNDays,
    this.resetTime = const TimeOfDay(hour: 0, minute: 0),
    this.endDate,
  });

  bool get isForever => endDate == null;

  /// Is today a scheduled day for this habit?
  bool isDueToday(DateTime now) {
    if (endDate != null && now.isAfter(endDate!)) return false;
    switch (frequency) {
      case RepeatFrequency.daily:
        return true;
      case RepeatFrequency.weekly:
        return weekdays.contains(now.weekday);
      case RepeatFrequency.monthly:
        return true; // once per month — track via lastCompletedDate
      case RepeatFrequency.custom:
        return true; // handled via everyNDays logic in provider
    }
  }

  String get frequencyLabel {
    switch (frequency) {
      case RepeatFrequency.daily:
        return 'Every day';
      case RepeatFrequency.weekly:
        if (weekdays.length == 7) return 'Every day';
        if (weekdays.length == 5 && !weekdays.contains(6) && !weekdays.contains(7)) {
          return 'Weekdays';
        }
        final names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays.map((d) => names[d]).join(', ');
      case RepeatFrequency.monthly:
        return 'Every month';
      case RepeatFrequency.custom:
        return 'Every ${everyNDays ?? 1} day${(everyNDays ?? 1) > 1 ? 's' : ''}';
    }
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency.index,
        'weekdays': weekdays,
        'everyNDays': everyNDays,
        'resetTimeHour': resetTime.hour,
        'resetTimeMinute': resetTime.minute,
        'endDate': endDate?.toIso8601String(),
      };

  factory RepeatConfig.fromJson(Map<String, dynamic> j) => RepeatConfig(
        frequency: RepeatFrequency.values[j['frequency'] ?? 0],
        weekdays: List<int>.from(j['weekdays'] ?? [1, 2, 3, 4, 5, 6, 7]),
        everyNDays: j['everyNDays'],
        resetTime: TimeOfDay(
          hour: j['resetTimeHour'] ?? 0,
          minute: j['resetTimeMinute'] ?? 0,
        ),
        endDate: j['endDate'] != null ? DateTime.parse(j['endDate']) : null,
      );
}

class Habit {
  final String id;
  String title;
  String description;
  int xpReward;
  QuestRarity rarity;
  List<String> tags;
  RepeatConfig repeatConfig;
  HabitStatus status;
  int currentStreak;
  int longestStreak;
  int totalCompletions;
  DateTime? lastCompletedDate;
  DateTime createdAt;

  /// Dates on which this habit was completed (for calendar view)
  List<DateTime> completionHistory;

  // ── Penalty fields ─────────────────────────────────────────
  bool hasPenalty;
  String? penaltyDescription;  // what the penalty task says
  int? penaltyXpDeduction;     // XP lost when missed
  int totalMissedDays;         // how many days were missed

  Habit({
    String? id,
    required this.title,
    required this.description,
    required this.xpReward,
    this.rarity = QuestRarity.common,
    this.tags = const [],
    RepeatConfig? repeatConfig,
    this.status = HabitStatus.active,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.lastCompletedDate,
    DateTime? createdAt,
    List<DateTime>? completionHistory,
    this.hasPenalty = false,
    this.penaltyDescription,
    this.penaltyXpDeduction,
    this.totalMissedDays = 0,
  })  : id = id ?? const Uuid().v4(),
        repeatConfig = repeatConfig ?? const RepeatConfig(),
        createdAt = createdAt ?? DateTime.now(),
        completionHistory = completionHistory ?? [];

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  bool get isDueToday => repeatConfig.isDueToday(DateTime.now());

  bool get isExpired =>
      repeatConfig.endDate != null &&
      DateTime.now().isAfter(repeatConfig.endDate!);

  Color get rarityColor {
    switch (rarity) {
      case QuestRarity.legendary: return const Color(0xFFFFD700);
      case QuestRarity.epic:      return const Color(0xFFA855F7);
      case QuestRarity.rare:      return const Color(0xFF4A9EFF);
      case QuestRarity.common:    return const Color(0xFF22C55E);
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case QuestRarity.legendary: return 'LEGENDARY';
      case QuestRarity.epic:      return 'EPIC';
      case QuestRarity.rare:      return 'RARE';
      case QuestRarity.common:    return 'COMMON';
    }
  }

  Habit copyWith({
    String? title,
    String? description,
    int? xpReward,
    QuestRarity? rarity,
    List<String>? tags,
    RepeatConfig? repeatConfig,
    HabitStatus? status,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    DateTime? lastCompletedDate,
    List<DateTime>? completionHistory,
    bool? hasPenalty,
    String? penaltyDescription,
    int? penaltyXpDeduction,
    int? totalMissedDays,
  }) =>
      Habit(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        xpReward: xpReward ?? this.xpReward,
        rarity: rarity ?? this.rarity,
        tags: tags ?? this.tags,
        repeatConfig: repeatConfig ?? this.repeatConfig,
        status: status ?? this.status,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        totalCompletions: totalCompletions ?? this.totalCompletions,
        lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
        createdAt: createdAt,
        completionHistory: completionHistory ?? this.completionHistory,
        hasPenalty: hasPenalty ?? this.hasPenalty,
        penaltyDescription: penaltyDescription ?? this.penaltyDescription,
        penaltyXpDeduction: penaltyXpDeduction ?? this.penaltyXpDeduction,
        totalMissedDays: totalMissedDays ?? this.totalMissedDays,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'rarity': rarity.index,
        'tags': tags,
        'repeatConfig': repeatConfig.toJson(),
        'status': status.index,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalCompletions': totalCompletions,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'completionHistory':
            completionHistory.map((d) => d.toIso8601String()).toList(),
        'hasPenalty': hasPenalty,
        'penaltyDescription': penaltyDescription,
        'penaltyXpDeduction': penaltyXpDeduction,
        'totalMissedDays': totalMissedDays,
      };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        xpReward: j['xpReward'] ?? 50,
        rarity: QuestRarity.values[j['rarity'] ?? 0],
        tags: List<String>.from(j['tags'] ?? []),
        repeatConfig: j['repeatConfig'] != null
            ? RepeatConfig.fromJson(j['repeatConfig'])
            : const RepeatConfig(),
        status: HabitStatus.values[j['status'] ?? 0],
        currentStreak: j['currentStreak'] ?? 0,
        longestStreak: j['longestStreak'] ?? 0,
        totalCompletions: j['totalCompletions'] ?? 0,
        lastCompletedDate: j['lastCompletedDate'] != null
            ? DateTime.parse(j['lastCompletedDate'])
            : null,
        createdAt: DateTime.parse(j['createdAt']),
        completionHistory: (j['completionHistory'] as List<dynamic>? ?? [])
            .map((d) => DateTime.parse(d as String))
            .toList(),
        hasPenalty: j['hasPenalty'] ?? false,
        penaltyDescription: j['penaltyDescription'],
        penaltyXpDeduction: j['penaltyXpDeduction'],
        totalMissedDays: j['totalMissedDays'] ?? 0,
      );
}

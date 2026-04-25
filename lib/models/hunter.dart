import 'dart:math';

enum HunterRank { e, d, c, b, a, s }

class HunterStats {
  int strength;
  int agility;
  int intelligence;
  int endurance;
  int perception;

  HunterStats({
    this.strength = 10,
    this.agility = 10,
    this.intelligence = 10,
    this.endurance = 10,
    this.perception = 10,
  });

  HunterStats copyWith({int? strength, int? agility, int? intelligence, int? endurance, int? perception}) {
    return HunterStats(
      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      intelligence: intelligence ?? this.intelligence,
      endurance: endurance ?? this.endurance,
      perception: perception ?? this.perception,
    );
  }

  Map<String, dynamic> toJson() => {
    'strength': strength,
    'agility': agility,
    'intelligence': intelligence,
    'endurance': endurance,
    'perception': perception,
  };

  factory HunterStats.fromJson(Map<String, dynamic> json) => HunterStats(
    strength: json['strength'] ?? 10,
    agility: json['agility'] ?? 10,
    intelligence: json['intelligence'] ?? 10,
    endurance: json['endurance'] ?? 10,
    perception: json['perception'] ?? 10,
  );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final int xpBonus;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    this.xpBonus = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'unlockedAt': unlockedAt.toIso8601String(),
    'xpBonus': xpBonus,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    icon: json['icon'],
    unlockedAt: DateTime.parse(json['unlockedAt']),
    xpBonus: json['xpBonus'] ?? 0,
  );
}

class Hunter {
  String name;
  String? profileImagePath;
  String? title; // e.g. "Shadow Monarch", "Steel Hunter"
  int level;
  int currentXp;
  HunterRank rank;
  HunterStats stats;
  List<Achievement> achievements;
  int totalQuestsCompleted;
  int totalPenaltiesFaced;
  int totalPenaltiesCompleted;
  int streakDays;
  DateTime? lastActiveDate;
  Map<DateTime, int> xpHistory; // date -> xp gained that day

  Hunter({
    this.name = 'Hunter',
    this.profileImagePath,
    this.title,
    this.level = 1,
    this.currentXp = 0,
    this.rank = HunterRank.e,
    HunterStats? stats,
    List<Achievement>? achievements,
    this.totalQuestsCompleted = 0,
    this.totalPenaltiesFaced = 0,
    this.totalPenaltiesCompleted = 0,
    this.streakDays = 0,
    this.lastActiveDate,
    Map<DateTime, int>? xpHistory,
  })  : stats = stats ?? HunterStats(),
        achievements = achievements ?? [],
        xpHistory = xpHistory ?? {};

  int get xpToNextLevel => _calculateXpRequired(level);

  double get xpProgress => min(currentXp / xpToNextLevel, 1.0);

  static int _calculateXpRequired(int level) {
    // Exponential scaling
    return (1000 * pow(1.15, level - 1)).toInt();
  }

  bool canLevelUp() => currentXp >= xpToNextLevel;

  void addXp(int xp) {
    currentXp += xp;
    // Track daily xp
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    xpHistory[today] = (xpHistory[today] ?? 0) + xp;

    // Update streak
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastActiveDate != null) {
      final lastDay = DateTime(lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
      if (lastDay == yesterday) {
        streakDays++;
      } else if (lastDay != today) {
        streakDays = 1;
      }
    } else {
      streakDays = 1;
    }
    lastActiveDate = DateTime.now();
  }

  void levelUp() {
    if (canLevelUp()) {
      currentXp -= xpToNextLevel;
      level++;
      _updateRank();
      _boostStats();
    }
  }

  void _updateRank() {
    if (level >= 80) {
      rank = HunterRank.s;
    } else if (level >= 60) {
      rank = HunterRank.a;
    } else if (level >= 40) {
      rank = HunterRank.b;
    } else if (level >= 25) {
      rank = HunterRank.c;
    } else if (level >= 10) {
      rank = HunterRank.d;
    } else {
      rank = HunterRank.e;
    }
  }

  void _boostStats() {
    // Random stat boost on level up
    final random = Random();
    final stat = random.nextInt(5);
    switch (stat) {
      case 0: stats.strength += random.nextInt(3) + 1;
      case 1: stats.agility += random.nextInt(3) + 1;
      case 2: stats.intelligence += random.nextInt(3) + 1;
      case 3: stats.endurance += random.nextInt(3) + 1;
      case 4: stats.perception += random.nextInt(3) + 1;
    }
  }

  String get rankLabel => rank.name.toUpperCase();

  String get rankDisplayLabel => '[${rank.name.toUpperCase()}-Rank]';

  Map<String, dynamic> toJson() => {
    'name': name,
    'profileImagePath': profileImagePath,
    'title': title,
    'level': level,
    'currentXp': currentXp,
    'rank': rank.index,
    'stats': stats.toJson(),
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'totalQuestsCompleted': totalQuestsCompleted,
    'totalPenaltiesFaced': totalPenaltiesFaced,
    'totalPenaltiesCompleted': totalPenaltiesCompleted,
    'streakDays': streakDays,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'xpHistory': xpHistory.map((k, v) => MapEntry(k.toIso8601String(), v)),
  };

  factory Hunter.fromJson(Map<String, dynamic> json) {
    final xpHistoryRaw = json['xpHistory'] as Map<String, dynamic>? ?? {};
    final xpHistory = <DateTime, int>{};
    xpHistoryRaw.forEach((k, v) {
      xpHistory[DateTime.parse(k)] = v as int;
    });

    return Hunter(
      name: json['name'] ?? 'Hunter',
      profileImagePath: json['profileImagePath'],
      title: json['title'],
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      rank: HunterRank.values[json['rank'] ?? 0],
      stats: HunterStats.fromJson(json['stats'] ?? {}),
      achievements: (json['achievements'] as List<dynamic>? ?? [])
          .map((a) => Achievement.fromJson(a))
          .toList(),
      totalQuestsCompleted: json['totalQuestsCompleted'] ?? 0,
      totalPenaltiesFaced: json['totalPenaltiesFaced'] ?? 0,
      totalPenaltiesCompleted: json['totalPenaltiesCompleted'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(json['lastActiveDate']) : null,
      xpHistory: xpHistory,
    );
  }
}

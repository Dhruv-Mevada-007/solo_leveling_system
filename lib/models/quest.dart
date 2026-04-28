import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum QuestRarity { legendary, epic, rare, common }

enum QuestStatus { active, completed, failed, locked, penalty }

class Quest {
  final String id;
  String title;
  String description;
  int xpReward;
  DateTime? deadline; // null = no deadline
  QuestRarity rarity;
  QuestStatus status;
  List<String> tags;
  String? penaltyTaskId;
  bool hasPenalty;
  int? penaltyXp;
  String? penaltyDescription;
  DateTime? completedAt;
  DateTime createdAt;
  int? unlockLevel;

  Quest({
    String? id,
    required this.title,
    required this.description,
    required this.xpReward,
    this.deadline,
    this.rarity = QuestRarity.common,
    this.status = QuestStatus.active,
    this.tags = const [],
    this.penaltyTaskId,
    this.hasPenalty = false,
    this.penaltyXp,
    this.penaltyDescription,
    this.completedAt,
    DateTime? createdAt,
    this.unlockLevel,
    this.penaltyTier = 0,
    this.xpPenaltyOnExpiry = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get hasDeadline => deadline != null;
  bool get isOverdue =>
      deadline != null &&
      deadline!.isBefore(DateTime.now()) &&
      status == QuestStatus.active;
  bool get isLocked => unlockLevel != null;

  /// For penalty quests: 0=first spawn, 1=first escalation, 2=second, 3=final
  int penaltyTier;

  /// XP deducted from hunter when this penalty quest expires unfinished
  int xpPenaltyOnExpiry;

  Color get rarityColor {
    switch (rarity) {
      case QuestRarity.legendary: return const Color(0xFFFFD700);
      case QuestRarity.epic:      return const Color(0xFFA855F7);
      case QuestRarity.rare:      return const Color(0xFF4A9EFF);
      case QuestRarity.common:    return const Color(0xFF22C55E);
    }
  }

  Color get statusColor {
    switch (status) {
      case QuestStatus.active:    return const Color(0xFF4A9EFF);
      case QuestStatus.completed: return const Color(0xFF22C55E);
      case QuestStatus.failed:    return const Color(0xFFEF4444);
      case QuestStatus.locked:    return const Color(0xFF888888);
      case QuestStatus.penalty:   return const Color(0xFFEF4444);
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

  Quest copyWith({
    String? title,
    String? description,
    int? xpReward,
    Object? deadline = _sentinel,
    QuestRarity? rarity,
    QuestStatus? status,
    List<String>? tags,
    String? penaltyTaskId,
    bool? hasPenalty,
    int? penaltyXp,
    String? penaltyDescription,
    DateTime? completedAt,
    int? unlockLevel,
    int? penaltyTier,
    int? xpPenaltyOnExpiry,
  }) {
    return Quest(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      deadline: deadline == _sentinel ? this.deadline : deadline as DateTime?,
      rarity: rarity ?? this.rarity,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      penaltyTaskId: penaltyTaskId ?? this.penaltyTaskId,
      hasPenalty: hasPenalty ?? this.hasPenalty,
      penaltyXp: penaltyXp ?? this.penaltyXp,
      penaltyDescription: penaltyDescription ?? this.penaltyDescription,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      unlockLevel: unlockLevel ?? this.unlockLevel,
      penaltyTier: penaltyTier ?? this.penaltyTier,
      xpPenaltyOnExpiry: xpPenaltyOnExpiry ?? this.xpPenaltyOnExpiry,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'xpReward': xpReward,
    'deadline': deadline?.toIso8601String(),
    'rarity': rarity.index,
    'status': status.index,
    'tags': tags,
    'penaltyTaskId': penaltyTaskId,
    'hasPenalty': hasPenalty,
    'penaltyXp': penaltyXp,
    'penaltyDescription': penaltyDescription,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'unlockLevel': unlockLevel,
    'penaltyTier': penaltyTier,
    'xpPenaltyOnExpiry': xpPenaltyOnExpiry,
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    xpReward: json['xpReward'],
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    rarity: QuestRarity.values[json['rarity']],
    status: QuestStatus.values[json['status']],
    tags: List<String>.from(json['tags'] ?? []),
    penaltyTaskId: json['penaltyTaskId'],
    hasPenalty: json['hasPenalty'] ?? false,
    penaltyXp: json['penaltyXp'],
    penaltyDescription: json['penaltyDescription'],
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    unlockLevel: json['unlockLevel'],
    penaltyTier: json['penaltyTier'] ?? 0,
    xpPenaltyOnExpiry: json['xpPenaltyOnExpiry'] ?? 0,
  );
}

// Sentinel so copyWith can distinguish "not passed" from "explicitly null"
const Object _sentinel = Object();

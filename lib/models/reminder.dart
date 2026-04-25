import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ReminderCategory { general, health, productivity, personal, learning, other }

extension ReminderCategoryX on ReminderCategory {
  String get label {
    switch (this) {
      case ReminderCategory.general:      return 'General';
      case ReminderCategory.health:       return 'Health';
      case ReminderCategory.productivity: return 'Productivity';
      case ReminderCategory.personal:     return 'Personal';
      case ReminderCategory.learning:     return 'Learning';
      case ReminderCategory.other:        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderCategory.general:      return Icons.push_pin_outlined;
      case ReminderCategory.health:       return Icons.favorite_outline;
      case ReminderCategory.productivity: return Icons.bolt_outlined;
      case ReminderCategory.personal:     return Icons.person_outline;
      case ReminderCategory.learning:     return Icons.menu_book_outlined;
      case ReminderCategory.other:        return Icons.more_horiz;
    }
  }
}

class Reminder {
  final String id;
  String title;
  String note;
  ReminderCategory category;
  String emoji;
  bool isPinned;
  Color color;
  DateTime createdAt;
  DateTime updatedAt;

  Reminder({
    String? id,
    required this.title,
    this.note = '',
    this.category = ReminderCategory.general,
    this.emoji = '📌',
    this.isPinned = false,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        color = color ?? const Color(0xFF4A9EFF),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get categoryLabel => category.label;
  IconData get categoryIcon => category.icon;

  Reminder copyWith({
    String? title,
    String? note,
    ReminderCategory? category,
    String? emoji,
    bool? isPinned,
    Color? color,
  }) =>
      Reminder(
        id: id,
        title: title ?? this.title,
        note: note ?? this.note,
        category: category ?? this.category,
        emoji: emoji ?? this.emoji,
        isPinned: isPinned ?? this.isPinned,
        color: color ?? this.color,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'category': category.index,
        'emoji': emoji,
        'isPinned': isPinned,
        'color': color.value,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'],
        title: j['title'],
        note: j['note'] ?? '',
        category: ReminderCategory.values[j['category'] ?? 0],
        emoji: j['emoji'] ?? '📌',
        isPinned: j['isPinned'] ?? false,
        color: Color(j['color'] ?? 0xFF4A9EFF),
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );
}

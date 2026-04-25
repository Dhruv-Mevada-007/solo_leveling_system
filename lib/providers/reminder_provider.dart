import 'dart:ui';

import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../services/storage_service.dart';

class ReminderProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Reminder> _reminders = [];
  bool _isLoading = true;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;

  List<Reminder> get pinnedReminders =>
      _reminders.where((r) => r.isPinned).toList();

  List<Reminder> get unpinnedReminders =>
      _reminders.where((r) => !r.isPinned).toList();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _reminders = await _storage.loadReminders();
    if (_reminders.isEmpty) _reminders = _defaults();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(Reminder r) async {
    _reminders.insert(0, r);
    await _storage.saveReminders(_reminders);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder updated) async {
    final idx = _reminders.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _reminders[idx] = updated;
      await _storage.saveReminders(_reminders);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _storage.saveReminders(_reminders);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final r = _reminders[idx];
      _reminders[idx] = r.copyWith(isPinned: !r.isPinned);
      await _storage.saveReminders(_reminders);
      notifyListeners();
    }
  }

  List<Reminder> _defaults() => [
        Reminder(
          title: 'Drink 2L of water today',
          note: 'Hydration is not optional. Keep a bottle at your desk.',
          category: ReminderCategory.health,
          emoji: '💧',
          isPinned: true,
          color: const Color(0xFF4A9EFF),
        ),
        Reminder(
          title: 'No phone first 30 minutes after waking',
          note: 'Protect your morning mind. Let it wake up on its own terms.',
          category: ReminderCategory.personal,
          emoji: '🌅',
          color: const Color(0xFFF59E0B),
        ),
        Reminder(
          title: 'Review your goals weekly',
          note: 'Every Sunday — check your progress and adjust.',
          category: ReminderCategory.productivity,
          emoji: '📊',
          color: const Color(0xFFA855F7),
        ),
      ];
}

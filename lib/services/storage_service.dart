import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';
import '../models/hunter.dart';
import '../models/habit.dart';
import '../models/reminder.dart';

class StorageService {
  // ── Singleton ──────────────────────────────────────────────
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _questsKey   = 'quests';
  static const String _hunterKey   = 'hunter';
  static const String _habitsKey   = 'habits';
  static const String _remindersKey = 'reminders';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Hunter ─────────────────────────────────────────────────
  Future<Hunter?> loadHunter() async {
    final data = _prefs?.getString(_hunterKey);
    if (data == null) return null;
    try { return Hunter.fromJson(json.decode(data)); } catch (_) { return null; }
  }

  Future<void> saveHunter(Hunter hunter) async {
    await _prefs?.setString(_hunterKey, json.encode(hunter.toJson()));
  }

  // ── Quests ─────────────────────────────────────────────────
  Future<List<Quest>> loadQuests() async {
    final data = _prefs?.getString(_questsKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = json.decode(data);
      return list.map((q) => Quest.fromJson(q)).toList();
    } catch (_) { return []; }
  }

  Future<void> saveQuests(List<Quest> quests) async {
    await _prefs?.setString(_questsKey, json.encode(quests.map((q) => q.toJson()).toList()));
  }

  // ── Habits ─────────────────────────────────────────────────
  Future<List<Habit>> loadHabits() async {
    final data = _prefs?.getString(_habitsKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = json.decode(data);
      return list.map((h) => Habit.fromJson(h)).toList();
    } catch (_) { return []; }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    await _prefs?.setString(_habitsKey, json.encode(habits.map((h) => h.toJson()).toList()));
  }

  // ── Reminders ──────────────────────────────────────────────
  Future<List<Reminder>> loadReminders() async {
    final data = _prefs?.getString(_remindersKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = json.decode(data);
      return list.map((r) => Reminder.fromJson(r)).toList();
    } catch (_) { return []; }
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    await _prefs?.setString(_remindersKey, json.encode(reminders.map((r) => r.toJson()).toList()));
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}


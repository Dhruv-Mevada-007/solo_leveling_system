import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';
import '../models/hunter.dart';

class StorageService {
  // ── Singleton ──────────────────────────────────────────────
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _questsKey = 'quests';
  static const String _hunterKey = 'hunter';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Hunter ─────────────────────────────────────────────────
  Future<Hunter?> loadHunter() async {
    final data = _prefs?.getString(_hunterKey);
    if (data == null) return null;
    try {
      return Hunter.fromJson(json.decode(data));
    } catch (_) {
      return null;
    }
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
    } catch (_) {
      return [];
    }
  }

  Future<void> saveQuests(List<Quest> quests) async {
    final data = quests.map((q) => q.toJson()).toList();
    await _prefs?.setString(_questsKey, json.encode(data));
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}

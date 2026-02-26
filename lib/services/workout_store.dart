import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_record.dart';

class WorkoutStore {
  static const String _key = 'workout_records';

  Future<List<WorkoutRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }
    return decoded
        .whereType<Map>()
        .map((raw) =>
            WorkoutRecord.fromJson(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  Future<void> saveRecords(List<WorkoutRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_key, payload);
  }
}

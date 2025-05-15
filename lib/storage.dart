import 'package:life_points/service_locator.dart';
import 'dart:convert';

class Storage {
  static const String _usernameKey = 'username';
  static const String _pointsKey = 'points';
  static const String _tasksKey = 'tasks';
  static const String _overdueFrequencyKey = 'overdue_frequency';
  static const String _overduePointsKey = 'overdue_points';

  static Future<void> saveUsername(String username) async {
    await ServiceLocator.prefs.setString(_usernameKey, username);
  }

  static Future<String?> getUsername() async {
    return ServiceLocator.prefs.getString(_usernameKey);
  }

  static Future<void> savePoints(int points) async {
    await ServiceLocator.prefs.setInt(_pointsKey, points);
  }

  static Future<int> getPoints() async {
    return ServiceLocator.prefs.getInt(_pointsKey) ?? 0;
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final tasksJson = tasks.map((task) => json.encode(task)).toList();
    await ServiceLocator.prefs.setStringList(_tasksKey, tasksJson);
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final tasksJson = ServiceLocator.prefs.getStringList(_tasksKey) ?? [];
    return tasksJson
        .map((task) => json.decode(task) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> saveOverdueSettings(String frequency, int points) async {
    await ServiceLocator.prefs.setString(_overdueFrequencyKey, frequency);
    await ServiceLocator.prefs.setInt(_overduePointsKey, points);
  }

  static Future<Map<String, dynamic>> getOverdueSettings() async {
    return {
      'frequency':
          ServiceLocator.prefs.getString(_overdueFrequencyKey) ?? 'Never',
      'points': ServiceLocator.prefs.getInt(_overduePointsKey) ?? 0,
    };
  }

  static Future<void> clearAllData() async {
    await ServiceLocator.prefs.remove(_usernameKey);
    await ServiceLocator.prefs.remove(_pointsKey);
    await ServiceLocator.prefs.remove(_tasksKey);
    await ServiceLocator.prefs.remove(_overdueFrequencyKey);
    await ServiceLocator.prefs.remove(_overduePointsKey);
  }
}

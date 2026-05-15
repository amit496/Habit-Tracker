import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static late Box _habits;
  static late Box _logs;
  static late Box _settings;

  static Future<void> init() async {
    _habits = await Hive.openBox('habits');
    _logs = await Hive.openBox('habit_logs');
    _settings = await Hive.openBox('settings');
  }

  static Box get habits => _habits;
  static Box get logs => _logs;

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settings.get(key, defaultValue: defaultValue);
  }

  static Future<void> setSetting(String key, dynamic value) async {
    await _settings.put(key, value);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class BackupService {
  static const backupVersion = 1;

  static String buildJson({
    required List<HabitModel> habits,
    required List<HabitLogModel> logs,
    required bool isDarkMode,
    required int weekStart,
  }) {
    final payload = {
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'HabitFlow',
      'settings': {
        'isDarkMode': isDarkMode,
        'weekStart': weekStart,
      },
      'habits': habits.map((h) => h.toMap()).toList(),
      'logs': logs.map((l) => l.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static BackupParseResult parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Invalid backup file');
    }
    final map = Map<String, dynamic>.from(decoded);
    final habitsRaw = map['habits'];
    final logsRaw = map['logs'];
    if (habitsRaw is! List || logsRaw is! List) {
      throw const FormatException('Missing habits or logs in backup');
    }

    final habits = habitsRaw
        .map((e) => HabitModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    final logs = logsRaw
        .map((e) => HabitLogModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();

    final settings = map['settings'];
    var isDarkMode = false;
    var weekStart = 1;
    if (settings is Map) {
      isDarkMode = settings['isDarkMode'] == true;
      weekStart = (settings['weekStart'] as num?)?.toInt() ?? 1;
    }

    return BackupParseResult(
      habits: habits,
      logs: logs,
      isDarkMode: isDarkMode,
      weekStart: weekStart,
    );
  }

  static Future<void> shareJson(String json) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/habitflow_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(json);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'HabitFlow backup',
    );
  }
}

class BackupParseResult {
  final List<HabitModel> habits;
  final List<HabitLogModel> logs;
  final bool isDarkMode;
  final int weekStart;

  const BackupParseResult({
    required this.habits,
    required this.logs,
    required this.isDarkMode,
    required this.weekStart,
  });
}

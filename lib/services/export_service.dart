import 'package:share_plus/share_plus.dart';

import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class ExportService {
  static String buildCsv({
    required List<HabitModel> habits,
    required List<HabitLogModel> logs,
  }) {
    final habitNames = {for (final h in habits) h.id: h.name};
    final buffer = StringBuffer(
      'date,habit,completed,count,note\n',
    );
    final sorted = List<HabitLogModel>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final log in sorted) {
      final name = habitNames[log.habitId] ?? log.habitId;
      final note = log.note.replaceAll(',', ';').replaceAll('\n', ' ');
      buffer.writeln(
        '${log.dateKey},'
        '${_escape(name)},'
        '${log.completed},'
        '${log.count},'
        '${_escape(note)}',
      );
    }
    return buffer.toString();
  }

  static String _escape(String s) => '"${s.replaceAll('"', "'")}"';

  static Future<void> shareCsv(String csv) async {
    await Share.share(csv, subject: 'HabitFlow export');
  }
}

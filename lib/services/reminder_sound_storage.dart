import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ReminderSoundStorage {
  static Future<String> copyCustomSound(File source, String habitId) async {
    final dir = await getApplicationDocumentsDirectory();
    final soundsDir = Directory('${dir.path}/reminder_sounds');
    if (!await soundsDir.exists()) {
      await soundsDir.create(recursive: true);
    }
    final name = source.path.split('/').last;
    final dot = name.lastIndexOf('.');
    final ext = dot > 0 ? name.substring(dot) : '.mp3';
    final dest = File('${soundsDir.path}/habit_$habitId$ext');
    if (await dest.exists()) await dest.delete();
    await source.copy(dest.path);
    return dest.path;
  }

  static String fileNameFromPath(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.split('/').last;
  }
}

import 'package:flutter/material.dart';

import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

Future<void> showHabitNoteDialog({
  required BuildContext context,
  required HabitProvider provider,
  required HabitModel habit,
  required DateTime date,
  String initialNote = '',
}) async {
  final controller = TextEditingController(text: initialNote);
  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Note for ${habit.name}'),
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Optional note for this day...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (saved == true) {
    await provider.updateLogNote(habit, date, controller.text);
  }
}

import 'package:flutter/material.dart';

import '../core/constants/habit_templates.dart';
import '../core/constants/habit_icons.dart';
import '../core/theme/app_theme.dart';
import '../screens/habit_form_screen.dart';

void showAddHabitSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add habit',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.edit_rounded,
                color: AppTheme.primaryFor(ctx),
              ),
              title: const Text('Create from scratch'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitFormScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Templates',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText(ctx),
              ),
            ),
            const SizedBox(height: 8),
            ...HabitTemplates.all.map((t) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Color(t.colorValue).withValues(alpha: 0.15),
                  child: Icon(
                    HabitIcons.iconFor(t.iconKey),
                    color: Color(t.colorValue),
                    size: 20,
                  ),
                ),
                title: Text(t.name),
                subtitle: Text(t.subtitle),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitFormScreen(template: t),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}

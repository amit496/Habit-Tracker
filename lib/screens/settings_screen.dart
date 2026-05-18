import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/utils/date_utils.dart';

import '../core/constants/habit_categories.dart';
import '../core/theme/app_theme.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../services/hive_service.dart';
import '../services/reminder_service.dart';
import '../widgets/habit_flow_logo.dart';
import '../widgets/screen_header.dart';
import 'habit_form_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = provider.activeHabits;
    final archived = provider.archivedHabits;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          ScreenHeader(
            subtitle: 'v1.2.0 • Offline habit tracker',
            title: 'Settings',
          ),
          const SizedBox(height: 20),
          _section(context, 'General'),
          _card(
            isDark: isDark,
            child: SwitchListTile(
              title: const Text('Dark mode'),
              value: provider.isDarkMode,
              onChanged: (_) => provider.toggleTheme(),
              activeTrackColor: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          _card(
            isDark: isDark,
            child: ListTile(
              title: const Text('Week starts on'),
              subtitle: Text(provider.weekStart == 7 ? 'Sunday' : 'Monday'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                  provider.setWeekStart(provider.weekStart == 7 ? 1 : 7),
            ),
          ),
          const SizedBox(height: 10),
          _card(
            isDark: isDark,
            child: ListTile(
              leading: const Icon(Icons.replay_rounded),
              title: const Text('Show onboarding again'),
              onTap: () async {
                await HiveService.setSetting('onboardingComplete', false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restart the app to see onboarding'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          _section(context, 'Streak freeze'),
          _card(
            isDark: isDark,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.ac_unit_rounded,
                    color: AppTheme.primaryFor(context),
                  ),
                  title: const Text('Freeze today'),
                  subtitle: const Text(
                    'Missed habits won\'t break streaks today',
                  ),
                  onTap: () async {
                    if (provider.isDateFrozen(DateOnly.today())) {
                      await provider.unfreezeDate(DateOnly.today());
                    } else {
                      await provider.freezeDate(DateOnly.today());
                    }
                  },
                  trailing: Switch(
                    value: provider.isDateFrozen(DateOnly.today()),
                    onChanged: (_) async {
                      await provider.toggleFreezeDate(DateOnly.today());
                    },
                    activeTrackColor: AppTheme.primary,
                  ),
                ),
                if (provider.frozenDatesSorted.isNotEmpty) ...[
                  const Divider(height: 1),
                  ...provider.frozenDatesSorted.take(8).map((key) {
                    final d = DateOnly.parseKey(key);
                    final label = d != null
                        ? DateFormat('MMM d, yyyy').format(d)
                        : key;
                    return ListTile(
                      dense: true,
                      title: Text(label),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          if (d != null) provider.unfreezeDate(d);
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _section(context, 'Data & backup'),
          _card(
            isDark: isDark,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_rounded,
                      color: AppTheme.primary),
                  title: const Text('Backup (JSON)'),
                  subtitle: const Text('Save all habits and logs'),
                  onTap: () async {
                    try {
                      await provider.exportAndShareBackup();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Backup failed: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_rounded,
                      color: AppTheme.primary),
                  title: const Text('Restore from backup'),
                  subtitle: const Text('Replaces current data'),
                  onTap: () => _restoreBackup(context, provider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.ios_share_rounded,
                      color: AppTheme.primary),
                  title: const Text('Export logs (CSV)'),
                  subtitle: const Text('Share via email, Drive, etc.'),
                  onTap: () async {
                    try {
                      await provider.exportAndShareCsv();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          if (!ReminderService.isReady)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Reminders need a full app restart after install (not hot restart).',
                style: TextStyle(fontSize: 12, color: AppTheme.primary),
              ),
            ),
          if (Platform.isAndroid || Platform.isIOS)
            FutureBuilder<bool>(
              future: ReminderService.areNotificationsEnabled(),
              builder: (context, snap) {
                if (snap.data != false) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Notifications are off. Open system Settings → HabitFlow → '
                    'Notifications and allow alerts and sound.',
                    style: TextStyle(fontSize: 12, color: AppTheme.primary),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          _section(context, 'Active habits'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitFormScreen()),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ),
          if (habits.isEmpty)
            Text('No active habits', style: TextStyle(color: Colors.grey))
          else
            ...habits.map((h) => _habitTile(context, h, isDark, provider)),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 20),
            _section(context, 'Archived'),
            ...archived.map(
              (h) => _habitTile(context, h, isDark, provider, archived: true),
            ),
          ],
          const SizedBox(height: 32),
          _card(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const HabitFlowLogoTile(size: 80),
                  const SizedBox(height: 12),
                  const Text(
                    'HabitFlow',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('v1.2.0 • Offline habit tracker'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(
    BuildContext context,
    HabitProvider provider,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This replaces all habits and logs with the backup file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final file = result.files.single;
      final raw = file.path != null
          ? await File(file.path!).readAsString()
          : String.fromCharCodes(file.bytes ?? []);
      await provider.restoreFromBackup(raw);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryFor(context),
          ),
        ),
      );

  Widget _habitTile(
    BuildContext context,
    HabitModel h,
    bool isDark,
    HabitProvider provider, {
    bool archived = false,
  }) {
    final category = HabitCategories.forKey(h.categoryKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _card(
        isDark: isDark,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: h.color.withValues(alpha: 0.2),
            child: Icon(category.icon, color: h.color, size: 18),
          ),
          title: Text(h.name),
          subtitle: Text(
            archived
                ? 'Archived'
                : '${category.label} • ${h.scheduleLabel}${h.hasReminder ? ' • ${h.reminderHour}:${h.reminderMinute.toString().padLeft(2, '0')}' : ''}',
          ),
          trailing: archived
              ? IconButton(
                  icon: const Icon(Icons.unarchive_rounded),
                  onPressed: () => provider.setArchived(h, false),
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HabitFormScreen(habit: h)),
          ),
        ),
      ),
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: child,
    );
  }
}

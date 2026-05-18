import 'package:flutter/material.dart';

class TutorialTopic {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> steps;

  const TutorialTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.steps,
  });
}

class TutorialTopics {
  TutorialTopics._();

  static const all = [
    TutorialTopic(
      title: 'Getting started',
      subtitle: 'Create your first habit',
      icon: Icons.rocket_launch_rounded,
      steps: [
        'On Today, tap + to add a habit.',
        'Choose Create custom habit or pick a Quick start template.',
        'Set a name, category, icon, and color, then tap Create habit.',
        'Your habit appears on Today when it is scheduled for that day.',
      ],
    ),
    TutorialTopic(
      title: 'Today tab',
      subtitle: 'Complete habits each day',
      icon: Icons.today_rounded,
      steps: [
        'Today shows habits scheduled for the current day.',
        'Tap a habit to mark it complete, or tap + on target habits to count up.',
        'Long-press a habit to add a note for that day.',
        'Use category chips to filter the list.',
        'The progress ring shows how many habits you have finished today.',
      ],
    ),
    TutorialTopic(
      title: 'Calendar',
      subtitle: 'Log habits on any past day',
      icon: Icons.calendar_month_rounded,
      steps: [
        'Open Calendar and select a date.',
        'Complete or update habits for that day — great for catching up.',
        'Future dates cannot be edited.',
        'Use Freeze on a date in Calendar to protect streaks when you need a break.',
      ],
    ),
    TutorialTopic(
      title: 'Stats & streaks',
      subtitle: 'Track your momentum',
      icon: Icons.insights_rounded,
      steps: [
        'Stats shows your global streak, monthly completions, and a 7-day chart.',
        'Year at a glance is a heatmap of your last 365 days — darker means more completed.',
        'Per-habit streaks show current and best streaks; tap a habit for details.',
        'Open a habit to see its 30-day activity and history.',
      ],
    ),
    TutorialTopic(
      title: 'Streak freeze',
      subtitle: 'Protect streaks on rest days',
      icon: Icons.ac_unit_rounded,
      steps: [
        'Streak freeze lets you skip a day without breaking your streak.',
        'In Settings → Streak freeze, turn on Freeze today, or use Calendar → Freeze on a past day.',
        'Frozen days do not require completions for streak calculations.',
        'Remove a freeze anytime from Settings or Calendar.',
      ],
    ),
    TutorialTopic(
      title: 'Reminders',
      subtitle: 'Stay on schedule',
      icon: Icons.notifications_active_rounded,
      steps: [
        'When creating or editing a habit, enable Daily reminder and set a time.',
        'Choose a notification tone or select a custom audio file.',
        'Tap Play preview to hear the sound before saving.',
        'Allow notifications for HabitFlow in your phone Settings if reminders do not appear.',
        'After installing the app, fully close and reopen it once for sounds to work.',
      ],
    ),
    TutorialTopic(
      title: 'Targets & schedule',
      subtitle: 'Flexible habit setup',
      icon: Icons.tune_rounded,
      steps: [
        'Enable Daily target to track a number (e.g. 8 glasses of water).',
        'Turn on Weekly schedule to run a habit only on selected days.',
        'Archive a habit in Settings or the edit screen to hide it without deleting history.',
        'Duplicate a habit from its detail or edit screen to copy settings quickly.',
      ],
    ),
    TutorialTopic(
      title: 'Backup & export',
      subtitle: 'Keep your data safe',
      icon: Icons.backup_rounded,
      steps: [
        'Settings → Backup (JSON) saves all habits, logs, and preferences.',
        'Restore from backup replaces current data — use before switching phones.',
        'Export logs (CSV) shares your history for spreadsheets or records.',
        'All data stays on your device; HabitFlow does not use the cloud.',
      ],
    ),
    TutorialTopic(
      title: 'Privacy & offline use',
      subtitle: 'Your data stays on device',
      icon: Icons.shield_rounded,
      steps: [
        'HabitFlow works fully offline — no account required.',
        'Habits and logs are stored locally on your phone.',
        'Back up regularly if you change devices or reinstall the app.',
      ],
    ),
  ];
}

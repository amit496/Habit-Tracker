import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/habit_categories.dart';
import '../core/constants/habit_icons.dart';
import '../core/constants/habit_templates.dart';
import '../core/constants/reminder_sounds.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/brand.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../services/reminder_service.dart';
import '../services/reminder_sound_storage.dart';

class HabitFormScreen extends StatefulWidget {
  final HabitModel? habit;
  final HabitTemplate? template;

  const HabitFormScreen({super.key, this.habit, this.template});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late String _iconKey;
  late int _colorValue;
  late String _categoryKey;
  late Set<int> _scheduleDays;
  bool _useTarget = false;
  bool _useReminder = false;
  bool _customSchedule = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _reminderSoundKey = ReminderSounds.defaultKey;
  String _customSoundPath = '';
  String _customSoundLabel = '';
  bool _archived = false;

  static final _colors = Brand.habitColorValues;

  static const _weekdays = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  bool get _isEdit => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    final t = widget.template;
    _name = TextEditingController(text: h?.name ?? t?.name ?? '');
    _target = TextEditingController(
      text: h?.targetCount?.toString() ??
          t?.targetCount?.toString() ??
          '8',
    );
    _iconKey = h?.iconKey ?? t?.iconKey ?? 'star';
    _colorValue = h?.colorValue ?? t?.colorValue ?? _colors.first;
    _categoryKey =
        h?.categoryKey ?? t?.categoryKey ?? HabitCategories.general;
    if (h != null && !h.isDaily) {
      _scheduleDays = h.scheduleDays.toSet();
      _customSchedule = true;
    } else if (t != null && !t.isDaily) {
      _scheduleDays = t.scheduleDays.toSet();
      _customSchedule = true;
    } else {
      _scheduleDays = {1, 2, 3, 4, 5, 6, 7};
      _customSchedule = false;
    }
    _useTarget = h?.hasTarget ?? (t?.targetCount != null);
    _useReminder = h?.hasReminder ?? false;
    if (h != null && h.hasReminder) {
      _reminderTime =
          TimeOfDay(hour: h.reminderHour, minute: h.reminderMinute);
    }
    _reminderSoundKey = h?.reminderSoundKey ?? ReminderSounds.defaultKey;
    _customSoundPath = h?.reminderCustomSoundPath ?? '';
    _customSoundLabel = ReminderSoundStorage.fileNameFromPath(_customSoundPath);
    _archived = h?.archived ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  String _scheduleLabel(List<int> days) {
    if (days.isEmpty || days.length >= 7) return 'Every day';
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = [...days]..sort();
    return sorted.map((d) => names[d]).join(', ');
  }

  List<int> _resolvedScheduleDays() {
    if (!_customSchedule) return [];
    if (_scheduleDays.isEmpty || _scheduleDays.length >= 7) return [];
    return _scheduleDays.toList()..sort();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    if (_customSchedule && _scheduleDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    int? target;
    if (_useTarget) {
      target = int.tryParse(_target.text.trim());
      if (target == null || target < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid daily target')),
        );
        return;
      }
    }

    final reminderHour = _useReminder ? _reminderTime.hour : -1;
    final reminderMinute = _useReminder ? _reminderTime.minute : 0;
    final scheduleDays = _resolvedScheduleDays();

    final provider = context.read<HabitProvider>();
    final habitId =
        _isEdit ? widget.habit!.id : DateTime.now().millisecondsSinceEpoch.toString();

    var soundKey = _reminderSoundKey;
    var customPath = _customSoundPath;
    if (_useReminder &&
        soundKey == ReminderSounds.customKey &&
        customPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a custom sound or choose a built-in tone'),
        ),
      );
      return;
    }

    if (_isEdit) {
      await provider.updateHabit(
        widget.habit!.copyWith(
          name: name,
          iconKey: _iconKey,
          colorValue: _colorValue,
          targetCount: target,
          clearTarget: !_useTarget,
          archived: _archived,
          reminderHour: reminderHour,
          reminderMinute: reminderMinute,
          clearReminder: !_useReminder,
          reminderSoundKey: soundKey,
          reminderCustomSoundPath: customPath,
          categoryKey: _categoryKey,
          scheduleDays: scheduleDays,
          clearSchedule: scheduleDays.isEmpty,
        ),
      );
    } else {
      await provider.addHabit(
        HabitModel(
          id: habitId,
          name: name,
          iconKey: _iconKey,
          colorValue: _colorValue,
          targetCount: target,
          createdAt: DateTime.now(),
          reminderHour: reminderHour,
          reminderMinute: reminderMinute,
          reminderSoundKey: soundKey,
          reminderCustomSoundPath: customPath,
          categoryKey: _categoryKey,
          scheduleDays: scheduleDays,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickCustomSound() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a'],
    );
    if (result == null || result.files.single.path == null) return;
    final source = File(result.files.single.path!);
    final habitId = widget.habit?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final dest = await ReminderSoundStorage.copyCustomSound(source, habitId);
      setState(() {
        _customSoundPath = dest;
        _customSoundLabel = ReminderSoundStorage.fileNameFromPath(dest);
        _reminderSoundKey = ReminderSounds.customKey;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load audio file: $e')),
        );
      }
    }
  }

  Future<void> _testReminderSound() async {
    if (_useReminder &&
        _reminderSoundKey == ReminderSounds.customKey &&
        _customSoundPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an audio file first')),
      );
      return;
    }

    final preview = HabitModel(
      id: widget.habit?.id ?? 'preview',
      name: _name.text.trim().isEmpty ? 'Preview' : _name.text.trim(),
      iconKey: _iconKey,
      colorValue: _colorValue,
      createdAt: DateTime.now(),
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
      reminderSoundKey: _reminderSoundKey,
      reminderCustomSoundPath: _customSoundPath,
    );

    try {
      await ReminderService.previewSound(preview);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playing selected tone')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play sound: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: const Text(
          'This will permanently remove the habit and all associated history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<HabitProvider>().deleteHabit(widget.habit!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppTheme.mutedText(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit habit' : 'New habit'),
        actions: [
          if (_isEdit) ...[
            IconButton(
              tooltip: 'Duplicate',
              onPressed: () async {
                final provider = context.read<HabitProvider>();
                await provider.duplicateHabit(widget.habit!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habit duplicated successfully')),
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.copy_rounded),
            ),
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.danger),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g. Drink water',
            ),
          ),
          const SizedBox(height: 20),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HabitCategories.all.map((c) {
              final sel = _categoryKey == c.key;
              return FilterChip(
                avatar: Icon(c.icon, size: 16),
                label: Text(c.label),
                selected: sel,
                onSelected: (_) => setState(() => _categoryKey = c.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: HabitIcons.options.map((o) {
              final sel = _iconKey == o.key;
              return GestureDetector(
                onTap: () => setState(() => _iconKey = o.key),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.primaryFor(context).withValues(alpha: 0.15)
                        : (isDark
                            ? AppTheme.darkCardLight
                            : AppTheme.lightBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppTheme.primaryFor(context)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    o.icon,
                    color: sel ? AppTheme.primaryFor(context) : muted,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: _colors.map((c) {
              final sel = _colorValue == c;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: sel
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: Color(c).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Weekly schedule'),
            subtitle: Text(
              _customSchedule
                  ? _scheduleDays.isEmpty
                      ? 'Select days below'
                      : _scheduleLabel(_scheduleDays.toList())
                  : 'Repeats every day',
            ),
            value: _customSchedule,
            onChanged: (v) => setState(() {
              _customSchedule = v;
              if (v && _scheduleDays.isEmpty) {
                _scheduleDays = {1, 3, 5};
              }
              if (!v) _scheduleDays = {1, 2, 3, 4, 5, 6, 7};
            }),
          ),
          if (_customSchedule) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _weekdays.map((wd) {
                final sel = _scheduleDays.contains(wd.$1);
                return FilterChip(
                  label: Text(wd.$2),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    if (sel) {
                      _scheduleDays.remove(wd.$1);
                    } else {
                      _scheduleDays.add(wd.$1);
                    }
                  }),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily target'),
            subtitle: const Text('Track a number each day (e.g. 8 glasses)'),
            value: _useTarget,
            onChanged: (v) => setState(() => _useTarget = v),
          ),
          if (_useTarget)
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily target',
                hintText: 'e.g. 8',
              ),
            ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily reminder'),
            subtitle: Text(
              _useReminder
                  ? 'Daily at ${_reminderTime.format(context)}'
                  : 'Not set',
            ),
            value: _useReminder,
            onChanged: (v) => setState(() => _useReminder = v),
          ),
          if (_useReminder) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder time'),
              trailing: TextButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (t != null) setState(() => _reminderTime = t);
                },
                child: Text(_reminderTime.format(context)),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Notification tone',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...ReminderSounds.builtIn.map((s) {
                  final sel = _reminderSoundKey == s.key;
                  return ChoiceChip(
                    label: Text(s.label),
                    avatar: Icon(s.icon, size: 18),
                    selected: sel,
                    onSelected: (_) => setState(() => _reminderSoundKey = s.key),
                  );
                }),
                ChoiceChip(
                  label: Text(
                    _customSoundLabel.isEmpty
                        ? 'Custom audio'
                        : _customSoundLabel,
                  ),
                  avatar: const Icon(Icons.audio_file_rounded, size: 18),
                  selected: _reminderSoundKey == ReminderSounds.customKey,
                  onSelected: (_) => setState(
                    () => _reminderSoundKey = ReminderSounds.customKey,
                  ),
                ),
              ],
            ),
            if (_reminderSoundKey == ReminderSounds.customKey) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickCustomSound,
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(
                  _customSoundLabel.isEmpty
                      ? 'Select audio file'
                      : 'Replace audio file',
                ),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _testReminderSound,
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Play preview'),
            ),
            if (!ReminderService.isReady)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Scheduled reminders need a full app restart after install. '
                  'Preview works here without restart.',
                  style: TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
              ),
          ],
          if (_isEdit) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Archive habit'),
              subtitle: const Text('Hidden from Today; history is preserved'),
              value: _archived,
              onChanged: (v) => setState(() => _archived = v),
            ),
          ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(_isEdit ? 'Save changes' : 'Create habit'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

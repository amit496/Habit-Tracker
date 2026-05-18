import 'habit_categories.dart';

class HabitTemplate {
  final String name;
  final String iconKey;
  final int colorValue;
  final String categoryKey;
  final List<int> scheduleDays;
  final int? targetCount;
  final String subtitle;

  const HabitTemplate({
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.categoryKey,
    this.scheduleDays = const [],
    this.targetCount,
    required this.subtitle,
  });

  bool get isDaily => scheduleDays.isEmpty || scheduleDays.length >= 7;
}

class HabitTemplates {
  HabitTemplates._();

  static const all = [
    HabitTemplate(
      name: 'Drink water',
      iconKey: 'water',
      colorValue: 0xFF6366F1,
      categoryKey: 'health',
      targetCount: 8,
      subtitle: '8 glasses daily',
    ),
    HabitTemplate(
      name: 'Exercise',
      iconKey: 'fitness',
      colorValue: 0xFF8B5CF6,
      categoryKey: 'fitness',
      scheduleDays: [1, 3, 5],
      subtitle: 'Mon, Wed, Fri',
    ),
    HabitTemplate(
      name: 'Read',
      iconKey: 'book',
      colorValue: 0xFF4F46E5,
      categoryKey: 'study',
      subtitle: 'Every day',
    ),
    HabitTemplate(
      name: 'Meditate',
      iconKey: 'meditate',
      colorValue: 0xFF7C3AED,
      categoryKey: 'mindfulness',
      subtitle: 'Every day',
    ),
    HabitTemplate(
      name: 'Morning walk',
      iconKey: 'walk',
      colorValue: 0xFF6366F1,
      categoryKey: 'fitness',
      subtitle: 'Every day',
    ),
    HabitTemplate(
      name: 'Journal',
      iconKey: 'star',
      colorValue: 0xFF6366F1,
      categoryKey: HabitCategories.general,
      subtitle: 'Every day',
    ),
  ];
}

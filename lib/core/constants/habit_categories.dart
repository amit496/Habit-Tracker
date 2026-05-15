import 'package:flutter/material.dart';

class HabitCategory {
  final String key;
  final String label;
  final IconData icon;

  const HabitCategory({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class HabitCategories {
  HabitCategories._();

  static const general = 'general';

  static const List<HabitCategory> all = [
    HabitCategory(key: general, label: 'General', icon: Icons.star_rounded),
    HabitCategory(
      key: 'health',
      label: 'Health',
      icon: Icons.favorite_rounded,
    ),
    HabitCategory(
      key: 'fitness',
      label: 'Fitness',
      icon: Icons.fitness_center_rounded,
    ),
    HabitCategory(
      key: 'study',
      label: 'Study',
      icon: Icons.menu_book_rounded,
    ),
    HabitCategory(
      key: 'mindfulness',
      label: 'Mindfulness',
      icon: Icons.self_improvement_rounded,
    ),
    HabitCategory(
      key: 'productivity',
      label: 'Productivity',
      icon: Icons.work_rounded,
    ),
  ];

  static HabitCategory forKey(String key) {
    return all.firstWhere(
      (c) => c.key == key,
      orElse: () => all.first,
    );
  }
}

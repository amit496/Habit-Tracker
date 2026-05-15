import 'package:flutter/material.dart';

class HabitIconOption {
  final String key;
  final IconData icon;

  const HabitIconOption(this.key, this.icon);
}

class HabitIcons {
  static const options = [
    HabitIconOption('fitness', Icons.fitness_center_rounded),
    HabitIconOption('book', Icons.menu_book_rounded),
    HabitIconOption('water', Icons.water_drop_rounded),
    HabitIconOption('sleep', Icons.bedtime_rounded),
    HabitIconOption('meditate', Icons.self_improvement_rounded),
    HabitIconOption('code', Icons.code_rounded),
    HabitIconOption('walk', Icons.directions_walk_rounded),
    HabitIconOption('food', Icons.restaurant_rounded),
    HabitIconOption('money', Icons.savings_rounded),
    HabitIconOption('star', Icons.star_rounded),
  ];

  static IconData iconFor(String key) {
    return options
        .firstWhere(
          (o) => o.key == key,
          orElse: () => options.first,
        )
        .icon;
  }
}

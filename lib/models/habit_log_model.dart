import '../core/utils/date_utils.dart';

class HabitLogModel {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final int count;
  final String note;

  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.count = 0,
    this.note = '',
  });

  String get dateKey => DateOnly.key(date);

  Map<String, dynamic> toMap() => {
        'id': id,
        'habitId': habitId,
        'date': dateKey,
        'completed': completed,
        'count': count,
        'note': note,
      };

  factory HabitLogModel.fromMap(Map<dynamic, dynamic> map) {
    final dateKey = map['date']?.toString() ?? '';
    return HabitLogModel(
      id: map['id']?.toString() ?? '',
      habitId: map['habitId']?.toString() ?? '',
      date: DateOnly.parseKey(dateKey) ?? DateOnly.today(),
      completed: map['completed'] == true,
      count: (map['count'] as num?)?.toInt() ?? 0,
      note: map['note']?.toString() ?? '',
    );
  }

  HabitLogModel copyWith({bool? completed, int? count, String? note}) {
    return HabitLogModel(
      id: id,
      habitId: habitId,
      date: date,
      completed: completed ?? this.completed,
      count: count ?? this.count,
      note: note ?? this.note,
    );
  }
}

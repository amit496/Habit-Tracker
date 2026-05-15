class DateOnly {
  static DateTime of(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime today() => of(DateTime.now());

  static String key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? parseKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (y == null || m == null || day == null) return null;
    return DateTime(y, m, day);
  }
}

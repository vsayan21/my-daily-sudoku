/// Computes a deterministic daily index based on the calendar date.
int selectDailyIndex({
  required DateTime date,
  required int length,
  DateTime? referenceDate,
}) {
  if (length <= 0) {
    throw ArgumentError('List length must be greater than zero.');
  }
  final anchor = referenceDate ?? DateTime(2026, 1, 28);
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedAnchor = DateTime(anchor.year, anchor.month, anchor.day);
  final offsetDays = normalizedDate.difference(normalizedAnchor).inDays;
  return offsetDays.modulo(length);
}

extension _Modulo on int {
  int modulo(int other) => ((this % other) + other) % other;
}

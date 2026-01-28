/// Returns the local date key formatted as YYYY-MM-DD.
String dailyKeyForDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Returns today's local date key formatted as YYYY-MM-DD.
String dailyKeyToday() => dailyKeyForDate(DateTime.now());

/// Builds the daily key formatted as YYYY-MM-DD using local time.
String buildDailyKeyLocal({DateTime? now}) {
  final date = now ?? DateTime.now();
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Builds the daily key formatted as YYYY-MM-DD using UTC time.
String buildDailyKeyUtc({DateTime? now}) {
  final date = (now ?? DateTime.now()).toUtc();
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

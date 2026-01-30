import 'package:shared_preferences/shared_preferences.dart';

import '../streak_keys.dart';

class StreakService {
  const StreakService(this._preferences);

  final SharedPreferences _preferences;

  Future<int> updateOnCompletion(String dateKey) async {
    final lastSolved = _preferences.getString(StreakKeys.lastSolvedDate);
    final todayKey = dateKey;
    final yesterdayKey = _yesterdayKey(dateKey);
    var streakCount = _preferences.getInt(StreakKeys.streakCount) ?? 0;

    if (lastSolved == todayKey) {
      await _preferences.setBool(StreakKeys.todaySolved, true);
      return streakCount;
    }

    if (lastSolved == yesterdayKey) {
      streakCount += 1;
    } else {
      streakCount = 1;
    }

    await _preferences.setInt(StreakKeys.streakCount, streakCount);
    await _preferences.setString(StreakKeys.lastSolvedDate, todayKey);
    await _preferences.setBool(StreakKeys.todaySolved, true);

    return streakCount;
  }

  String _yesterdayKey(String todayKey) {
    final parsed = DateTime.tryParse(todayKey);
    if (parsed == null) {
      return '';
    }
    final yesterday = DateTime(parsed.year, parsed.month, parsed.day)
        .subtract(const Duration(days: 1));
    return _formatDateKey(yesterday);
  }

  String _formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

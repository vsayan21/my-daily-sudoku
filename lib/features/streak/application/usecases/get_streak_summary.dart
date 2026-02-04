import 'package:shared_preferences/shared_preferences.dart';

import '../../../daily_sudoku/shared/daily_key.dart';
import '../../streak_keys.dart';

class StreakSummary {
  const StreakSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.todaySolved,
    this.lastCompletedDateKey,
  });

  final int currentStreak;
  final int longestStreak;
  final bool todaySolved;
  final String? lastCompletedDateKey;

  static const empty = StreakSummary(
    currentStreak: 0,
    longestStreak: 0,
    todaySolved: false,
  );
}

class GetStreakSummary {
  const GetStreakSummary({required SharedPreferences preferences})
      : _preferences = preferences;

  final SharedPreferences _preferences;

  Future<StreakSummary> execute() async {
    final todayKey = buildDailyKeyUtc();
    final localTodayKey = buildDailyKeyLocal();
    final lastCompleted = _preferences.getString(
          StreakKeys.lastCompletedDateKey,
        ) ??
        _preferences.getString(StreakKeys.lastSolvedDate);
    var todaySolved = _preferences.getBool(StreakKeys.todaySolved) ?? false;
    if (todaySolved &&
        lastCompleted != todayKey &&
        lastCompleted != localTodayKey) {
      await _preferences.setBool(StreakKeys.todaySolved, false);
      todaySolved = false;
    }
    final currentStreak = _preferences.getInt(StreakKeys.streakCount) ?? 0;
    final longestStreak =
        _preferences.getInt(StreakKeys.streakLongest) ?? currentStreak;
    return StreakSummary(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletedDateKey: lastCompleted,
      todaySolved: todaySolved,
    );
  }
}

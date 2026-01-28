import 'package:shared_preferences/shared_preferences.dart';

import '../streak_keys.dart';

class StreakLocalDataSource {
  const StreakLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  int readStreakCount() {
    return _preferences.getInt(StreakKeys.streakCount) ?? 0;
  }

  bool readTodaySolved() {
    return _preferences.getBool(StreakKeys.todaySolved) ?? false;
  }

  String? readLastSolvedDate() {
    return _preferences.getString(StreakKeys.lastSolvedDate);
  }
}

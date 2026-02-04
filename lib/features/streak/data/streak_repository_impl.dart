import 'package:shared_preferences/shared_preferences.dart';

import '../../daily_sudoku/shared/daily_key.dart';
import '../domain/streak_repository.dart';
import '../domain/streak_state.dart';
import 'streak_local_datasource.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._localDataSource);

  final StreakLocalDataSource _localDataSource;

  static Future<StreakRepositoryImpl> create() async {
    final preferences = await SharedPreferences.getInstance();
    return StreakRepositoryImpl(StreakLocalDataSource(preferences));
  }

  @override
  Future<StreakState> fetchStreakState() async {
    final todayKey = buildDailyKeyUtc();
    final lastSolved = _localDataSource.readLastSolvedDate();
    var todaySolved = _localDataSource.readTodaySolved();
    if (todaySolved && lastSolved != todayKey) {
      await _localDataSource.writeTodaySolved(false);
      todaySolved = false;
    }
    return StreakState(
      streakCount: _localDataSource.readStreakCount(),
      todaySolved: todaySolved,
      lastSolvedDate: lastSolved,
    );
  }
}

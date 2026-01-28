import 'package:shared_preferences/shared_preferences.dart';

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
    return StreakState(
      streakCount: _localDataSource.readStreakCount(),
      todaySolved: _localDataSource.readTodaySolved(),
      lastSolvedDate: _localDataSource.readLastSolvedDate(),
    );
  }
}

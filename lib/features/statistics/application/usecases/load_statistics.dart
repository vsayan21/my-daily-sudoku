import 'package:shared_preferences/shared_preferences.dart';

import '../../../streak/streak_keys.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/repositories/statistics_repository.dart';

class LoadStatisticsResult {
  const LoadStatisticsResult({
    required this.records,
    required this.currentStreak,
    required this.longestStreak,
  });

  final List<GameResult> records;
  final int currentStreak;
  final int longestStreak;
}

class LoadStatistics {
  const LoadStatistics({
    required StatisticsRepository repository,
    required SharedPreferences preferences,
  })  : _repository = repository,
        _preferences = preferences;

  final StatisticsRepository _repository;
  final SharedPreferences _preferences;

  Future<LoadStatisticsResult> call() async {
    final records = await _repository.listGameResults();
    final currentStreak =
        _preferences.getInt(StreakKeys.streakCount) ?? 0;
    final longestStreak =
        _preferences.getInt(StreakKeys.streakLongest) ?? currentStreak;

    return LoadStatisticsResult(
      records: records,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }
}

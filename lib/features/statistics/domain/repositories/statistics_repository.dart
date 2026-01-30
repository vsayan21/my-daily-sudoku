import '../entities/game_result.dart';

abstract class StatisticsRepository {
  Future<void> saveGameResult(GameResult result);

  Future<GameResult?> fetchGameResult({
    required String dateKey,
    required String difficultyKey,
  });

  Future<List<GameResult>> listGameResults();
}

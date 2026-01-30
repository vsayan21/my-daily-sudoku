import '../../domain/entities/game_result.dart';
import '../../domain/repositories/statistics_repository.dart';

class GetGameResultForDay {
  const GetGameResultForDay({required StatisticsRepository repository})
      : _repository = repository;

  final StatisticsRepository _repository;

  Future<GameResult?> execute({
    required String dateKey,
    required String difficultyKey,
  }) {
    return _repository.fetchGameResult(
      dateKey: dateKey,
      difficultyKey: difficultyKey,
    );
  }
}

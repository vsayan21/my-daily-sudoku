import '../../domain/entities/game_result.dart';
import '../../domain/repositories/statistics_repository.dart';

class ListGameResults {
  const ListGameResults({required StatisticsRepository repository})
      : _repository = repository;

  final StatisticsRepository _repository;

  Future<List<GameResult>> execute() {
    return _repository.listGameResults();
  }
}

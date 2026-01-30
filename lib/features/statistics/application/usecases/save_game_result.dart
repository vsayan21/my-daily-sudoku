import '../../domain/entities/game_result.dart';
import '../../domain/repositories/statistics_repository.dart';

class SaveGameResult {
  const SaveGameResult({required StatisticsRepository repository})
      : _repository = repository;

  final StatisticsRepository _repository;

  Future<void> execute(GameResult result) {
    return _repository.saveGameResult(result);
  }
}

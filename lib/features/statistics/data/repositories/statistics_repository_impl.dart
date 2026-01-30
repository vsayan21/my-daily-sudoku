import '../../domain/entities/game_result.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_local_datasource.dart';
import '../models/game_result_model.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({required StatisticsLocalDataSource dataSource})
      : _dataSource = dataSource;

  final StatisticsLocalDataSource _dataSource;

  @override
  Future<void> saveGameResult(GameResult result) {
    return _dataSource.persist(GameResultModel.fromEntity(result));
  }

  @override
  Future<GameResult?> fetchGameResult({
    required String dateKey,
    required String difficultyKey,
  }) async {
    return _dataSource.fetchOne(
      dateKey: dateKey,
      difficultyKey: difficultyKey,
    );
  }

  @override
  Future<List<GameResult>> listGameResults() async {
    return _dataSource.fetchAll().values.toList();
  }
}

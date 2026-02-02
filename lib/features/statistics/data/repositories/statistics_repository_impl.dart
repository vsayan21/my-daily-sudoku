import '../../../medals/domain/medal_calculator.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../shared/statistics_keys.dart';
import '../datasources/statistics_local_datasource.dart';
import '../models/game_result_model.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({required StatisticsLocalDataSource dataSource})
      : _dataSource = dataSource;

  final StatisticsLocalDataSource _dataSource;

  @override
  Future<void> saveGameResult(GameResult result) async {
    await _ensureMigrated();
    return _dataSource.persist(
      GameResultModel.fromEntity(result),
      recordsKey: StatisticsKeys.recordsV2,
    );
  }

  @override
  Future<GameResult?> fetchGameResult({
    required String dateKey,
    required String difficultyKey,
  }) async {
    await _ensureMigrated();
    return _dataSource.fetchOne(
      recordsKey: StatisticsKeys.recordsV2,
      dateKey: dateKey,
      difficultyKey: difficultyKey,
    );
  }

  @override
  Future<List<GameResult>> listGameResults() async {
    await _ensureMigrated();
    return _dataSource.fetchAll(recordsKey: StatisticsKeys.recordsV2).values
        .toList();
  }

  Future<void> _ensureMigrated() async {
    final current = _dataSource.fetchAll(recordsKey: StatisticsKeys.recordsV2);
    if (current.isNotEmpty) {
      return;
    }
    final legacy = _dataSource.fetchAll(recordsKey: StatisticsKeys.recordsV1);
    if (legacy.isEmpty) {
      return;
    }
    final calculator = MedalCalculator();
    final migrated = <String, GameResultModel>{};
    for (final entry in legacy.entries) {
      final record = entry.value;
      migrated[entry.key] = GameResultModel(
        dateKey: record.dateKey,
        difficulty: record.difficulty,
        completedAtEpochMs: record.completedAtEpochMs,
        elapsedSeconds: record.elapsedSeconds,
        hintsUsed: record.hintsUsed,
        movesCount: 0,
        undoCount: 0,
        medal: calculator.getMedal(record.difficulty, record.elapsedSeconds),
        resetsCount: record.resetsCount,
        appVersion: record.appVersion,
        deviceLocale: record.deviceLocale,
      );
    }
    await _dataSource.saveAll(
      migrated,
      recordsKey: StatisticsKeys.recordsV2,
    );
  }
}

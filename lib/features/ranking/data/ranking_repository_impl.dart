import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../domain/entities/ranking_entry.dart';
import '../domain/ranking_repository.dart';
import 'ranking_remote_datasource.dart';

class RankingRepositoryImpl implements RankingRepository {
  RankingRepositoryImpl({required RankingRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final RankingRemoteDataSource _dataSource;

  @override
  Future<List<RankingEntry>> fetchRanking({
    required String dateKey,
    required SudokuDifficulty difficulty,
    int limit = 100,
  }) {
    return _dataSource.fetchRanking(
      dateKey: dateKey,
      difficulty: difficulty,
      limit: limit,
    );
  }
}

import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import 'entities/ranking_entry.dart';

abstract class RankingRepository {
  Future<List<RankingEntry>> fetchRanking({
    required String dateKey,
    required SudokuDifficulty difficulty,
    int limit,
  });
}

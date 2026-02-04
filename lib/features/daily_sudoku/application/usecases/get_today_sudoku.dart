import '../../domain/entities/daily_sudoku.dart';
import '../../domain/entities/sudoku_difficulty.dart';
import '../../domain/repositories/daily_sudoku_repository.dart';
import '../../shared/daily_key.dart';
import '../../shared/daily_selector.dart';

/// Retrieves today's deterministic Sudoku puzzle for any difficulty.
class GetTodaySudoku {
  final DailySudokuRepository repository;
  final DateTime Function() nowProvider;

  /// Creates the use case.
  const GetTodaySudoku({
    required this.repository,
    this.nowProvider = DateTime.now,
  });

  /// Returns today's Sudoku puzzle for the given difficulty.
  Future<DailySudoku> execute(SudokuDifficulty difficulty) async {
    final puzzles = await repository.fetchPuzzles(difficulty);
    if (puzzles.isEmpty) {
      throw StateError('No ${difficulty.name} puzzles available.');
    }
    final now = nowProvider();
    final dailyKey = buildDailyKeyUtc(now: now);
    final index = selectDailyIndexUtc(date: now, length: puzzles.length);
    return puzzles[index].copyWith(
      dateKey: dailyKey,
      difficulty: difficulty,
    );
  }
}

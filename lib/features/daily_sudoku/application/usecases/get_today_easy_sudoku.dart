import '../../domain/entities/daily_sudoku.dart';
import '../../domain/repositories/daily_sudoku_repository.dart';
import '../../shared/daily_key.dart';
import '../../shared/stable_hash.dart';

/// Retrieves today's deterministic easy Sudoku puzzle.
class GetTodayEasySudoku {
  final DailySudokuRepository repository;
  final DateTime Function() nowProvider;

  /// Creates the use case.
  const GetTodayEasySudoku({
    required this.repository,
    this.nowProvider = DateTime.now,
  });

  /// Returns today's easy Sudoku puzzle.
  Future<DailySudoku> execute() async {
    final puzzles = await repository.fetchEasyPuzzles();
    if (puzzles.isEmpty) {
      throw StateError('No easy puzzles available.');
    }
    final key = dailyKeyForDate(nowProvider());
    final hash = stableHashFnv1a32(key);
    final index = (hash % puzzles.length).abs();
    return puzzles[index];
  }
}

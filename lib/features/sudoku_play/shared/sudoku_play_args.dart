import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

/// Navigation arguments for the Sudoku play screen.
class SudokuPlayArgs {
  /// Creates navigation arguments for the Sudoku play screen.
  const SudokuPlayArgs({
    required this.difficulty,
    required this.puzzleId,
    required this.puzzleString,
    required this.solutionString,
    required this.dailyKey,
  });

  /// Selected difficulty.
  final SudokuDifficulty difficulty;

  /// Puzzle identifier.
  final String puzzleId;

  /// 81-character puzzle string (0 = empty).
  final String puzzleString;

  /// 81-character solution string.
  final String solutionString;

  /// Daily key in YYYY-MM-DD format.
  final String dailyKey;
}

/// Supported Sudoku difficulty levels.
enum SudokuDifficulty {
  easy,
  medium,
  hard,
}

/// Navigation arguments for the Sudoku play screen.
class SudokuPlayArgs {
  /// Creates navigation arguments for the Sudoku play screen.
  const SudokuPlayArgs({
    required this.difficulty,
    required this.puzzleId,
    required this.puzzleString,
  });

  /// Selected difficulty.
  final SudokuDifficulty difficulty;

  /// Puzzle identifier.
  final String puzzleId;

  /// 81-character puzzle string (0 = empty).
  final String puzzleString;
}

/// Convenience helpers for difficulty display.
extension SudokuDifficultyLabel on SudokuDifficulty {
  /// Human-readable label for UI.
  String get label {
    switch (this) {
      case SudokuDifficulty.easy:
        return 'Easy';
      case SudokuDifficulty.medium:
        return 'Medium';
      case SudokuDifficulty.hard:
        return 'Hard';
    }
  }
}

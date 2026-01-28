/// Supported Sudoku difficulty levels.
enum SudokuDifficulty {
  easy,
  medium,
  hard,
}

/// Convenience helpers for display.
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

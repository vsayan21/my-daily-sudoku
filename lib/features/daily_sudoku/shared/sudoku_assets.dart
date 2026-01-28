import '../domain/entities/sudoku_difficulty.dart';

/// Asset paths for daily Sudoku data.
abstract class SudokuAssets {
  /// Returns the puzzle asset path for the given difficulty.
  static String pathForDifficulty(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return 'assets/sudoku/easy.json';
      case SudokuDifficulty.medium:
        return 'assets/sudoku/medium.json';
      case SudokuDifficulty.hard:
        return 'assets/sudoku/hard.json';
    }
  }
}

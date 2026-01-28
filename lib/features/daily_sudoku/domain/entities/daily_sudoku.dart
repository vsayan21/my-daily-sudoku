import 'sudoku_difficulty.dart';

/// Represents a daily Sudoku puzzle.
class DailySudoku {
  /// Unique identifier for the puzzle.
  final String id;

  /// 81-character string where 0 represents an empty cell.
  final String puzzle;

  /// 81-character solution string.
  final String solution;

  /// Difficulty for the daily Sudoku.
  final SudokuDifficulty difficulty;

  /// Date key in YYYY-MM-DD format.
  final String dateKey;

  /// Creates a [DailySudoku] entity.
  const DailySudoku({
    required this.id,
    required this.puzzle,
    required this.solution,
    required this.difficulty,
    required this.dateKey,
  });

  /// Returns a copy of this puzzle with updated fields.
  DailySudoku copyWith({
    String? id,
    String? puzzle,
    String? solution,
    SudokuDifficulty? difficulty,
    String? dateKey,
  }) {
    return DailySudoku(
      id: id ?? this.id,
      puzzle: puzzle ?? this.puzzle,
      solution: solution ?? this.solution,
      difficulty: difficulty ?? this.difficulty,
      dateKey: dateKey ?? this.dateKey,
    );
  }
}

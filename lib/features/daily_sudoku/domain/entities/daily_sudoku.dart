/// Represents a daily Sudoku puzzle.
class DailySudoku {
  /// Unique identifier for the puzzle.
  final String id;

  /// 81-character string where 0 represents an empty cell.
  final String puzzle;

  /// 81-character solution string.
  final String solution;

  /// Creates a [DailySudoku] entity.
  const DailySudoku({
    required this.id,
    required this.puzzle,
    required this.solution,
  });
}

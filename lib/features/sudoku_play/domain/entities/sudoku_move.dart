/// Represents a change made to a Sudoku cell.
class SudokuMove {
  /// Creates a record of a move.
  const SudokuMove({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
    required this.timestamp,
  });

  /// Row index of the move.
  final int row;

  /// Column index of the move.
  final int col;

  /// Value before the move.
  final int previousValue;

  /// Value after the move.
  final int newValue;

  /// When the move occurred.
  final DateTime timestamp;
}

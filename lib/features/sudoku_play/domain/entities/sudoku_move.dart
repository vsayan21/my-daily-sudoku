/// Represents a change made to a Sudoku cell.
class SudokuMove {
  /// Creates a record of a move.
  const SudokuMove({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
    required this.previousNotes,
    required this.newNotes,
    required this.timestamp,
  });

  /// Row index of the move.
  final int row;

  /// Column index of the move.
  final int col;

  /// Value before the move.
  final int? previousValue;

  /// Value after the move.
  final int? newValue;

  /// Notes before the move.
  final Set<int> previousNotes;

  /// Notes after the move.
  final Set<int> newNotes;

  /// When the move occurred.
  final DateTime timestamp;
}

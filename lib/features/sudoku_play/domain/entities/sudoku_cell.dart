/// Represents a single Sudoku cell value and its given status.
class SudokuCell {
  /// Creates a Sudoku cell with a current value and whether it is given.
  const SudokuCell({
    required this.value,
    required this.notes,
    required this.isGiven,
  });

  /// The current value of the cell. Null means empty.
  final int? value;

  /// Manual notes for the cell.
  final Set<int> notes;

  /// Whether the value is part of the original puzzle.
  final bool isGiven;

  /// Returns true when the cell value is empty.
  bool get isEmpty => value == null;
}

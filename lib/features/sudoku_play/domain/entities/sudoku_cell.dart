/// Represents a single Sudoku cell value and its given status.
class SudokuCell {
  /// Creates a Sudoku cell with a current value and whether it is given.
  const SudokuCell({
    required this.value,
    required this.isGiven,
  });

  /// The current value of the cell. Zero means empty.
  final int value;

  /// Whether the value is part of the original puzzle.
  final bool isGiven;

  /// Returns true when the cell value is empty.
  bool get isEmpty => value == 0;
}

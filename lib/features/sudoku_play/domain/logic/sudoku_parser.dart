import '../entities/sudoku_board.dart';

/// Parses Sudoku puzzle strings into board models.
class SudokuParser {
  /// Converts an 81-character puzzle string into a [SudokuBoard].
  SudokuBoard parse(String puzzle) {
    if (puzzle.length != 81) {
      throw ArgumentError('Puzzle string must be 81 characters long.');
    }
    final values = List.generate(9, (row) {
      return List.generate(9, (col) {
        final char = puzzle[row * 9 + col];
        final value = int.tryParse(char) ?? 0;
        return value;
      });
    });
    return SudokuBoard(initialValues: values);
  }
}

import '../entities/daily_sudoku.dart';

/// Repository contract for loading daily Sudoku puzzles.
abstract class DailySudokuRepository {
  /// Returns the list of available easy puzzles.
  Future<List<DailySudoku>> fetchEasyPuzzles();
}

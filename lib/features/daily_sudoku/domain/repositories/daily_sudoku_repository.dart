import '../entities/daily_sudoku.dart';
import '../entities/sudoku_difficulty.dart';

/// Repository contract for loading daily Sudoku puzzles.
abstract class DailySudokuRepository {
  /// Returns the list of available puzzles for the given difficulty.
  Future<List<DailySudoku>> fetchPuzzles(SudokuDifficulty difficulty);
}

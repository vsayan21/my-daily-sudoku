import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class SudokuSolvedDetails {
  const SudokuSolvedDetails({
    required this.dateKey,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.movesCount,
    required this.undoCount,
    required this.resetsCount,
  });

  final String dateKey;
  final SudokuDifficulty difficulty;
  final int elapsedSeconds;
  final int hintsUsed;
  final int movesCount;
  final int undoCount;
  final int resetsCount;
}

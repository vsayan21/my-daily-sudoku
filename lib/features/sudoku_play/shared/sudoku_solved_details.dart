import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class SudokuSolvedDetails {
  const SudokuSolvedDetails({
    required this.dateKey,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.pausesCount,
    required this.resetsCount,
  });

  final String dateKey;
  final SudokuDifficulty difficulty;
  final int elapsedSeconds;
  final int hintsUsed;
  final int pausesCount;
  final int resetsCount;
}

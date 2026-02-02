import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../medals/domain/medal.dart';

class GameResult {
  const GameResult({
    required this.dateKey,
    required this.difficulty,
    required this.completedAtEpochMs,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.movesCount,
    required this.undoCount,
    required this.medal,
    required this.resetsCount,
    this.appVersion,
    this.deviceLocale,
  });

  final String dateKey;
  final SudokuDifficulty difficulty;
  final int completedAtEpochMs;
  final int elapsedSeconds;
  final int hintsUsed;
  final int movesCount;
  final int undoCount;
  final Medal medal;
  final int resetsCount;
  final String? appVersion;
  final String? deviceLocale;
}

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class GameResult {
  const GameResult({
    required this.dateKey,
    required this.difficulty,
    required this.completedAtEpochMs,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.pausesCount,
    required this.resetsCount,
    this.appVersion,
    this.deviceLocale,
  });

  final String dateKey;
  final SudokuDifficulty difficulty;
  final int completedAtEpochMs;
  final int elapsedSeconds;
  final int hintsUsed;
  final int pausesCount;
  final int resetsCount;
  final String? appVersion;
  final String? deviceLocale;
}

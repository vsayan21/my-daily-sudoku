import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../domain/entities/game_result.dart';

class GameResultModel extends GameResult {
  const GameResultModel({
    required super.dateKey,
    required super.difficulty,
    required super.completedAtEpochMs,
    required super.elapsedSeconds,
    required super.hintsUsed,
    required super.pausesCount,
    required super.resetsCount,
    super.appVersion,
    super.deviceLocale,
  });

  factory GameResultModel.fromEntity(GameResult result) {
    return GameResultModel(
      dateKey: result.dateKey,
      difficulty: result.difficulty,
      completedAtEpochMs: result.completedAtEpochMs,
      elapsedSeconds: result.elapsedSeconds,
      hintsUsed: result.hintsUsed,
      pausesCount: result.pausesCount,
      resetsCount: result.resetsCount,
      appVersion: result.appVersion,
      deviceLocale: result.deviceLocale,
    );
  }

  factory GameResultModel.fromJson(Map<String, dynamic> json) {
    return GameResultModel(
      dateKey: json['dateKey'] as String? ?? '',
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      completedAtEpochMs: json['completedAtEpochMs'] as int? ?? 0,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      pausesCount: json['pausesCount'] as int? ?? 0,
      resetsCount: json['resetsCount'] as int? ?? 0,
      appVersion: json['appVersion'] as String?,
      deviceLocale: json['deviceLocale'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'difficulty': difficulty.name,
      'completedAtEpochMs': completedAtEpochMs,
      'elapsedSeconds': elapsedSeconds,
      'hintsUsed': hintsUsed,
      'pausesCount': pausesCount,
      'resetsCount': resetsCount,
      'appVersion': appVersion,
      'deviceLocale': deviceLocale,
    };
  }

  static SudokuDifficulty _parseDifficulty(String? raw) {
    switch (raw) {
      case 'easy':
        return SudokuDifficulty.easy;
      case 'medium':
        return SudokuDifficulty.medium;
      case 'hard':
        return SudokuDifficulty.hard;
      default:
        return SudokuDifficulty.easy;
    }
  }
}

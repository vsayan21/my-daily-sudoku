import '../../domain/entities/daily_sudoku.dart';
import '../../domain/entities/sudoku_difficulty.dart';

/// DTO for a daily Sudoku puzzle loaded from assets.
class DailySudokuModel {
  final String id;
  final String puzzle;
  final String solution;

  const DailySudokuModel({
    required this.id,
    required this.puzzle,
    required this.solution,
  });

  /// Creates a model from JSON.
  factory DailySudokuModel.fromJson(Map<String, dynamic> json) {
    return DailySudokuModel(
      id: json['id'] as String,
      puzzle: json['puzzle'] as String,
      solution: json['solution'] as String,
    );
  }

  /// Converts the model to a domain entity.
  DailySudoku toEntity({
    required SudokuDifficulty difficulty,
    required String dateKey,
  }) {
    return DailySudoku(
      id: id,
      puzzle: puzzle,
      solution: solution,
      difficulty: difficulty,
      dateKey: dateKey,
    );
  }
}

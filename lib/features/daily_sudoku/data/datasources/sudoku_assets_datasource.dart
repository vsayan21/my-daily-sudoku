import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/sudoku_difficulty.dart';
import '../../shared/sudoku_assets.dart';
import '../models/daily_sudoku_model.dart';

/// Loads Sudoku puzzles from bundled JSON assets.
class SudokuAssetsDataSource {
  /// Returns the list of puzzles from assets for the given difficulty.
  Future<List<DailySudokuModel>> loadPuzzles(SudokuDifficulty difficulty) async {
    final path = SudokuAssets.pathForDifficulty(difficulty);
    final jsonString = await rootBundle.loadString(path);
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      throw FormatException('${difficulty.label} puzzles JSON must be a list.');
    }
    return decoded
        .map((entry) => DailySudokuModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}

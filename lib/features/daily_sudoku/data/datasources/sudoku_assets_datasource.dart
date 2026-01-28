import 'dart:convert';

import 'package:flutter/services.dart';

import '../../daily_sudoku_assets.dart';
import '../models/daily_sudoku_model.dart';

/// Loads Sudoku puzzles from bundled JSON assets.
class SudokuAssetsDataSource {
  /// Returns the list of easy puzzles from assets.
  Future<List<DailySudokuModel>> loadEasyPuzzles() async {
    final jsonString = await rootBundle.loadString(DailySudokuAssets.easyPuzzles);
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      throw const FormatException('Easy puzzles JSON must be a list.');
    }
    return decoded
        .map((entry) => DailySudokuModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}

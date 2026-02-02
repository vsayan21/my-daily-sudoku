import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../medals/domain/medal.dart';
import '../domain/entities/game_result.dart';
import '../domain/entities/statistics_summary.dart';
import 'usecases/load_statistics.dart';

class StatisticsHistoryEntry {
  const StatisticsHistoryEntry({
    required this.dateKey,
    required this.results,
  });

  final String dateKey;
  final List<GameResult> results;
}

class StatisticsViewModel extends ChangeNotifier {
  StatisticsViewModel({required LoadStatistics loadStatistics})
      : _loadStatistics = loadStatistics;

  final LoadStatistics _loadStatistics;

  bool _isLoading = true;
  StatisticsSummary? _summary;
  List<StatisticsHistoryEntry> _history = const [];
  int _currentStreak = 0;
  int _longestStreak = 0;

  bool get isLoading => _isLoading;
  StatisticsSummary? get summary => _summary;
  List<StatisticsHistoryEntry> get history => _history;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final result = await _loadStatistics();
    final records = [...result.records]
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    _currentStreak = result.currentStreak;
    _longestStreak = result.longestStreak;
    _summary = _buildSummary(records);
    _history = _buildHistory(records);
    _isLoading = false;
    notifyListeners();
  }

  StatisticsSummary _buildSummary(List<GameResult> records) {
    final bestTimes = <SudokuDifficulty, int?>{
      SudokuDifficulty.easy: null,
      SudokuDifficulty.medium: null,
      SudokuDifficulty.hard: null,
    };
    var totalHints = 0;
    var totalMoves = 0;
    var totalUndo = 0;
    var goldMedals = 0;
    var silverMedals = 0;
    var bronzeMedals = 0;
    var totalTime = 0;

    for (final record in records) {
      totalHints += record.hintsUsed;
      totalMoves += record.movesCount;
      totalUndo += record.undoCount;
      totalTime += record.elapsedSeconds;

      final currentBest = bestTimes[record.difficulty];
      if (currentBest == null || record.elapsedSeconds < currentBest) {
        bestTimes[record.difficulty] = record.elapsedSeconds;
      }

      switch (record.medal) {
        case Medal.gold:
          goldMedals += 1;
          break;
        case Medal.silver:
          silverMedals += 1;
          break;
        case Medal.bronze:
          bronzeMedals += 1;
          break;
      }
    }

    final averageTimeSeconds = records.isEmpty
        ? null
        : totalTime / records.length;

    return StatisticsSummary(
      completedCount: records.length,
      bestTimesSeconds: UnmodifiableMapView(bestTimes),
      averageTimeSeconds: averageTimeSeconds,
      totalHints: totalHints,
      totalMoves: totalMoves,
      totalUndo: totalUndo,
      goldMedals: goldMedals,
      silverMedals: silverMedals,
      bronzeMedals: bronzeMedals,
    );
  }

  List<StatisticsHistoryEntry> _buildHistory(List<GameResult> records) {
    final grouped = <String, List<GameResult>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.dateKey, () => []).add(record);
    }

    final entries = grouped.entries.map((entry) {
      final results = [...entry.value]
        ..sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
      return StatisticsHistoryEntry(dateKey: entry.key, results: results);
    }).toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    return entries;
  }

  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static FontFeature tabularFigures() => const FontFeature.tabularFigures();

  static String difficultyLabel(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return 'Easy';
      case SudokuDifficulty.medium:
        return 'Medium';
      case SudokuDifficulty.hard:
        return 'Hard';
    }
  }
}

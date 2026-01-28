import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/sudoku_board.dart';
import '../../domain/logic/sudoku_conflict_checker.dart';
import '../services/game_timer.dart';

/// Controller for Sudoku play interactions.
class SudokuPlayController extends ChangeNotifier {
  /// Creates a controller with the given board.
  SudokuPlayController({
    required SudokuBoard board,
  })  : _board = board,
        _conflicts = SudokuConflictChecker().findConflicts(board.currentValues) {
    _gameTimer.addListener(_handleTimerTick);
    _gameTimer.start();
  }

  SudokuBoard _board;
  SudokuPosition? _selectedCell;
  Set<SudokuPosition> _conflicts;
  final GameTimer _gameTimer = GameTimer();
  bool _isPaused = false;
  bool _isManuallyPaused = false;
  int _mistakesCount = 0;
  int _penaltySecondsLast = 0;
  DateTime? _penaltyEndsAt;
  Timer? _penaltyTimer;

  /// Current Sudoku board state.
  SudokuBoard get board => _board;

  /// Currently selected cell position.
  SudokuPosition? get selectedCell => _selectedCell;

  /// Cells that are currently in conflict.
  Set<SudokuPosition> get conflicts => _conflicts;

  /// Whether the game is currently paused.
  bool get isPaused => _isPaused;

  /// Current formatted time (mm:ss).
  String get formattedTime => _formatDuration(_gameTimer.elapsedSeconds);

  /// Number of mistakes made in the current game.
  int get mistakesCount => _mistakesCount;

  /// Whether the penalty animation should be visible.
  bool get showPenalty =>
      _penaltyEndsAt != null && DateTime.now().isBefore(_penaltyEndsAt!);

  /// Last applied penalty seconds.
  int get penaltySecondsLast => _penaltySecondsLast;

  /// Selects a cell by row and column.
  void selectCell(int row, int col) {
    if (_isPaused) {
      return;
    }
    _selectedCell = (row: row, col: col);
    notifyListeners();
  }

  /// Inputs a value into the selected cell.
  void inputValue(int value) {
    if (_isPaused) {
      return;
    }
    final selection = _selectedCell;
    if (selection == null) {
      return;
    }
    if (!_board.isEditable(selection.row, selection.col)) {
      return;
    }
    _board = _board.setValue(selection.row, selection.col, value);
    _recomputeConflicts();
    if (value != 0 && _conflicts.contains(selection)) {
      _applyPenalty(5);
    }
    notifyListeners();
  }

  /// Clears the selected cell.
  void erase() => inputValue(0);

  /// Toggles pause state from user action.
  void togglePause() {
    if (_isPaused) {
      resume(manual: true);
    } else {
      pause(manual: true);
    }
  }

  /// Pauses the game timer.
  void pause({bool manual = false}) {
    if (_isPaused) {
      return;
    }
    _isPaused = true;
    if (manual) {
      _isManuallyPaused = true;
    }
    _gameTimer.pause();
    notifyListeners();
  }

  /// Resumes the game timer.
  void resume({bool manual = false}) {
    if (!_isPaused) {
      return;
    }
    if (manual) {
      _isManuallyPaused = false;
    }
    _isPaused = false;
    _gameTimer.resume();
    notifyListeners();
  }

  /// Handles app lifecycle changes to pause/resume automatically.
  void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isManuallyPaused) {
          resume();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pause();
        break;
    }
  }

  @override
  void dispose() {
    _gameTimer.removeListener(_handleTimerTick);
    _gameTimer.dispose();
    _penaltyTimer?.cancel();
    super.dispose();
  }

  void _handleTimerTick() {
    notifyListeners();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  void _recomputeConflicts() {
    _conflicts = SudokuConflictChecker().findConflicts(_board.currentValues);
  }

  void _applyPenalty(int seconds) {
    if (seconds <= 0 || _isPaused) {
      return;
    }
    _gameTimer.addPenalty(seconds);
    _mistakesCount++;
    _penaltySecondsLast = seconds;
    _penaltyEndsAt = DateTime.now().add(const Duration(seconds: 1));
    _penaltyTimer?.cancel();
    _penaltyTimer = Timer(const Duration(seconds: 1), notifyListeners);
    HapticFeedback.lightImpact();
  }
}

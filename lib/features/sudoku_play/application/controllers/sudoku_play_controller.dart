import 'package:flutter/material.dart';

import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../domain/entities/sudoku_board.dart';
import '../services/game_timer.dart';

/// Controller for Sudoku play interactions.
class SudokuPlayController extends ChangeNotifier {
  /// Creates a controller with the given board.
  SudokuPlayController({
    required SudokuBoard board,
    required SudokuDifficulty difficulty,
    required String dateKey,
    required String puzzleId,
    required String puzzleString,
  })  : _board = board,
        _difficulty = difficulty,
        _dateKey = dateKey,
        _puzzleId = puzzleId,
        _puzzleString = puzzleString {
    _gameTimer.addListener(_handleTimerTick);
    _gameTimer.start();
  }

  SudokuBoard _board;
  SudokuDifficulty _difficulty;
  String _dateKey;
  String _puzzleId;
  String _puzzleString;
  SudokuPosition? _selectedCell;
  final GameTimer _gameTimer = GameTimer();
  bool _isPaused = false;
  bool _isManuallyPaused = false;

  /// Current Sudoku board state.
  SudokuBoard get board => _board;

  /// Currently selected cell position.
  SudokuPosition? get selectedCell => _selectedCell;

  /// Whether the game is currently paused.
  bool get isPaused => _isPaused;

  /// Current formatted time (mm:ss).
  String get formattedTime => _formatDuration(_gameTimer.elapsedSeconds);

  /// Builds a session snapshot for persistence.
  ActiveGameSession exportSession() {
    return ActiveGameSession(
      difficulty: _difficulty,
      dateKey: _dateKey,
      puzzleId: _puzzleId,
      puzzle: _puzzleString,
      current: _gridToString(_board.currentValues),
      givens: _puzzleString,
      elapsedSeconds: _gameTimer.elapsedSeconds,
      isPaused: _isPaused,
      lastUpdatedEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Restores the controller from a saved session.
  void restoreFromSession(ActiveGameSession session) {
    _difficulty = session.difficulty;
    _dateKey = session.dateKey;
    _puzzleId = session.puzzleId ?? _puzzleId;
    _puzzleString = session.puzzle;
    _board = SudokuBoard(
      initialValues: _stringToGrid(session.puzzle),
      currentValues: _stringToGrid(session.current),
    );
    _selectedCell = null;
    _isManuallyPaused = false;
    _isPaused = false;
    _gameTimer.startFrom(session.elapsedSeconds);
    if (session.isPaused) {
      pause();
    }
    notifyListeners();
  }

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
    super.dispose();
  }

  void _handleTimerTick() {
    notifyListeners();
  }

  String _gridToString(List<List<int>> values) {
    final buffer = StringBuffer();
    for (final row in values) {
      for (final cell in row) {
        buffer.write(cell.toString());
      }
    }
    return buffer.toString();
  }

  List<List<int>> _stringToGrid(String value) {
    if (value.length != 81) {
      throw ArgumentError('Puzzle string must be 81 characters long.');
    }
    return List.generate(9, (row) {
      return List.generate(9, (col) {
        final char = value[row * 9 + col];
        final parsed = int.tryParse(char);
        return parsed ?? 0;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

}

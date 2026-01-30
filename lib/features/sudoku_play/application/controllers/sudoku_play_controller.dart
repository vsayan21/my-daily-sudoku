import 'package:flutter/material.dart';

import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../hints/application/hint_controller.dart';
import '../../../hints/domain/hint_result.dart';
import '../../../hints/domain/hint_service.dart';
import '../../domain/entities/sudoku_board.dart';
import '../../domain/entities/sudoku_move.dart';
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
    required String solutionString,
  })  : _board = board,
        _difficulty = difficulty,
        _dateKey = dateKey,
        _puzzleId = puzzleId,
        _puzzleString = puzzleString,
        _solutionString = solutionString,
        _hintController = HintController.create() {
    _gameTimer.addListener(_handleTimerTick);
    _gameTimer.start();
  }

  SudokuBoard _board;
  SudokuDifficulty _difficulty;
  String _dateKey;
  String _puzzleId;
  String _puzzleString;
  String _solutionString;
  final HintController _hintController;
  SudokuPosition? _selectedCell;
  final GameTimer _gameTimer = GameTimer();
  bool _isPaused = false;
  bool _isManuallyPaused = false;
  final List<SudokuMove> _history = [];
  final Set<SudokuPosition> _hintedCells = {};
  Set<SudokuPosition> _transientHighlightedCells = {};
  bool _isHintBusy = false;
  int _hintPenaltySeconds = 0;
  int _penaltyToken = 0;
  String? _inlineHintMessage;
  int _inlineHintToken = 0;

  /// Current Sudoku board state.
  SudokuBoard get board => _board;

  /// Currently selected cell position.
  SudokuPosition? get selectedCell => _selectedCell;

  /// Whether the game is currently paused.
  bool get isPaused => _isPaused;

  /// Whether the hint flow is running.
  bool get isHintBusy => _isHintBusy;

  /// Cells temporarily highlighted for conflicts.
  Set<SudokuPosition> get transientHighlightedCells =>
      _transientHighlightedCells;

  /// Cells filled by hints.
  Set<SudokuPosition> get hintedCells => _hintedCells;

  /// Latest hint penalty label to display.
  String? get hintPenaltyLabel =>
      _hintPenaltySeconds > 0 ? '+$_hintPenaltySeconds sec' : null;

  /// Inline hint message shown below the action bar.
  String? get inlineHintMessage => _inlineHintMessage;

  /// Whether there is a move available to undo.
  bool get canUndo => _history.isNotEmpty;

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
      hinted: _hintedToString(_hintedCells),
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
    _history.clear();
    _isManuallyPaused = false;
    _isPaused = false;
    _hintedCells.clear();
    _hintedCells.addAll(_stringToHinted(session.hinted));
    _transientHighlightedCells = {};
    _gameTimer.startFrom(session.elapsedSeconds);
    if (session.isPaused) {
      pause();
    }
    notifyListeners();
  }

  /// Selects a cell by row and column.
  void selectCell(int row, int col) {
    if (_isPaused) {
      resume(manual: true);
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
    if (_hintedCells.contains(selection)) {
      return;
    }
    final previousValue = _board.currentValues[selection.row][selection.col];
    if (previousValue == value) {
      return;
    }
    _board = _board.setValue(selection.row, selection.col, value);
    _history.add(
      SudokuMove(
        row: selection.row,
        col: selection.col,
        previousValue: previousValue,
        newValue: value,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Clears the selected cell.
  void erase() => inputValue(0);

  /// Reverts the most recent move.
  void undo() {
    if (_history.isEmpty) {
      return;
    }
    final lastMove = _history.removeLast();
    _board = _board.setValue(
      lastMove.row,
      lastMove.col,
      lastMove.previousValue,
    );
    _selectedCell = (row: lastMove.row, col: lastMove.col);
    notifyListeners();
  }

  Future<void> onHintPressed() async {
    if (_isPaused || _isHintBusy) {
      return;
    }
    _isHintBusy = true;
    notifyListeners();

    final selection = _selectedCell;
    final action = await _hintController.requestHint(
      board: _board,
      solution: _solutionString,
      dateKey: _dateKey,
      selected: selection == null
          ? null
          : HintSelection(
              position: selection,
              isEditable: _board.isEditable(selection.row, selection.col) &&
                  !_hintedCells.contains(selection),
              isEmpty: _board.currentValues[selection.row][selection.col] == 0,
            ),
    );
    await _applyHintAction(action);
  }

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

  String _hintedToString(Set<SudokuPosition> hinted) {
    final buffer = StringBuffer();
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        buffer.write(hinted.contains((row: row, col: col)) ? '1' : '0');
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

  Set<SudokuPosition> _stringToHinted(String value) {
    if (value.length != 81) {
      return {};
    }
    final hinted = <SudokuPosition>{};
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final char = value[row * 9 + col];
        if (char == '1') {
          hinted.add((row: row, col: col));
        }
      }
    }
    return hinted;
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  void _showHintPenalty(int seconds) {
    if (seconds <= 0) {
      return;
    }
    _hintPenaltySeconds = seconds;
    _penaltyToken += 1;
    final token = _penaltyToken;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (token != _penaltyToken) {
        return;
      }
      _hintPenaltySeconds = 0;
      notifyListeners();
    });
  }

  void _applyHintPenalty() {
    _gameTimer.addPenaltySeconds(5);
    _showHintPenalty(5);
  }

  Future<void> _applyHintAction(HintAction action) async {
    switch (action.result) {
      case HintResult.revealedConflicts:
        _transientHighlightedCells = action.conflicts;
        _selectedCell = action.selectedPosition ?? _selectedCell;
        _applyHintPenalty();
        if (action.message != null) {
          showInlineHint(action.message!);
        }
        notifyListeners();
        await Future<void>.delayed(const Duration(milliseconds: 2500));
        _transientHighlightedCells = {};
        _isHintBusy = false;
        notifyListeners();
        break;
      case HintResult.filledCell:
        final position = action.filledPosition;
        final value = action.filledValue;
        if (position != null && value != null) {
          _board = _board.setValue(position.row, position.col, value);
          _hintedCells.add(position);
          _selectedCell = action.selectedPosition ??
              (row: position.row, col: position.col);
        }
        _applyHintPenalty();
        if (action.message != null) {
          showInlineHint(action.message!);
        }
        _isHintBusy = false;
        notifyListeners();
        break;
      case HintResult.noOp:
        if (action.message != null) {
          showInlineHint(action.message!);
        }
        _isHintBusy = false;
        notifyListeners();
        break;
    }
  }

  /// Shows an inline hint message for a short duration.
  void showInlineHint(String message) {
    _inlineHintMessage = message;
    _inlineHintToken += 1;
    final token = _inlineHintToken;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (token != _inlineHintToken) {
        return;
      }
      _inlineHintMessage = null;
      notifyListeners();
    });
  }
}

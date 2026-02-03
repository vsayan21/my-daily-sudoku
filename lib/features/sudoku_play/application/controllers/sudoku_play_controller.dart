import 'dart:async';

import 'package:flutter/material.dart';
import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../hints/application/hint_controller.dart';
import '../../../hints/domain/hint_message.dart';
import '../../../hints/domain/hint_result.dart';
import '../../../hints/domain/hint_service.dart';
import '../../domain/entities/sudoku_board.dart';
import '../../domain/entities/sudoku_move.dart';
import '../../shared/sudoku_solved_details.dart';
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
    this.onSolved,
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
  final String _solutionString;
  final HintController _hintController;
  final ValueChanged<SudokuSolvedDetails>? onSolved;
  SudokuPosition? _selectedCell;
  final GameTimer _gameTimer = GameTimer();
  bool _isPaused = false;
  bool _isManuallyPaused = false;
  bool _isCompleted = false;
  bool _hasNotifiedSolved = false;
  bool _notesMode = false;
  int _hintsUsed = 0;
  int _movesCount = 0;
  int _undoCount = 0;
  final List<SudokuMove> _history = [];
  final Set<SudokuPosition> _hintedCells = {};
  Set<SudokuPosition> _transientHighlightedCells = {};
  bool _isHintBusy = false;
  int _hintPenaltySeconds = 0;
  int _penaltyToken = 0;
  HintMessage? _inlineHintMessage;
  int _inlineHintToken = 0;
  bool _isDisposed = false;
  Timer? _hintPenaltyTimer;
  Timer? _inlineHintTimer;

  /// Current Sudoku board state.
  SudokuBoard get board => _board;

  /// Currently selected cell position.
  SudokuPosition? get selectedCell => _selectedCell;

  /// Whether the game is currently paused.
  bool get isPaused => _isPaused;

  /// Whether the hint flow is running.
  bool get isHintBusy => _isHintBusy;

  /// Whether notes mode is enabled.
  bool get notesMode => _notesMode;

  /// Cells temporarily highlighted for conflicts.
  Set<SudokuPosition> get transientHighlightedCells =>
      _transientHighlightedCells;

  /// Cells filled by hints.
  Set<SudokuPosition> get hintedCells => _hintedCells;

  /// Latest hint penalty seconds to display.
  int? get hintPenaltySeconds =>
      _hintPenaltySeconds > 0 ? _hintPenaltySeconds : null;

  /// Inline hint message shown below the action bar.
  HintMessage? get inlineHintMessage => _inlineHintMessage;

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
      notes: _notesToString(_board.notes),
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
      initialValues: _stringToFixedGrid(session.puzzle),
      currentValues: _stringToGrid(session.current),
      notes: _stringToNotes(session.notes),
    );
    _selectedCell = null;
    _history.clear();
    _isManuallyPaused = false;
    _isPaused = false;
    _isCompleted = false;
    _hasNotifiedSolved = false;
    _notesMode = false;
    _hintsUsed = 0;
    _movesCount = 0;
    _undoCount = 0;
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
    if (_isCompleted) {
      return;
    }
    if (_isPaused) {
      resume(manual: true);
    }
    _selectedCell = (row: row, col: col);
    notifyListeners();
  }

  /// Inputs a value into the selected cell.
  void inputValue(int value) {
    if (_isCompleted) {
      return;
    }
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
    final cell = _board.cellAt(selection.row, selection.col);
    final previousValue = cell.value;
    final previousNotes = cell.notes;
    final Set<int> newNotes;
    final int? newValue;
    if (_notesMode) {
      newValue = null;
      newNotes = Set<int>.from(previousNotes);
      if (newNotes.contains(value)) {
        newNotes.remove(value);
      } else {
        newNotes.add(value);
      }
    } else {
      newValue = value;
      newNotes = <int>{};
    }
    if (previousValue == newValue &&
        _setsEqual(previousNotes, newNotes)) {
      return;
    }
    _movesCount += 1;
    _board = _board.setCell(
      row: selection.row,
      col: selection.col,
      value: newValue,
      notes: newNotes,
    );
    _history.add(
      SudokuMove(
        row: selection.row,
        col: selection.col,
        previousValue: previousValue,
        newValue: newValue,
        previousNotes: previousNotes,
        newNotes: newNotes,
        timestamp: DateTime.now(),
      ),
    );
    _notifySafely();
    _checkSolved();
  }

  /// Clears the selected cell.
  void erase() {
    if (_isCompleted) {
      return;
    }
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
    final cell = _board.cellAt(selection.row, selection.col);
    final previousValue = cell.value;
    final previousNotes = cell.notes;
    final int? newValue;
    final Set<int> newNotes;
    if (cell.value != null) {
      newValue = null;
      newNotes = previousNotes;
    } else {
      newValue = null;
      newNotes = <int>{};
    }
    if (previousValue == newValue &&
        _setsEqual(previousNotes, newNotes)) {
      return;
    }
    _movesCount += 1;
    _board = _board.setCell(
      row: selection.row,
      col: selection.col,
      value: newValue,
      notes: newNotes,
    );
    _history.add(
      SudokuMove(
        row: selection.row,
        col: selection.col,
        previousValue: previousValue,
        newValue: newValue,
        previousNotes: previousNotes,
        newNotes: newNotes,
        timestamp: DateTime.now(),
      ),
    );
    _notifySafely();
    _checkSolved();
  }

  /// Reverts the most recent move.
  void undo() {
    if (_isCompleted) {
      return;
    }
    if (_history.isEmpty) {
      return;
    }
    _undoCount += 1;
    final lastMove = _history.removeLast();
    _board = _board.setCell(
      row: lastMove.row,
      col: lastMove.col,
      value: lastMove.previousValue,
      notes: lastMove.previousNotes,
    );
    _selectedCell = (row: lastMove.row, col: lastMove.col);
    _notifySafely();
    _checkSolved();
  }

  /// Toggles the notes entry mode.
  void toggleNotesMode() {
    if (_isCompleted) {
      return;
    }
    if (_isPaused) {
      return;
    }
    _notesMode = !_notesMode;
    notifyListeners();
  }

  Future<void> onHintPressed() async {
    if (_isCompleted) {
      return;
    }
    if (_isPaused || _isHintBusy) {
      return;
    }
    _isHintBusy = true;
    notifyListeners();

    final selection = _selectedCell;
    final selectionSnapshot = selection == null
        ? null
        : HintSelection(
            position: selection,
            isEditable: _board.isEditable(selection.row, selection.col) &&
                !_hintedCells.contains(selection),
            isEmpty: _board.cellAt(selection.row, selection.col).isEmpty,
          );
    final action = await _hintController.requestHint(
      board: _board,
      solution: _solutionString,
      selected: selectionSnapshot,
    );
    await _applyHintAction(action);
  }

  /// Toggles pause state from user action.
  void togglePause() {
    if (_isCompleted) {
      return;
    }
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

  /// Resets the game state back to the original puzzle.
  Future<void> resetGame() async {
    _board = SudokuBoard(
      initialValues: _stringToFixedGrid(_puzzleString),
    );
    _selectedCell = null;
    _history.clear();
    _hintedCells.clear();
    _transientHighlightedCells = {};
    _notesMode = false;
    _isHintBusy = false;
    _hintPenaltySeconds = 0;
    _penaltyToken += 1;
    _inlineHintMessage = null;
    _inlineHintToken += 1;
    _hintPenaltyTimer?.cancel();
    _inlineHintTimer?.cancel();
    _hintPenaltyTimer = null;
    _inlineHintTimer = null;
    _hintsUsed = 0;
    _movesCount = 0;
    _undoCount = 0;
    _isCompleted = false;
    _hasNotifiedSolved = false;
    _isPaused = false;
    _isManuallyPaused = false;
    _gameTimer.startFrom(0);
    _notifySafely();
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
    _isDisposed = true;
    _hintPenaltyTimer?.cancel();
    _inlineHintTimer?.cancel();
    _gameTimer.removeListener(_handleTimerTick);
    _gameTimer.dispose();
    super.dispose();
  }

  void _handleTimerTick() {
    notifyListeners();
  }

  String _gridToString(List<List<int?>> values) {
    final buffer = StringBuffer();
    for (final row in values) {
      for (final cell in row) {
        buffer.write((cell ?? 0).toString());
      }
    }
    return buffer.toString();
  }

  String _notesToString(List<List<Set<int>>> values) {
    final buffer = StringBuffer();
    var index = 0;
    for (final row in values) {
      for (final cell in row) {
        final mask = _notesToMask(cell);
        if (index > 0) {
          buffer.write(',');
        }
        buffer.write(mask.toString());
        index += 1;
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

  List<List<int?>> _stringToGrid(String value) {
    if (value.length != 81) {
      throw ArgumentError('Puzzle string must be 81 characters long.');
    }
    return List.generate(9, (row) {
      return List.generate(9, (col) {
        final char = value[row * 9 + col];
        final parsed = int.tryParse(char);
        return parsed == null || parsed == 0 ? null : parsed;
      });
    });
  }

  List<List<int>> _stringToFixedGrid(String value) {
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

  List<List<Set<int>>> _stringToNotes(String value) {
    final emptyNotes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    if (value.isEmpty) {
      return emptyNotes;
    }
    final parts = value.split(',');
    if (parts.length != 81) {
      return emptyNotes;
    }
    var index = 0;
    return List.generate(9, (row) {
      return List.generate(9, (col) {
        final raw = parts[index];
        index += 1;
        final parsed = int.tryParse(raw) ?? 0;
        return _maskToNotes(parsed);
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

  int _notesToMask(Set<int> notes) {
    var mask = 0;
    for (final note in notes) {
      if (note < 1 || note > 9) {
        continue;
      }
      mask |= 1 << (note - 1);
    }
    return mask;
  }

  Set<int> _maskToNotes(int mask) {
    final notes = <int>{};
    for (var value = 1; value <= 9; value++) {
      if ((mask & (1 << (value - 1))) != 0) {
        notes.add(value);
      }
    }
    return notes;
  }

  bool _setsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  void _checkSolved() {
    if (_isCompleted || _hasNotifiedSolved) {
      return;
    }
    if (!_isBoardSolved()) {
      return;
    }
    _isCompleted = true;
    _gameTimer.pause();
    final handler = onSolved;
    if (handler == null) {
      return;
    }
    _hasNotifiedSolved = true;
    handler(
      SudokuSolvedDetails(
        dateKey: _dateKey,
        difficulty: _difficulty,
        elapsedSeconds: _gameTimer.elapsedSeconds,
        hintsUsed: _hintsUsed,
        movesCount: _movesCount,
        undoCount: _undoCount,
        resetsCount: 0,
      ),
    );
  }

  bool _isBoardSolved() {
    var index = 0;
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final value = _board.currentValues[row][col];
        if (value == null) {
          return false;
        }
        if (index >= _solutionString.length) {
          return false;
        }
        final solutionValue = int.tryParse(_solutionString[index]) ?? 0;
        if (value != solutionValue) {
          return false;
        }
        index += 1;
      }
    }
    return index == _solutionString.length;
  }

  void _showHintPenalty(int seconds) {
    if (seconds <= 0) {
      return;
    }
    _hintPenaltySeconds = seconds;
    _penaltyToken += 1;
    final token = _penaltyToken;
    _notifySafely();
    _hintPenaltyTimer?.cancel();
    _hintPenaltyTimer = Timer(const Duration(seconds: 2), () {
      if (token != _penaltyToken) {
        return;
      }
      _hintPenaltySeconds = 0;
      _notifySafely();
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
        _hintsUsed += 1;
        _applyHintPenalty();
        if (action.message != null) {
          showInlineHint(action.message!);
        }
        _notifySafely();
        await Future<void>.delayed(const Duration(milliseconds: 2500));
        _transientHighlightedCells = {};
        _isHintBusy = false;
        _notifySafely();
        break;
      case HintResult.filledCell:
        final position = action.filledPosition;
        final value = action.filledValue;
        if (position != null && value != null) {
          _board = _board.setCell(
            row: position.row,
            col: position.col,
            value: value,
            notes: <int>{},
          );
          _hintedCells.add(position);
          _selectedCell = action.selectedPosition ??
              (row: position.row, col: position.col);
        }
        _hintsUsed += 1;
        _applyHintPenalty();
        if (action.message != null) {
          showInlineHint(action.message!);
        }
        _isHintBusy = false;
        _notifySafely();
        _checkSolved();
        break;
      case HintResult.noOp:
        if (action.message != null) {
          showInlineHint(action.message!);
        }
        _isHintBusy = false;
        _notifySafely();
        break;
    }
  }

  /// Shows an inline hint message for a short duration.
  void showInlineHint(HintMessage message) {
    _inlineHintMessage = message;
    _inlineHintToken += 1;
    final token = _inlineHintToken;
    _notifySafely();
    _inlineHintTimer?.cancel();
    _inlineHintTimer = Timer(const Duration(seconds: 2), () {
      if (token != _inlineHintToken) {
        return;
      }
      _inlineHintMessage = null;
      _notifySafely();
    });
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }
}

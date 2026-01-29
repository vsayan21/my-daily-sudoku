import 'package:flutter/material.dart';

import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../hints/application/hint_controller.dart';
import '../../../hints/domain/hint_result.dart';
import '../../../hints/presentation/hint_feedback_overlay.dart';
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
  final Future<HintController> _hintController;
  SudokuPosition? _selectedCell;
  final GameTimer _gameTimer = GameTimer();
  bool _isPaused = false;
  bool _isManuallyPaused = false;
  final List<SudokuMove> _history = [];
  final Set<SudokuPosition> _hintedCells = {};
  Set<SudokuPosition> _transientHighlightedCells = {};
  bool _isHintBusy = false;

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

  /// Placeholder hint handler.
  Future<void> onHintPressed(BuildContext context) async {
    if (_isPaused || _isHintBusy) {
      return;
    }
    _isHintBusy = true;
    notifyListeners();

    final hintController = await _hintController;
    var action = await hintController.requestHint(
      board: _board,
      solution: _solutionString,
      dateKey: _dateKey,
    );

    if (action.result == HintResult.blockedNeedsAd) {
      _isHintBusy = false;
      notifyListeners();
      final shouldWatchAd = await _showHintAdPrompt(context);
      if (!shouldWatchAd || _isPaused) {
        return;
      }
      _isHintBusy = true;
      notifyListeners();
      action = await hintController.requestHint(
        board: _board,
        solution: _solutionString,
        dateKey: _dateKey,
        fromAd: true,
      );
    }

    await _applyHintAction(context, action);
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

  Future<void> _applyHintAction(
    BuildContext context,
    HintAction action,
  ) async {
    switch (action.result) {
      case HintResult.revealedConflicts:
        _transientHighlightedCells = action.conflicts;
        notifyListeners();
        if (action.message != null) {
          HintFeedbackOverlay.showMessage(context, action.message!);
        }
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
        }
        if (action.message != null) {
          HintFeedbackOverlay.showMessage(context, action.message!);
        }
        _isHintBusy = false;
        notifyListeners();
        break;
      case HintResult.noOp:
        if (action.message != null) {
          HintFeedbackOverlay.showMessage(context, action.message!);
        }
        _isHintBusy = false;
        notifyListeners();
        break;
      case HintResult.blockedNeedsAd:
        _isHintBusy = false;
        notifyListeners();
        break;
    }
  }

  Future<bool> _showHintAdPrompt(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Need another hint?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Watch Ad to get 1 hint'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }
}

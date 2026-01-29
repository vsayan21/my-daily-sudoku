import '../../sudoku_play/domain/entities/sudoku_board.dart';
import '../logic/sudoku_conflict_finder.dart';
import '../logic/sudoku_hint_picker.dart';
import 'hint_result.dart';

/// A domain-level action that describes a hint response.
class HintAction {
  /// Creates a hint action.
  const HintAction({
    required this.result,
    this.conflicts = const {},
    this.filledPosition,
    this.filledValue,
    this.message,
  });

  /// Outcome of the hint request.
  final HintResult result;

  /// Conflicting cell positions, when applicable.
  final Set<SudokuPosition> conflicts;

  /// Filled cell position when a hint fills a cell.
  final SudokuPosition? filledPosition;

  /// Value filled into the hinted cell.
  final int? filledValue;

  /// Optional message to display to the user.
  final String? message;
}

/// Contract for hint generation services.
abstract class HintService {
  /// Returns the next hint action for the given board state.
  HintAction requestHint({
    required SudokuBoard board,
    required String solution,
  });
}

/// Default implementation for hint generation.
class DefaultHintService implements HintService {
  /// Creates a hint service.
  DefaultHintService({
    SudokuConflictFinder? conflictFinder,
    SudokuHintPicker? hintPicker,
  })  : _conflictFinder = conflictFinder ?? SudokuConflictFinder(),
        _hintPicker = hintPicker ?? SudokuHintPicker();

  final SudokuConflictFinder _conflictFinder;
  final SudokuHintPicker _hintPicker;

  @override
  HintAction requestHint({
    required SudokuBoard board,
    required String solution,
  }) {
    final conflicts = _conflictFinder.findConflicts(board.currentValues);
    if (conflicts.isNotEmpty) {
      return HintAction(
        result: HintResult.revealedConflicts,
        conflicts: conflicts,
        message: 'Conflicts found',
      );
    }

    final pick = _hintPicker.pickFirstEmpty(
      board: board,
      solution: solution,
    );
    if (pick == null) {
      return const HintAction(
        result: HintResult.noOp,
        message: 'No empty cells',
      );
    }

    return HintAction(
      result: HintResult.filledCell,
      filledPosition: (row: pick.row, col: pick.col),
      filledValue: pick.value,
      message: 'Hint used',
    );
  }
}

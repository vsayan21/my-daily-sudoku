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
    this.selectedPosition,
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

  /// Selected cell position to focus in the UI.
  final SudokuPosition? selectedPosition;

  /// Optional message to display to the user.
  final String? message;
}

/// Details about a selected cell for hint targeting.
class HintSelection {
  /// Creates a selection snapshot.
  const HintSelection({
    required this.position,
    required this.isEditable,
    required this.isEmpty,
  });

  /// Selected cell position.
  final SudokuPosition position;

  /// Whether the cell is editable (not a given or locked hint).
  final bool isEditable;

  /// Whether the cell is empty.
  final bool isEmpty;
}

/// Contract for hint generation services.
abstract class HintService {
  /// Returns the next hint action for the given board state.
  HintAction requestHint({
    required SudokuBoard board,
    required String solution,
    HintSelection? selected,
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
    HintSelection? selected,
  }) {
    final conflicts = _conflictFinder.findConflicts(board.currentValues);
    if (conflicts.isNotEmpty) {
      final selectedConflict = _pickTopLeft(conflicts);
      return HintAction(
        result: HintResult.revealedConflicts,
        conflicts: conflicts,
        selectedPosition: selectedConflict,
        message: 'Conflicts found',
      );
    }

    if (selected != null) {
      if (!selected.isEditable) {
        return const HintAction(
          result: HintResult.noOp,
          message: 'Select an empty cell',
        );
      }
      if (!selected.isEmpty) {
        return const HintAction(
          result: HintResult.noOp,
          message: 'Clear the cell or select an empty one.',
        );
      }
    }

    final pick = _hintPicker.pickTarget(
      board: board,
      solution: solution,
      selected: selected?.position,
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
      selectedPosition: (row: pick.row, col: pick.col),
    );
  }

  SudokuPosition? _pickTopLeft(Set<SudokuPosition> conflicts) {
    if (conflicts.isEmpty) {
      return null;
    }
    return conflicts.reduce((current, next) {
      if (next.row < current.row) {
        return next;
      }
      if (next.row == current.row && next.col < current.col) {
        return next;
      }
      return current;
    });
  }
}

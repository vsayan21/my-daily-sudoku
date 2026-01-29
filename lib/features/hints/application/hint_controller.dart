import '../../sudoku_play/domain/entities/sudoku_board.dart';
import '../domain/hint_result.dart';
import '../domain/hint_service.dart';

/// Coordinates hint quota checks and hint generation.
class HintController {
  /// Creates a hint controller.
  HintController({
    required HintService hintService,
  }) : _hintService = hintService;

  final HintService _hintService;

  /// Builds a controller using default implementations.
  static HintController create() {
    return HintController(
      hintService: DefaultHintService(),
    );
  }

  /// Attempts to use a hint.
  Future<HintAction> requestHint({
    required SudokuBoard board,
    required String solution,
  }) async {
    if (!_isValidSolution(solution)) {
      return const HintAction(
        result: HintResult.noOp,
        message: 'Solution unavailable',
      );
    }

    final action = _hintService.requestHint(
      board: board,
      solution: solution,
    );

    return action;
  }

  bool _isValidSolution(String solution) {
    if (solution.length != 81) {
      return false;
    }
    return !RegExp(r'[^0-9]').hasMatch(solution);
  }
}

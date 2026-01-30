import '../../sudoku_play/domain/entities/sudoku_board.dart';
import '../data/hint_quota_store.dart';
import '../domain/hint_result.dart';
import '../domain/hint_service.dart';

/// Coordinates hint quota checks and hint generation.
class HintController {
  /// Creates a hint controller.
  HintController({
    required HintService hintService,
    HintQuotaStore? quotaStore,
  })  : _hintService = hintService,
        _quotaStore = quotaStore ?? HintQuotaStore();

  final HintService _hintService;
  final HintQuotaStore _quotaStore;

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
    required String dateKey,
    HintSelection? selected,
    bool fromAd = false,
  }) async {
    if (!_isValidSolution(solution)) {
      return const HintAction(
        result: HintResult.noOp,
        message: 'Solution unavailable',
      );
    }

    final quota = await _quotaStore.loadQuota(dateKey);
    if (!fromAd && quota.usedCount >= 1) {
      return const HintAction(
        result: HintResult.noOp,
        message: 'Need another hint?',
      );
    }
    if (fromAd && quota.adUsed) {
      return const HintAction(
        result: HintResult.noOp,
        message: 'No more ad hints today',
      );
    }

    final action = _hintService.requestHint(
      board: board,
      solution: solution,
      selected: selected,
    );

    if (action.result != HintResult.noOp) {
      await _quotaStore.recordHintUse(
        dateKey: dateKey,
        fromAd: fromAd,
      );
    }

    return action;
  }

  bool _isValidSolution(String solution) {
    if (solution.length != 81) {
      return false;
    }
    return !RegExp(r'[^0-9]').hasMatch(solution);
  }
}

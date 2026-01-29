import 'package:shared_preferences/shared_preferences.dart';

import '../../sudoku_play/domain/entities/sudoku_board.dart';
import '../data/hint_quota_store.dart';
import '../domain/hint_result.dart';
import '../domain/hint_service.dart';

/// Coordinates hint quota checks and hint generation.
class HintController {
  /// Creates a hint controller.
  HintController({
    required HintService hintService,
    required HintQuotaStore quotaStore,
  })  : _hintService = hintService,
        _quotaStore = quotaStore;

  final HintService _hintService;
  final HintQuotaStore _quotaStore;

  /// Builds a controller using shared preferences.
  static Future<HintController> create() async {
    final preferences = await SharedPreferences.getInstance();
    return HintController(
      hintService: DefaultHintService(),
      quotaStore: HintQuotaStore(preferences),
    );
  }

  /// Attempts to use a hint, respecting daily quota rules.
  Future<HintAction> requestHint({
    required SudokuBoard board,
    required String solution,
    required String dateKey,
    bool fromAd = false,
  }) async {
    if (!fromAd) {
      final count = await _quotaStore.getHintCount(dateKey);
      if (count >= 1) {
        return const HintAction(result: HintResult.blockedNeedsAd);
      }
    }

    if (!_isValidSolution(solution)) {
      return const HintAction(
        result: HintResult.noOp,
        message: 'Solution unavailable',
      );
    }

    if (fromAd) {
      await _quotaStore.incrementHintCount(dateKey);
    }

    final action = _hintService.requestHint(
      board: board,
      solution: solution,
    );

    if (!fromAd &&
        (action.result == HintResult.revealedConflicts ||
            action.result == HintResult.filledCell)) {
      await _quotaStore.incrementHintCount(dateKey);
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

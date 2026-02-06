import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../active_game/application/usecases/clear_active_game.dart';
import '../../../active_game/application/usecases/save_active_game.dart';
import '../../../active_game/data/datasources/active_game_local_datasource.dart';
import '../../../active_game/data/repositories/active_game_repository_impl.dart';
import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../completion/presentation/screens/success_screen.dart';
import '../../../completion/shared/success_screen_args.dart';
import '../../../firebase/firebase_sync_service.dart';
import '../../../medals/domain/medal_calculator.dart';
import '../../../statistics/application/usecases/save_game_result.dart';
import '../../../statistics/data/datasources/statistics_local_datasource.dart';
import '../../../statistics/data/repositories/statistics_repository_impl.dart';
import '../../../statistics/domain/entities/game_result.dart';
import '../../../streak/application/streak_service.dart';
import '../../application/controllers/sudoku_play_controller.dart';
import '../../../hints/domain/hint_message.dart';
import '../../domain/logic/sudoku_parser.dart';
import '../../shared/sudoku_play_args.dart';
import '../../shared/sudoku_solved_details.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/sudoku_number_row.dart';
import '../widgets/sudoku_pause_overlay.dart';
import '../widgets/inline_hint_message.dart';
import '../widgets/sudoku_action_bar.dart';
import '../widgets/sudoku_timer_bar.dart';
import '../widgets/sudoku_top_bar.dart';
import '../../../shared/presentation/widgets/sudoku_loading_widget.dart';

/// Screen for playing a Sudoku puzzle.
class SudokuPlayScreen extends StatefulWidget {
  /// Creates a Sudoku play screen.
  const SudokuPlayScreen({
    super.key,
    required this.args,
    required this.dependencies,
    this.initialSession,
  });

  /// Navigation arguments.
  final SudokuPlayArgs args;
  final AppDependencies dependencies;
  final ActiveGameSession? initialSession;

  @override
  State<SudokuPlayScreen> createState() => _SudokuPlayScreenState();
}

class _SudokuPlayScreenState extends State<SudokuPlayScreen>
    with WidgetsBindingObserver {
  late final SudokuPlayController _controller;
  late final Future<SaveActiveGame> _saveActiveGame;
  late final Future<_CompletionServices> _completionServices;
  bool _isCompleting = false;

  static const double _horizontalPadding = 8;
  static const double _spacingMedium = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final board = SudokuParser().parse(widget.args.puzzleString);
    _controller = SudokuPlayController(
      board: board,
      difficulty: widget.args.difficulty,
      dateKey: widget.args.dailyKey,
      puzzleId: widget.args.puzzleId,
      puzzleString: widget.args.puzzleString,
      solutionString: widget.args.solutionString,
      onSolved: _handleSolved,
    );
    final session = widget.initialSession;
    if (session != null) {
      _controller.restoreFromSession(session);
    }
    _saveActiveGame = _buildSaveActiveGame();
    _completionServices = _buildCompletionServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.handleAppLifecycleState(state);
  }

  Future<SaveActiveGame> _buildSaveActiveGame() async {
    final preferences = await SharedPreferences.getInstance();
    final repository = ActiveGameRepositoryImpl(
      dataSource: ActiveGameLocalDataSource(preferences),
    );
    return SaveActiveGame(repository: repository);
  }

  Future<_CompletionServices> _buildCompletionServices() async {
    final preferences = await SharedPreferences.getInstance();
    final activeGameRepository = ActiveGameRepositoryImpl(
      dataSource: ActiveGameLocalDataSource(preferences),
    );
    final statisticsRepository = StatisticsRepositoryImpl(
      dataSource: StatisticsLocalDataSource(preferences),
    );
    return _CompletionServices(
      clearActiveGame: ClearActiveGame(repository: activeGameRepository),
      saveGameResult: SaveGameResult(repository: statisticsRepository),
      streakService: StreakService(preferences),
    );
  }

  Future<bool> _handleWillPop() async {
    if (_isCompleting) {
      return true;
    }
    _controller.pause();
    final session = _controller.exportSession();
    final saver = await _saveActiveGame;
    await saver.execute(session);
    return true;
  }

  Future<void> _handleSolved(SudokuSolvedDetails details) async {
    if (_isCompleting) {
      return;
    }
    setState(() => _isCompleting = true);
    final loc = AppLocalizations.of(context)!;
    final syncService = await widget.dependencies.firebaseSyncService;
    final services = await _completionServices;
    final completedAtEpochMs = DateTime.now().millisecondsSinceEpoch;
    final locale =
        mounted ? Localizations.localeOf(context).toLanguageTag() : null;
    final medal = const MedalCalculator()
        .getMedal(details.difficulty, details.elapsedSeconds);
    final result = GameResult(
      dateKey: details.dateKey,
      difficulty: details.difficulty,
      completedAtEpochMs: completedAtEpochMs,
      elapsedSeconds: details.elapsedSeconds,
      hintsUsed: details.hintsUsed,
      movesCount: details.movesCount,
      undoCount: details.undoCount,
      medal: medal,
      resetsCount: details.resetsCount,
      deviceLocale: locale,
    );
    await services.saveGameResult.execute(result);
    try {
      await syncService.ensureUserProfileExistsAndSynced(
        locale: locale,
      );
      await syncService.uploadAllLocalResults();
    } catch (error, stackTrace) {
      debugPrint('Firebase upload failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (_isOfflineError(error)) {
        _showOfflineNotice(loc);
      }
      _scheduleUploadRetry(syncService, locale);
    }
    final streakCount = await services.streakService
        .updateOnCompletion(details.dateKey);
    await services.clearActiveGame.execute();
    if (!mounted) {
      return;
    }
    final navigationResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          args: SuccessScreenArgs(
            dateKey: details.dateKey,
            difficulty: details.difficulty,
            elapsedSeconds: details.elapsedSeconds,
            hintsUsed: details.hintsUsed,
            movesCount: details.movesCount,
            undoCount: details.undoCount,
            medal: medal,
            streakCount: streakCount,
          ),
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(navigationResult);
  }

  Future<void> _handleBack() async {
    final shouldPop = await _handleWillPop();
    if (!mounted || !shouldPop) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _scheduleUploadRetry(
    FirebaseSyncService syncService,
    String? locale,
  ) {
    unawaited(_retryUpload(syncService, locale));
  }

  bool _isOfflineError(Object error) {
    if (error is SocketException) {
      return true;
    }
    if (error is FirebaseException) {
      final code = error.code.toLowerCase();
      return code == 'network-request-failed' || code == 'unavailable';
    }
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('network') ||
        message.contains('connection');
  }

  void _showOfflineNotice(AppLocalizations loc) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.offlineSyncNotice),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _retryUpload(
    FirebaseSyncService syncService,
    String? locale, {
    int attempts = 2,
  }) async {
    const delay = Duration(seconds: 30);
    for (var attempt = 1; attempt <= attempts; attempt += 1) {
      await Future.delayed(delay * attempt);
      try {
        await syncService.ensureUserProfileExistsAndSynced(
          locale: locale,
        );
        await syncService.uploadAllLocalResults();
        return;
      } catch (error, stackTrace) {
        debugPrint('Firebase retry $attempt failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> _handleReset() async {
    if (_isCompleting) {
      return;
    }
    final loc = AppLocalizations.of(context)!;
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.restartGameTitle),
        content: Text(loc.restartGameMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.restartGameConfirm),
          ),
        ],
      ),
    );
    if (!mounted || shouldReset != true) {
      return;
    }
    await _controller.resetGame();
    final saver = await _saveActiveGame;
    await saver.execute(_controller.exportSession());
  }

  String? _localizedHintMessage(AppLocalizations loc, HintMessage? message) {
    switch (message) {
      case HintMessage.solutionUnavailable:
        return loc.hintSolutionUnavailable;
      case HintMessage.conflictsFound:
        return loc.hintConflictsFound;
      case HintMessage.selectEmptyCell:
        return loc.hintSelectEmptyCell;
      case HintMessage.clearCellOrSelectEmpty:
        return loc.hintClearCellOrSelectEmpty;
      case HintMessage.noEmptyCells:
        return loc.hintNoEmptyCells;
      case null:
        return null;
    }
  }

  String? _localizedHintPenalty(AppLocalizations loc, int? seconds) {
    if (seconds == null) {
      return null;
    }
    return loc.hintPenaltyLabel(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          final navigator = Navigator.of(context);
          final shouldPop = await _handleWillPop();
          if (!mounted || !shouldPop) {
            return;
          }
          navigator.pop();
        },
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final selectedCell = _controller.selectedCell;
                  final selectedValue = selectedCell == null
                      ? null
                      : _controller
                          .board
                          .cellAt(selectedCell.row, selectedCell.col)
                          .value;
                  return Column(
                    children: [
                      SudokuTopBar(
                        difficulty: widget.args.difficulty,
                        dailyKey: widget.args.dailyKey,
                        onBack: _handleBack,
                        isPaused: _controller.isPaused,
                        onPauseToggle: _controller.togglePause,
                        onReset: _handleReset,
                      ),
                      SudokuTimerBar(
                        formattedTime: _controller.formattedTime,
                        penaltyText: _localizedHintPenalty(
                          loc,
                          _controller.hintPenaltySeconds,
                        ),
                      ),
                      const SizedBox(height: _spacingMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _horizontalPadding,
                        ),
                        child: SudokuActionBar(
                          onHintPressed:
                              _controller.isPaused || _controller.isHintBusy
                                  ? null
                                  : _controller.onHintPressed,
                          onNotesPressed: _controller.isPaused
                              ? null
                              : _controller.toggleNotesMode,
                          onErasePressed:
                              _controller.isPaused ? null : _controller.erase,
                          onUndoPressed:
                              _controller.isPaused || !_controller.canUndo
                                  ? null
                                  : _controller.undo,
                          isNotesMode: _controller.notesMode,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _horizontalPadding,
                        ),
                        child: InlineHintMessage(
                          message: _localizedHintMessage(
                            loc,
                            _controller.inlineHintMessage,
                          ),
                        ),
                      ),
                      const SizedBox(height: _spacingMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _horizontalPadding,
                        ),
                        child: Stack(
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _controller.isPaused ? 0.6 : 1,
                              child: SudokuGrid(
                                board: _controller.board,
                                selectedCell: _controller.selectedCell,
                                hintedCells: _controller.hintedCells,
                                transientHighlightedCells:
                                    _controller.transientHighlightedCells,
                                onCellTap: _controller.selectCell,
                              ),
                            ),
                            if (_controller.isPaused)
                              const Positioned.fill(
                                child: IgnorePointer(
                                  child: SudokuPauseOverlay(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: _spacingMedium),
                      SudokuNumberRow(
                        onNumberSelected: _controller.inputValue,
                        isPaused: _controller.isPaused,
                        selectedValue: selectedValue,
                      ),
                    ],
                  );
                },
              ),
              if (_isCompleting)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: const SudokuLoadingWidget(
                        label: '',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionServices {
  const _CompletionServices({
    required this.clearActiveGame,
    required this.saveGameResult,
    required this.streakService,
  });

  final ClearActiveGame clearActiveGame;
  final SaveGameResult saveGameResult;
  final StreakService streakService;
}

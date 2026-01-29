import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../active_game/application/usecases/save_active_game.dart';
import '../../../active_game/data/datasources/active_game_local_datasource.dart';
import '../../../active_game/data/repositories/active_game_repository_impl.dart';
import '../../../active_game/domain/entities/active_game_session.dart';
import '../../application/controllers/sudoku_play_controller.dart';
import '../../domain/logic/sudoku_parser.dart';
import '../../shared/sudoku_play_args.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/sudoku_number_row.dart';
import '../widgets/sudoku_pause_overlay.dart';
import '../widgets/sudoku_action_bar.dart';
import '../widgets/sudoku_timer_bar.dart';
import '../widgets/sudoku_top_bar.dart';

/// Screen for playing a Sudoku puzzle.
class SudokuPlayScreen extends StatefulWidget {
  /// Creates a Sudoku play screen.
  const SudokuPlayScreen({
    super.key,
    required this.args,
    this.initialSession,
  });

  /// Navigation arguments.
  final SudokuPlayArgs args;
  final ActiveGameSession? initialSession;

  @override
  State<SudokuPlayScreen> createState() => _SudokuPlayScreenState();
}

class _SudokuPlayScreenState extends State<SudokuPlayScreen>
    with WidgetsBindingObserver {
  late final SudokuPlayController _controller;
  late final Future<SaveActiveGame> _saveActiveGame;

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
    );
    final session = widget.initialSession;
    if (session != null) {
      _controller.restoreFromSession(session);
    }
    _saveActiveGame = _buildSaveActiveGame();
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

  Future<bool> _handleWillPop() async {
    _controller.pause();
    final session = _controller.exportSession();
    final saver = await _saveActiveGame;
    await saver.execute(session);
    return true;
  }

  Future<void> _handleBack() async {
    final shouldPop = await _handleWillPop();
    if (!mounted || !shouldPop) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final selectedCell = _controller.selectedCell;
            final selectedValue = selectedCell == null
                ? null
                : _controller.board.currentValues[selectedCell.row]
                    [selectedCell.col];
            return Column(
              children: [
                SudokuTopBar(
                  difficulty: widget.args.difficulty,
                  dailyKey: widget.args.dailyKey,
                  onBack: _handleBack,
                  isPaused: _controller.isPaused,
                  onPauseToggle: _controller.togglePause,
                ),
                SudokuTimerBar(
                  formattedTime: _controller.formattedTime,
                ),
                const SizedBox(height: _spacingMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                  ),
                  child: SudokuActionBar(
                    onHintPressed: _controller.isPaused || _controller.isHintBusy
                        ? null
                        : () => _controller.onHintPressed(context),
                    onErasePressed:
                        _controller.isPaused ? null : _controller.erase,
                    onUndoPressed: _controller.isPaused || !_controller.canUndo
                        ? null
                        : _controller.undo,
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
        ),
      ),
    );
  }
}

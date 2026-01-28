import 'package:flutter/material.dart';

import '../../application/controllers/sudoku_play_controller.dart';
import '../../domain/logic/sudoku_parser.dart';
import '../../shared/sudoku_play_args.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/sudoku_number_pad.dart';
import '../widgets/sudoku_pause_overlay.dart';
import '../widgets/sudoku_timer_bar.dart';
import '../widgets/sudoku_top_bar.dart';

/// Screen for playing a Sudoku puzzle.
class SudokuPlayScreen extends StatefulWidget {
  /// Creates a Sudoku play screen.
  const SudokuPlayScreen({
    super.key,
    required this.args,
  });

  /// Navigation arguments.
  final SudokuPlayArgs args;

  @override
  State<SudokuPlayScreen> createState() => _SudokuPlayScreenState();
}

class _SudokuPlayScreenState extends State<SudokuPlayScreen>
    with WidgetsBindingObserver {
  late final SudokuPlayController _controller;

  static const double _horizontalPadding = 16;
  static const double _spacingSmall = 12;
  static const double _spacingMedium = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final board = SudokuParser().parse(widget.args.puzzleString);
    _controller = SudokuPlayController(board: board);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                SudokuTopBar(
                  difficulty: widget.args.difficulty,
                  dailyKey: widget.args.dailyKey,
                  onBack: () => Navigator.of(context).pop(),
                  isPaused: _controller.isPaused,
                  onPauseToggle: _controller.togglePause,
                ),
                SudokuTimerBar(formattedTime: _controller.formattedTime),
                const SizedBox(height: _spacingMedium),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _horizontalPadding,
                      ),
                      child: Stack(
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _controller.isPaused ? 0.6 : 1,
                            child: IgnorePointer(
                              ignoring: _controller.isPaused,
                              child: SudokuGrid(
                                board: _controller.board,
                                selectedCell: _controller.selectedCell,
                                conflicts: _controller.conflicts,
                                onCellTap: _controller.selectCell,
                              ),
                            ),
                          ),
                          if (_controller.isPaused)
                            const Positioned.fill(
                              child: SudokuPauseOverlay(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: _controller.isPaused,
                  child: SudokuNumberPad(
                    onNumberSelected: _controller.inputValue,
                    onErase: _controller.erase,
                  ),
                ),
                const SizedBox(height: _spacingSmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

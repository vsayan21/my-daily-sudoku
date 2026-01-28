import 'package:flutter/material.dart';

import '../../application/controllers/sudoku_play_controller.dart';
import '../../domain/logic/sudoku_parser.dart';
import '../../shared/sudoku_play_args.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/sudoku_number_pad.dart';
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

class _SudokuPlayScreenState extends State<SudokuPlayScreen> {
  late final SudokuPlayController _controller;

  @override
  void initState() {
    super.initState();
    final board = SudokuParser().parse(widget.args.puzzleString);
    _controller = SudokuPlayController(board: board);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  puzzleId: widget.args.puzzleId,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SudokuGrid(
                        board: _controller.board,
                        selectedCell: _controller.selectedCell,
                        conflicts: _controller.conflicts,
                        onCellTap: _controller.selectCell,
                      ),
                    ),
                  ),
                ),
                SudokuNumberPad(
                  onNumberSelected: _controller.inputValue,
                  onErase: _controller.erase,
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}

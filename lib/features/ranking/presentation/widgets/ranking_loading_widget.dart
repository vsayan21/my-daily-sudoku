import 'dart:math' as math;

import 'package:flutter/material.dart';

class RankingLoadingWidget extends StatefulWidget {
  const RankingLoadingWidget({super.key});

  @override
  State<RankingLoadingWidget> createState() => _RankingLoadingWidgetState();
}

class _RankingLoadingWidgetState extends State<RankingLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return _SudokuJumpGrid(
                t: _controller.value,
                color: colorScheme.primary,
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Ranking is loading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SudokuJumpGrid extends StatelessWidget {
  const _SudokuJumpGrid({
    required this.t,
    required this.color,
  });

  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const int size = 3;
    const double cell = 12;
    const double gap = 6;
    const double amplitude = 6;
    const double phaseStep = 0.35;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < size; row += 1)
          Padding(
            padding: EdgeInsets.only(bottom: row == size - 1 ? 0 : gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var col = 0; col < size; col += 1)
                  Padding(
                    padding:
                        EdgeInsets.only(right: col == size - 1 ? 0 : gap),
                    child: _JumpingCell(
                      t: t,
                      phase: (row * size + col) * phaseStep,
                      size: cell,
                      amplitude: amplitude,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _JumpingCell extends StatelessWidget {
  const _JumpingCell({
    required this.t,
    required this.phase,
    required this.size,
    required this.amplitude,
    required this.color,
  });

  final double t;
  final double phase;
  final double size;
  final double amplitude;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final y = math.sin((t * 2 * math.pi) + phase) * amplitude;
    return Transform.translate(
      offset: Offset(0, -y.abs()),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 204),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

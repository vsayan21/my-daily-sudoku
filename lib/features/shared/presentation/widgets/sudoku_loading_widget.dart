import 'dart:math' as math;

import 'package:flutter/material.dart';

class SudokuLoadingWidget extends StatefulWidget {
  const SudokuLoadingWidget({
    super.key,
    required this.label,
    this.size = 12,
    this.gap = 6,
    this.amplitude = 6,
    this.duration = const Duration(milliseconds: 1800),
  });

  final String label;
  final double size;
  final double gap;
  final double amplitude;
  final Duration duration;

  @override
  State<SudokuLoadingWidget> createState() => _SudokuLoadingWidgetState();
}

class _SudokuLoadingWidgetState extends State<SudokuLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
                size: widget.size,
                gap: widget.gap,
                amplitude: widget.amplitude,
              );
            },
          ),
          if (widget.label.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SudokuJumpGrid extends StatelessWidget {
  const _SudokuJumpGrid({
    required this.t,
    required this.color,
    required this.size,
    required this.gap,
    required this.amplitude,
  });

  final double t;
  final Color color;
  final double size;
  final double gap;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    const int gridSize = 3;
    const double phaseStep = 0.35;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < gridSize; row += 1)
          Padding(
            padding:
                EdgeInsets.only(bottom: row == gridSize - 1 ? 0 : gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var col = 0; col < gridSize; col += 1)
                  Padding(
                    padding: EdgeInsets.only(
                      right: col == gridSize - 1 ? 0 : gap,
                    ),
                    child: _JumpingCell(
                      t: t,
                      phase: (row * gridSize + col) * phaseStep,
                      size: size,
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

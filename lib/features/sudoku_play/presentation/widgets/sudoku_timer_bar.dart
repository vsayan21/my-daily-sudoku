import 'package:flutter/material.dart';

/// Timer bar for the Sudoku play screen.
class SudokuTimerBar extends StatelessWidget {
  /// Creates a timer bar.
  const SudokuTimerBar({
    super.key,
    required this.formattedTime,
  });

  /// Formatted timer text.
  final String formattedTime;

  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 8;
  static const double _containerRadius = 16;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(_containerRadius),
        ),
        child: Text(
          formattedTime,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

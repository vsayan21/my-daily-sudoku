import 'package:flutter/material.dart';

/// Timer bar for the Sudoku play screen.
class SudokuTimerBar extends StatelessWidget {
  /// Creates a timer bar.
  const SudokuTimerBar({
    super.key,
    required this.formattedTime,
    required this.showPenalty,
    required this.penaltySecondsLast,
  });

  /// Formatted timer text.
  final String formattedTime;

  /// Whether to show the penalty animation.
  final bool showPenalty;

  /// Last penalty seconds to display.
  final int penaltySecondsLast;

  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 8;
  static const double _containerRadius = 16;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final penaltyColor = colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: AnimatedContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(_containerRadius),
          border: showPenalty
              ? Border.all(color: penaltyColor.withValues(alpha: 0.6))
              : null,
          boxShadow: showPenalty
              ? [
                  BoxShadow(
                    color: penaltyColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        duration: _animationDuration,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              formattedTime,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: colorScheme.onSurface,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedScale(
                scale: showPenalty ? 1 : 0.9,
                duration: _animationDuration,
                child: AnimatedOpacity(
                  opacity: showPenalty ? 1 : 0,
                  duration: _animationDuration,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: penaltyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${penaltySecondsLast}s',
                      style: textTheme.labelLarge?.copyWith(
                        color: penaltyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

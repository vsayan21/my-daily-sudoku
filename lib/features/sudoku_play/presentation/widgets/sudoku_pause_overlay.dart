import 'package:flutter/material.dart';

/// Overlay displayed when the game is paused.
class SudokuPauseOverlay extends StatelessWidget {
  /// Creates a pause overlay.
  const SudokuPauseOverlay({super.key});

  static const double _overlayOpacity = 0.3;
  static const double _labelPadding = 12;
  static const double _labelRadius = 16;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: Colors.black.withValues(alpha: _overlayOpacity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _labelPadding * 1.5,
            vertical: _labelPadding,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(_labelRadius),
          ),
          child: Text(
            'Paused',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

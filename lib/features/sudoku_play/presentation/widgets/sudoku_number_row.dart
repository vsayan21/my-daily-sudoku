import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Number row for Sudoku input.
class SudokuNumberRow extends StatelessWidget {
  /// Creates a Sudoku number row.
  const SudokuNumberRow({
    super.key,
    required this.onNumberSelected,
    required this.isPaused,
    this.selectedValue,
  });

  /// Called when a number is selected.
  final ValueChanged<int> onNumberSelected;

  /// Whether the game is paused.
  final bool isPaused;

  /// Currently selected value, if any.
  final int? selectedValue;

  static const double _horizontalPadding = 12;
  static const double _spacing = 8;
  static const double _buttonSize = 56;
  static const double _minTapSize = 48;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final buttonSize = math.min(_buttonSize, maxWidth / 9);
          final totalButtonWidth = buttonSize * 9;
          final remainingSpace = (maxWidth - totalButtonWidth).clamp(0, maxWidth);
          final spacing = math.min(_spacing, remainingSpace / 8);
          final children = <Widget>[];
          for (var index = 0; index < 9; index++) {
            final number = index + 1;
            children.add(
              SizedBox.square(
                dimension: buttonSize,
                child: _NumberButton(
                  label: number.toString(),
                  isSelected: selectedValue == number,
                  onPressed: isPaused ? null : () => onNumberSelected(number),
                ),
              ),
            );
            if (index < 8) {
              children.add(SizedBox(width: spacing));
            }
          }

          return Row(children: children);
        },
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainer;
    final selectedOverlay = colorScheme.primary.withValues(alpha: 0.12);
    final backgroundColor = isSelected
        ? Color.alphaBlend(selectedOverlay, baseColor)
        : baseColor;

    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(SudokuNumberRow._minTapSize, SudokuNumberRow._minTapSize),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: const WidgetStatePropertyAll(CircleBorder()),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return backgroundColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          return colorScheme.onSurface;
        }),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: const WidgetStatePropertyAll(0),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

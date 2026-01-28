import 'package:flutter/material.dart';

/// Renders a single Sudoku cell with selection and conflict styling.
class SudokuCellWidget extends StatelessWidget {
  /// Creates a Sudoku cell widget.
  const SudokuCellWidget({
    super.key,
    required this.value,
    required this.isGiven,
    required this.isSelected,
    required this.isHighlighted,
    required this.isConflict,
    required this.border,
    required this.onTap,
  });

  /// Current value of the cell.
  final int value;

  /// Whether the cell is a given.
  final bool isGiven;

  /// Whether this cell is selected.
  final bool isSelected;

  /// Whether this cell is highlighted (row/column).
  final bool isHighlighted;

  /// Whether this cell is in conflict.
  final bool isConflict;

  /// Border for the cell.
  final Border border;

  /// Called when the cell is tapped.
  final VoidCallback onTap;

  static const double _conflictOpacity = 0.14;
  static const double _selectedOpacity = 0.16;
  static const double _highlightOpacity = 0.05;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = _backgroundColor(colorScheme);
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: isGiven ? FontWeight.w700 : FontWeight.w500,
          color: isGiven ? colorScheme.onSurface : colorScheme.primary,
        );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: background,
          border: border,
        ),
        alignment: Alignment.center,
        child: value == 0
            ? const SizedBox.shrink()
            : Text(value.toString(), style: textStyle),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    if (isConflict) {
      return colorScheme.error.withValues(alpha: _conflictOpacity);
    }
    if (isSelected) {
      return colorScheme.primary.withValues(alpha: _selectedOpacity);
    }
    if (isHighlighted) {
      return colorScheme.primary.withValues(alpha: _highlightOpacity);
    }
    return Colors.transparent;
  }
}

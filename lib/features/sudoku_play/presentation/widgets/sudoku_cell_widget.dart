import 'package:flutter/material.dart';

/// Renders a single Sudoku cell with selection styling.
class SudokuCellWidget extends StatelessWidget {
  /// Creates a Sudoku cell widget.
  const SudokuCellWidget({
    super.key,
    required this.value,
    required this.isGiven,
    required this.isHinted,
    required this.isSelected,
    required this.isHighlighted,
    required this.isTransientHighlighted,
    required this.border,
    required this.onTap,
  });

  /// Current value of the cell.
  final int value;

  /// Whether the cell is a given.
  final bool isGiven;

  /// Whether the cell was filled by a hint.
  final bool isHinted;

  /// Whether this cell is selected.
  final bool isSelected;

  /// Whether this cell is highlighted (row/column).
  final bool isHighlighted;

  /// Whether this cell is highlighted as a conflict.
  final bool isTransientHighlighted;

  /// Border for the cell.
  final Border border;

  /// Called when the cell is tapped.
  final VoidCallback onTap;

  static const double _selectedOpacity = 0.12;
  static const double _highlightOpacity = 0.08;
  static const double _conflictOpacity = 0.35;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = _backgroundColor(colorScheme);
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: isGiven
              ? FontWeight.w700
              : isHinted
                  ? FontWeight.w600
                  : FontWeight.w500,
          color: isGiven
              ? colorScheme.onSurface
              : isHinted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
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
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                transitionBuilder: (child, animation) {
                  final scale = Tween<double>(
                    begin: 0.92,
                    end: 1,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: scale, child: child),
                  );
                },
                child: Text(
                  value.toString(),
                  key: ValueKey(value),
                  style: textStyle,
                ),
              ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    if (isTransientHighlighted) {
      return colorScheme.tertiaryContainer
          .withValues(alpha: _conflictOpacity);
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

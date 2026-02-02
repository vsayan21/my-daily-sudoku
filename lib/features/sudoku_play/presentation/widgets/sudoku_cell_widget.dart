import 'package:flutter/material.dart';

/// Renders a single Sudoku cell with selection styling.
class SudokuCellWidget extends StatelessWidget {
  /// Creates a Sudoku cell widget.
  const SudokuCellWidget({
    super.key,
    required this.value,
    required this.notes,
    required this.isGiven,
    required this.isHinted,
    required this.isSelected,
    required this.isHighlighted,
    required this.isTransientHighlighted,
    required this.border,
    required this.onTap,
  });

  /// Current value of the cell.
  final int? value;

  /// Manual notes for the cell.
  final Set<int> notes;

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

  static const double _selectedOpacity = 0.6;
  static const double _highlightOpacity = 0.08;
  static const double _conflictOpacity = 0.35;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = _backgroundColor(colorScheme);
    final noteStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
        );
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
        child: AnimatedSwitcher(
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
          child: value == null
              ? _NotesGrid(
                  key: const ValueKey('notes'),
                  notes: notes,
                  textStyle: noteStyle,
                )
              : Text(
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
      return colorScheme.secondaryContainer
          .withValues(alpha: _selectedOpacity);
    }
    if (isHighlighted) {
      return colorScheme.primary.withValues(alpha: _highlightOpacity);
    }
    return Colors.transparent;
  }
}

class _NotesGrid extends StatelessWidget {
  const _NotesGrid({
    super.key,
    required this.notes,
    required this.textStyle,
  });

  final Set<int> notes;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 3;
        final fontSize = (cellSize * 0.65).clamp(8.0, 14.0);
        final style = textStyle?.copyWith(fontSize: fontSize);

        return Column(
          children: List.generate(3, (row) {
            return Expanded(
              child: Row(
                children: List.generate(3, (col) {
                  final value = row * 3 + col + 1;
                  final label = notes.contains(value) ? '$value' : '';
                  return Expanded(
                    child: Center(
                      child: Text(label, style: style),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

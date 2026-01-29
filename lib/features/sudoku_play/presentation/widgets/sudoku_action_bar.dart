import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

/// Compact action bar for Sudoku tools.
class SudokuActionBar extends StatelessWidget {
  /// Creates a Sudoku action bar.
  const SudokuActionBar({
    super.key,
    required this.onHintPressed,
    required this.onErasePressed,
    required this.onUndoPressed,
  });

  /// Called when hint is pressed.
  final VoidCallback? onHintPressed;

  /// Called when erase is pressed.
  final VoidCallback? onErasePressed;

  /// Called when undo is pressed.
  final VoidCallback? onUndoPressed;

  static const double _spacing = 12;
  static const double _buttonHeight = 46;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final buttonStyle = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: const StadiumBorder(),
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, _buttonHeight),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _ActionButton(
            label: loc.sudokuActionHint,
            icon: Icons.lightbulb_outline_rounded,
            tooltip: loc.sudokuActionHint,
            onPressed: onHintPressed,
            style: buttonStyle,
          ),
        ),
        const SizedBox(width: _spacing),
        Expanded(
          child: _ActionButton(
            label: loc.sudokuActionErase,
            icon: Icons.backspace_outlined,
            tooltip: loc.sudokuActionErase,
            onPressed: onErasePressed,
            style: buttonStyle,
          ),
        ),
        const SizedBox(width: _spacing),
        Expanded(
          child: _ActionButton(
            label: loc.sudokuActionUndo,
            icon: Icons.undo_rounded,
            tooltip: loc.sudokuActionUndo,
            onPressed: onUndoPressed,
            style: buttonStyle,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.style,
  });

  final String label;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final ButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 20),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Number pad for Sudoku input.
class SudokuNumberPad extends StatelessWidget {
  /// Creates a Sudoku number pad.
  const SudokuNumberPad({
    super.key,
    required this.onNumberSelected,
    required this.onErase,
  });

  /// Called when a number is selected.
  final ValueChanged<int> onNumberSelected;

  /// Called when the erase button is pressed.
  final VoidCallback onErase;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      for (var number = 1; number <= 9; number++)
        _NumberButton(
          label: number.toString(),
          onPressed: () => onNumberSelected(number),
        ),
      _NumberButton(
        label: '⌫',
        onPressed: onErase,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: buttons,
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 48,
      child: FilledButton.tonal(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

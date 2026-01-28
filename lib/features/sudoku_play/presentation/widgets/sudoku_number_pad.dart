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

  static const double _horizontalPadding = 12;
  static const double _spacing = 12;
  static const double _buttonSize = 56;
  static const double _minTapSize = 48;

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
        isErase: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Wrap(
        spacing: _spacing,
        runSpacing: _spacing,
        alignment: WrapAlignment.center,
        children: buttons,
      ),
    );
  }
}

class _NumberButton extends StatefulWidget {
  const _NumberButton({
    required this.label,
    required this.onPressed,
    this.isErase = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isErase;

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton> {
  static const double _pressedScale = 0.95;
  static const Duration _scaleDuration = Duration(milliseconds: 90);

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.isErase
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = widget.isErase
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return AnimatedScale(
      scale: _isPressed ? _pressedScale : 1,
      duration: _scaleDuration,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: SudokuNumberPad._minTapSize,
          minHeight: SudokuNumberPad._minTapSize,
        ),
        child: SizedBox(
          width: SudokuNumberPad._buttonSize,
          height: SudokuNumberPad._buttonSize,
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              child: Center(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }
}

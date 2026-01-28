import 'package:flutter/material.dart';

class StreakWeekDots extends StatelessWidget {
  const StreakWeekDots({
    super.key,
    required this.todaySolved,
  });

  final bool todaySolved;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final neutralColor = colorScheme.surfaceContainerHighest;
    final neutralBorder = colorScheme.outlineVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 6; i++)
          _Dot(
            color: neutralColor,
            borderColor: neutralColor,
          ),
        _Dot(
          color: todaySolved ? colorScheme.primary : Colors.transparent,
          borderColor: todaySolved ? colorScheme.primary : neutralBorder,
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    required this.borderColor,
  });

  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 1),
      ),
    );
  }
}

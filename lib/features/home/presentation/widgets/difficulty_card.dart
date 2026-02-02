import 'package:flutter/material.dart';

import '../../../medals/domain/medal.dart';
import '../../domain/models/difficulty_option.dart';
import '../models/difficulty_tile_state.dart';

class DifficultyCard extends StatelessWidget {
  const DifficultyCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onPressed,
    this.tileState,
  });

  final DifficultyOption option;
  final bool isSelected;
  final VoidCallback onPressed;
  final DifficultyTileState? tileState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        isSelected ? colorScheme.primary : colorScheme.outlineVariant;
    final backgroundColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surfaceContainerLow;
    final solvedState = tileState;
    final isSolved = solvedState?.isSolvedToday ?? false;
    final medal = solvedState?.medal;

    final timeStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );
    final leadingIconColor =
        medal == null ? colorScheme.primary : _medalColor(colorScheme, medal);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: leadingIconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                medal == null ? option.icon : Icons.emoji_events_rounded,
                color: leadingIconColor,
                size: medal == null ? 24 : 30,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              option.title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (isSolved && solvedState?.timeLabel != null) ...[
              Expanded(
                child: Text(
                  solvedState!.timeLabel ?? '--:--',
                  textAlign: TextAlign.right,
                  style: timeStyle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _medalColor(ColorScheme scheme, Medal medal) {
    switch (medal) {
      case Medal.gold:
        return scheme.tertiary;
      case Medal.silver:
        return scheme.secondary;
      case Medal.bronze:
        return scheme.primary;
    }
  }
}

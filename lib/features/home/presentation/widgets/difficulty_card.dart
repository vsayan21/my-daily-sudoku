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
    final detailStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
    final timeStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );
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
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(option.icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (isSolved && solvedState?.timeLabel != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Solved', style: detailStyle),
                        const Spacer(),
                        if (medal != null)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 20,
                                color: _medalColor(colorScheme, medal),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                solvedState!.timeLabel ?? '--:--',
                                style: timeStyle,
                              ),
                            ],
                          )
                        else
                          Text(
                            solvedState!.timeLabel ?? '--:--',
                            style: timeStyle,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
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

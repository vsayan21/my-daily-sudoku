import 'package:flutter/material.dart';

import '../../../medals/presentation/medal_colors.dart';

class MedalSummaryRow extends StatelessWidget {
  const MedalSummaryRow({
    super.key,
    required this.goldCount,
    required this.silverCount,
    required this.bronzeCount,
  });

  final int goldCount;
  final int silverCount;
  final int bronzeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MedalTile(
            label: 'Gold',
            count: goldCount,
            color: MedalColors.gold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MedalTile(
            label: 'Silver',
            count: silverCount,
            color: MedalColors.silver,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MedalTile(
            label: 'Bronze',
            count: bronzeCount,
            color: MedalColors.bronze,
          ),
        ),
      ],
    );
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.emoji_events, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

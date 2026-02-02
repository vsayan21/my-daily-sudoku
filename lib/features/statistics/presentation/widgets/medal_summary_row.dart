import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _MedalTile(
            label: 'Gold',
            count: goldCount,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MedalTile(
            label: 'Silver',
            count: silverCount,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MedalTile(
            label: 'Bronze',
            count: bronzeCount,
            color: colorScheme.tertiary,
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
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: color),
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
                  'x$count',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

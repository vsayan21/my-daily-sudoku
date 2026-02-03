import 'package:flutter/material.dart';

class RankingHeader extends StatelessWidget {
  const RankingHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
    required this.refreshTooltip,
    this.isRefreshing = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRefresh;
  final String refreshTooltip;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: refreshTooltip,
          onPressed: isRefreshing ? null : onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';
import 'ranking_scope_segment.dart';
import 'ranking_types.dart';

class RankingHeader extends StatelessWidget {
  const RankingHeader({
    super.key,
    required this.title,
    required this.dateFilter,
    required this.scope,
    required this.onDateFilterChanged,
    required this.onScopeChanged,
  });

  final String title;
  final DateFilter dateFilter;
  final RankingScope scope;
  final ValueChanged<DateFilter> onDateFilterChanged;
  final ValueChanged<RankingScope> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RankingScopeSegment(
                  value: scope,
                  onChanged: onScopeChanged,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 96,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _DateFilterMenu(
                    value: dateFilter,
                    onChanged: onDateFilterChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFilterMenu extends StatelessWidget {
  const _DateFilterMenu({
    required this.value,
    required this.onChanged,
  });

  final DateFilter value;
  final ValueChanged<DateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (value) {
      DateFilter.today => loc.rankingDayToday,
      DateFilter.yesterday => loc.rankingDayYesterday,
    };
    return PopupMenuButton<DateFilter>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: DateFilter.today,
          child: Text(loc.rankingDayToday),
        ),
        PopupMenuItem(
          value: DateFilter.yesterday,
          child: Text(loc.rankingDayYesterday),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more,
              size: 18,
              color: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

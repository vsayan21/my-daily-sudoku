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
    required this.onRefresh,
  });

  final String title;
  final DateFilter dateFilter;
  final RankingScope scope;
  final ValueChanged<DateFilter> onDateFilterChanged;
  final ValueChanged<RankingScope> onScopeChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              _DateFilterMenu(
                value: dateFilter,
                onChanged: onDateFilterChanged,
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RankingScopeSegment(
            value: scope,
            onChanged: onScopeChanged,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.expand_more,
            size: 18,
          ),
        ],
      ),
    );
  }
}

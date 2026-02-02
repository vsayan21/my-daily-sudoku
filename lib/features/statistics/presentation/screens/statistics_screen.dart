import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';
import '../../application/statistics_view_model.dart';
import '../../application/usecases/load_statistics.dart';
import '../../data/datasources/statistics_local_datasource.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/entities/statistics_summary.dart';
import '../widgets/best_times_row.dart';
import '../widgets/medal_summary_row.dart';
import '../widgets/stat_kpi_card.dart';
import '../widgets/stats_history_list.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final preferences = await SharedPreferences.getInstance();
    final repository = StatisticsRepositoryImpl(
      dataSource: StatisticsLocalDataSource(preferences),
    );
    final loadStatistics = LoadStatistics(
      repository: repository,
      preferences: preferences,
    );
    final viewModel = StatisticsViewModel(loadStatistics: loadStatistics);
    await viewModel.load();
    if (!mounted) {
      viewModel.dispose();
      return;
    }
    setState(() {
      _viewModel = viewModel;
    });
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading || viewModel.summary == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final summary = viewModel.summary!;
        return _StatisticsBody(
          summary: summary,
          history: viewModel.history,
          currentStreak: viewModel.currentStreak,
          longestStreak: viewModel.longestStreak,
          hintsLabel: loc.statsHintsUsed,
          movesLabel: loc.statsMoves,
          undoLabel: loc.statsUndo,
          title: loc.navigationStatistics,
        );
      },
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({
    required this.summary,
    required this.history,
    required this.currentStreak,
    required this.longestStreak,
    required this.hintsLabel,
    required this.movesLabel,
    required this.undoLabel,
    required this.title,
  });

  final StatisticsSummary summary;
  final List<StatisticsHistoryEntry> history;
  final int currentStreak;
  final int longestStreak;
  final String hintsLabel;
  final String movesLabel;
  final String undoLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 320,
                  child: StatKpiCard(
                    title: 'Streak',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _KpiLine(
                          label: 'Current',
                          value: currentStreak.toString(),
                        ),
                        const SizedBox(height: 8),
                        _KpiLine(
                          label: 'Longest',
                          value: longestStreak.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: StatKpiCard(
                    title: 'Completed puzzles',
                    child: Text(
                      summary.completedCount.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Best times',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            BestTimesRow(bestTimes: summary.bestTimesSeconds),
            const SizedBox(height: 24),
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActivityTile(
                    label: hintsLabel,
                    value: summary.totalHints,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActivityTile(
                    label: movesLabel,
                    value: summary.totalMoves,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActivityTile(
                    label: undoLabel,
                    value: summary.totalUndo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Medals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            MedalSummaryRow(
              goldCount: summary.goldMedals,
              silverCount: summary.silverMedals,
              bronzeCount: summary.bronzeMedals,
            ),
            const SizedBox(height: 24),
            Text(
              'History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            StatsHistoryList(history: history),
          ],
        ),
      ),
    );
  }
}

class _KpiLine extends StatelessWidget {
  const _KpiLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

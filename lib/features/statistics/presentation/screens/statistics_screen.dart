import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
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
    required this.title,
  });

  final StatisticsSummary summary;
  final List<StatisticsHistoryEntry> history;
  final int currentStreak;
  final int longestStreak;
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
            StatKpiCard(
              title: 'Overview',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 160,
                    child: _OverviewStat(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Current streak',
                      value: currentStreak.toString(),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _OverviewStat(
                      icon: Icons.emoji_events_outlined,
                      label: 'Longest streak',
                      value: longestStreak.toString(),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _OverviewStat(
                      icon: Icons.check_circle_outline,
                      label: 'Completed',
                      value: summary.completedCount.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StatKpiCard(
              title: 'Best times',
              child: Column(
                children: [
                  BestTimesRow(bestTimes: summary.bestTimesSeconds),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StatKpiCard(
              title: 'Medals',
              child: MedalSummaryRow(
                goldCount: summary.goldMedals,
                silverCount: summary.silverMedals,
                bronzeCount: summary.bronzeMedals,
              ),
            ),
            const SizedBox(height: 16),
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

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

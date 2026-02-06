import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../application/statistics_view_model.dart';
import '../../application/usecases/load_statistics.dart';
import '../../data/datasources/statistics_local_datasource.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/entities/statistics_summary.dart';
import '../widgets/best_times_row.dart';
import '../widgets/medal_summary_row.dart';
import '../widgets/stat_kpi_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  StatisticsViewModel? _viewModel;
  AnimationController? _animationController;
  Animation<double>? _overviewOpacity;
  Animation<Offset>? _overviewSlide;
  Animation<double>? _timesOpacity;
  Animation<Offset>? _timesSlide;
  Animation<double>? _achievementsOpacity;
  Animation<Offset>? _achievementsSlide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    final curve = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    );
    _overviewOpacity = CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _overviewSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(curve);
    _timesOpacity = CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.2, 0.75, curve: Curves.easeOut),
    );
    _timesSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(curve);
    _achievementsOpacity = CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _achievementsSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(curve);
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
    _animationController?.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController?.dispose();
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
          currentStreak: viewModel.currentStreak,
          longestStreak: viewModel.longestStreak,
          title: loc.navigationStatistics,
          overviewOpacity: _overviewOpacity ?? const AlwaysStoppedAnimation(1),
          overviewSlide: _overviewSlide ?? const AlwaysStoppedAnimation(Offset.zero),
          timesOpacity: _timesOpacity ?? const AlwaysStoppedAnimation(1),
          timesSlide: _timesSlide ?? const AlwaysStoppedAnimation(Offset.zero),
          achievementsOpacity: _achievementsOpacity ?? const AlwaysStoppedAnimation(1),
          achievementsSlide: _achievementsSlide ?? const AlwaysStoppedAnimation(Offset.zero),
        );
      },
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({
    required this.summary,
    required this.currentStreak,
    required this.longestStreak,
    required this.title,
    required this.overviewOpacity,
    required this.overviewSlide,
    required this.timesOpacity,
    required this.timesSlide,
    required this.achievementsOpacity,
    required this.achievementsSlide,
  });

  final StatisticsSummary summary;
  final int currentStreak;
  final int longestStreak;
  final String title;
  final Animation<double> overviewOpacity;
  final Animation<Offset> overviewSlide;
  final Animation<double> timesOpacity;
  final Animation<Offset> timesSlide;
  final Animation<double> achievementsOpacity;
  final Animation<Offset> achievementsSlide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: overviewOpacity,
                child: SlideTransition(
                  position: overviewSlide,
                  child: StatKpiCard(
                    title: 'Overview',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _OverviewStat(
                                icon: Icons.emoji_events_outlined,
                                label: 'Longest streak',
                                value: longestStreak.toString(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OverviewStat(
                                icon: Icons.local_fire_department_outlined,
                                label: 'Current streak',
                                value: currentStreak.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _CompletedBreakdownCard(
                          totalLabel: 'Completed Sudoku',
                          totalValue: summary.completedCount,
                          easyLabel: loc.difficultyEasy,
                          mediumLabel: loc.difficultyMedium,
                          hardLabel: loc.difficultyHard,
                          easyCount: summary
                                  .completedByDifficulty[SudokuDifficulty.easy] ??
                              0,
                          mediumCount: summary.completedByDifficulty[
                                  SudokuDifficulty.medium] ??
                              0,
                          hardCount: summary
                                  .completedByDifficulty[SudokuDifficulty.hard] ??
                              0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: timesOpacity,
                child: SlideTransition(
                  position: timesSlide,
                  child: StatKpiCard(
                    title: 'Best times',
                    child: Column(
                      children: [
                        BestTimesRow(bestTimes: summary.bestTimesSeconds),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: achievementsOpacity,
                child: SlideTransition(
                  position: achievementsSlide,
                  child: StatKpiCard(
                    title: 'Achievements',
                    child: MedalSummaryRow(
                      goldCount: summary.goldMedals,
                      silverCount: summary.silverMedals,
                      bronzeCount: summary.bronzeMedals,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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
      ),
    );
  }
}

class _CompletedBreakdownCard extends StatelessWidget {
  const _CompletedBreakdownCard({
    required this.totalLabel,
    required this.totalValue,
    required this.easyLabel,
    required this.mediumLabel,
    required this.hardLabel,
    required this.easyCount,
    required this.mediumCount,
    required this.hardCount,
  });

  final String totalLabel;
  final int totalValue;
  final String easyLabel;
  final String mediumLabel;
  final String hardLabel;
  final int easyCount;
  final int mediumCount;
  final int hardCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  totalLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.96, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Text(
                  totalValue.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                _DifficultyCountChip(label: easyLabel, value: easyCount),
                const SizedBox(width: 10),
                _DifficultyCountChip(label: mediumLabel, value: mediumCount),
                const SizedBox(width: 10),
                _DifficultyCountChip(label: hardLabel, value: hardCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyCountChip extends StatelessWidget {
  const _DifficultyCountChip({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.96, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

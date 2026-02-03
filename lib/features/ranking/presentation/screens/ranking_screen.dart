import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../daily_sudoku/shared/daily_key.dart';
import '../../application/ranking_controller.dart';
import '../../data/ranking_remote_datasource.dart';
import '../../data/ranking_repository_impl.dart';
import '../../domain/entities/ranking_entry.dart';
import '../../domain/ranking_repository.dart';
import '../widgets/difficulty_segment.dart';
import '../widgets/ranking_date_picker.dart';
import '../widgets/ranking_empty_state.dart';
import '../widgets/ranking_header.dart';
import '../widgets/ranking_list_item.dart';
import '../widgets/ranking_shimmer_list.dart';
import '../../../../l10n/app_localizations.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    final repository = RankingRepositoryImpl(
      dataSource: RankingRemoteDataSource(),
    );
    final controller = RankingController(
      repository: repository,
      uidProvider: widget.dependencies.firebaseProfileService.ensureSignedIn,
    );
    await controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final loc = AppLocalizations.of(context)!;
            final dateKeys = _buildRecentDateKeys();
            final dateLabel = _labelForDateKey(
              context,
              controller.selectedDateKey,
            );
            final entries = controller.entries;
            final rankedEntries = _buildRankedEntries(entries);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RankingHeader(
                  title: loc.navigationProfile,
                  subtitle: loc.rankingGlobalSubtitle(dateLabel),
                  onRefresh: controller.refresh,
                  refreshTooltip: loc.rankingRefreshTooltip,
                  isRefreshing: controller.isLoading,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    RankingDatePicker(
                      selectedDateKey: controller.selectedDateKey,
                      availableDateKeys: dateKeys,
                      labelBuilder: (key) => _labelForDateKey(context, key),
                      onChanged: controller.setDateKey,
                    ),
                    const Spacer(),
                    DifficultySegment(
                      selected: controller.selectedDifficulty,
                      easyLabel: loc.difficultyEasy,
                      mediumLabel: loc.difficultyMedium,
                      hardLabel: loc.difficultyHard,
                      onSelectionChanged: controller.setDifficulty,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: _buildBody(
                      context,
                      controller: controller,
                      entries: rankedEntries,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required RankingController controller,
    required List<_RankedEntry> entries,
  }) {
    final loc = AppLocalizations.of(context)!;
    if (controller.isLoading && entries.isEmpty) {
      return const RankingShimmerList();
    }

    if (controller.error != null) {
      return _buildScrollableMessage(
        context,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.rankingErrorTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: controller.refresh,
                child: Text(loc.rankingRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (entries.isEmpty) {
      return _buildScrollableMessage(
        context,
        child: RankingEmptyState(
          title: loc.rankingEmptyTitle,
          subtitle: loc.rankingEmptySubtitle,
        ),
      );
    }

    final currentUid = controller.currentUid;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemBuilder: (context, index) {
        final ranked = entries[index];
        final isCurrentUser =
            currentUid != null && currentUid.isNotEmpty &&
            ranked.entry.uid == currentUid;
        return RankingListItem(
          rank: ranked.rank,
          entry: ranked.entry,
          timeLabel: _formatDuration(ranked.entry.elapsedSeconds),
          metaLabel: loc.rankingHintsMovesLabel(
            ranked.entry.hintsUsed,
            ranked.entry.movesCount,
          ),
          youLabel: loc.rankingYouLabel,
          isCurrentUser: isCurrentUser,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: entries.length,
    );
  }

  Widget _buildScrollableMessage(BuildContext context, {required Widget child}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        child,
      ],
    );
  }

  List<String> _buildRecentDateKeys() {
    final now = DateTime.now();
    final anchor = DateTime(now.year, now.month, now.day);
    return List.generate(
      7,
      (index) => buildDailyKey(
        now: anchor.subtract(Duration(days: index)),
      ),
    );
  }

  String _labelForDateKey(BuildContext context, String dateKey) {
    final loc = AppLocalizations.of(context)!;
    final todayKey = buildDailyKey();
    if (dateKey == todayKey) {
      return loc.today;
    }
    final date = DateTime.tryParse(dateKey);
    if (date == null) {
      return dateKey;
    }
    return DateFormat.yMMMd(loc.localeName).format(date);
  }

  List<_RankedEntry> _buildRankedEntries(List<RankingEntry> entries) {
    final ranked = <_RankedEntry>[];
    String? previousKey;
    var rank = 1;
    for (var index = 0; index < entries.length; index += 1) {
      final entry = entries[index];
      final key =
          '${entry.elapsedSeconds}_${entry.hintsUsed}_${entry.movesCount}_${entry.undoCount}';
      if (index == 0) {
        rank = 1;
      } else if (previousKey != key) {
        rank = index + 1;
      }
      ranked.add(_RankedEntry(entry: entry, rank: rank));
      previousKey = key;
    }
    return ranked;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _RankedEntry {
  const _RankedEntry({required this.entry, required this.rank});

  final RankingEntry entry;
  final int rank;
}

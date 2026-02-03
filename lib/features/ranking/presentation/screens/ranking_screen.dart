import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../daily_sudoku/shared/daily_key.dart';
import '../../../profile/application/usecases/load_user_profile.dart';
import '../../../profile/application/usecases/update_avatar_path.dart';
import '../../../profile/application/usecases/update_display_name.dart';
import '../../../profile/data/datasources/user_profile_local_datasource.dart';
import '../../../profile/data/repositories/user_profile_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/widgets/profile_card.dart';
import '../../application/ranking_controller.dart';
import '../../data/ranking_remote_datasource.dart';
import '../../data/ranking_repository_impl.dart';
import '../../domain/entities/ranking_entry.dart';
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
  ProfileController? _profileController;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _profileController?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    final preferences = await widget.dependencies.sharedPreferences;
    final profileService = widget.dependencies.firebaseProfileService;
    final syncService = await widget.dependencies.firebaseSyncService;
    final locale = Localizations.localeOf(context);
    await syncService.ensureUserProfileExistsAndSynced(
      locale: locale.toLanguageTag(),
    );
    await syncService.uploadAllLocalResults();
    final profileRepository = UserProfileRepositoryImpl(
      dataSource: UserProfileLocalDataSource(preferences),
      userIdProvider: profileService.ensureSignedIn,
      defaultNameBuilder: profileService.defaultDisplayNameForUid,
    );
    final profileController = ProfileController(
      loadUserProfile: LoadUserProfile(repository: profileRepository),
      updateDisplayName: UpdateDisplayName(
        repository: profileRepository,
        firebaseProfileService: profileService,
      ),
      updateAvatarPath: UpdateAvatarPath(repository: profileRepository),
    );
    await profileController.loadProfile();

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
    setState(() {
      _controller = controller;
      _profileController = profileController;
    });
  }

  Future<void> _showEditNameSheet(ProfileController controller) async {
    final profile = controller.profile;
    if (profile == null) {
      return;
    }
    final loc = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: profile.displayName);
    String? errorText;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.profileEditDisplayNameTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    textInputAction: TextInputAction.done,
                    maxLength: 24,
                    decoration: InputDecoration(
                      labelText: loc.profileDisplayNameLabel,
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() => errorText = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      await controller.updateDisplayName(
                        textController.text,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      if (controller.isDisplayNameTaken) {
                        setState(
                          () => errorText = loc.profileDisplayNameTakenError,
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(loc.save),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    final controller = _profileController;
    if (controller == null) {
      return;
    }
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(source: source);
      if (file == null) {
        return;
      }
      await controller.updateAvatarPath(file.path);
    } on PlatformException {
      if (!mounted) {
        return;
      }
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.profileAvatarPickError)),
      );
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.profileAvatarPickError)),
      );
    }
  }

  Future<void> _showAvatarPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(loc.profileAvatarGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatarImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(loc.profileAvatarCamera),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatarImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
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
                if (_profileController != null)
                  AnimatedBuilder(
                    animation: _profileController!,
                    builder: (context, _) {
                      final profile = _profileController!.profile;
                      if (profile == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProfileCard(
                          profile: profile,
                          onEditName: () => _showEditNameSheet(
                            _profileController!,
                          ),
                          onPickAvatar: _showAvatarPicker,
                        ),
                      );
                    },
                  ),
                RankingHeader(
                  title: loc.navigationProfile,
                  subtitle: loc.rankingGlobalSubtitle(dateLabel),
                  onRefresh: controller.refresh,
                  refreshTooltip: loc.rankingRefreshTooltip,
                  isRefreshing: controller.isLoading,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 420;
                    final datePicker = RankingDatePicker(
                      selectedDateKey: controller.selectedDateKey,
                      availableDateKeys: dateKeys,
                      labelBuilder: (key) => _labelForDateKey(context, key),
                      onChanged: controller.setDateKey,
                    );
                    final difficultySegment = DifficultySegment(
                      selected: controller.selectedDifficulty,
                      easyLabel: loc.difficultyEasy,
                      mediumLabel: loc.difficultyMedium,
                      hardLabel: loc.difficultyHard,
                      onSelectionChanged: controller.setDifficulty,
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          datePicker,
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: difficultySegment,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        datePicker,
                        const Spacer(),
                        Flexible(child: difficultySegment),
                      ],
                    );
                  },
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../daily_sudoku/shared/daily_key.dart';
import '../../../profile/application/usecases/load_user_profile.dart';
import '../../../profile/application/usecases/update_avatar_path.dart';
import '../../../profile/application/usecases/update_country_code.dart';
import '../../../profile/application/usecases/update_display_name.dart';
import '../../../profile/data/datasources/user_profile_local_datasource.dart';
import '../../../profile/data/repositories/user_profile_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/widgets/profile_card.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../ranking/data/models/leaderboard_entry.dart';
import '../../../ranking/data/services/leaderboard_service.dart';
import '../../../statistics/application/statistics_view_model.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  ProfileController? _controller;
  Locale? _locale;
  bool _isLoadingController = false;
  final LeaderboardService _leaderboardService = LeaderboardService();
  LeaderboardScope _scope = LeaderboardScope.global;
  LeaderboardDay _day = LeaderboardDay.today;
  Future<LeaderboardResult>? _leaderboardFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale ??= Localizations.localeOf(context);
    if (_controller == null && !_isLoadingController) {
      _isLoadingController = true;
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    final locale = _locale;
    if (locale == null) {
      _isLoadingController = false;
      return;
    }
    final preferences = await widget.dependencies.sharedPreferences;
    final profileService = widget.dependencies.firebaseProfileService;
    final syncService = await widget.dependencies.firebaseSyncService;
    final countryCode = _resolveCountryCode(locale);
    await syncService.ensureUserProfileExistsAndSynced(
      locale: locale.toLanguageTag(),
      countryCode: countryCode,
    );
    await syncService.uploadAllLocalResults();
    final repository = UserProfileRepositoryImpl(
      dataSource: UserProfileLocalDataSource(preferences),
      userIdProvider: profileService.ensureSignedIn,
      defaultNameBuilder: profileService.defaultDisplayNameForUid,
    );
    final controller = ProfileController(
      loadUserProfile: LoadUserProfile(repository: repository),
      updateDisplayName: UpdateDisplayName(
        repository: repository,
        firebaseProfileService: profileService,
      ),
      updateAvatarPath: UpdateAvatarPath(repository: repository),
      updateCountryCode: UpdateCountryCode(repository: repository),
    );
    await controller.loadProfile();
    await _ensureCountryCode(controller);
    _leaderboardFuture = _loadLeaderboards(profile: controller.profile);
    if (!mounted) {
      _isLoadingController = false;
      return;
    }
    setState(() {
      _controller = controller;
      _isLoadingController = false;
    });
  }

  Future<void> _ensureCountryCode(ProfileController controller) async {
    final profile = controller.profile;
    final locale = _locale;
    if (profile == null || locale == null) {
      return;
    }
    if (profile.countryCode != null && profile.countryCode!.isNotEmpty) {
      return;
    }
    final resolved = _resolveCountryCode(locale);
    if (resolved == null) {
      return;
    }
    await controller.updateCountryCode(resolved);
  }

  String? _resolveCountryCode(Locale locale) {
    final primary = _normalizeCountryCode(locale.countryCode);
    if (primary != null) {
      return primary;
    }
    final platformLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    for (final candidate in platformLocales) {
      final normalized = _normalizeCountryCode(candidate.countryCode);
      if (normalized != null) {
        return normalized;
      }
    }
    return 'US';
  }

  String? _normalizeCountryCode(String? code) {
    if (code == null) {
      return null;
    }
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return null;
    }
    if (RegExp(r'^[A-Z]{2}$').hasMatch(trimmed)) {
      return trimmed;
    }
    return null;
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

  Future<void> _showEditCountrySheet(ProfileController controller) async {
    final profile = controller.profile;
    if (profile == null) {
      return;
    }
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 520,
      ),
      onSelect: (Country country) {
        controller.updateCountryCode(country.countryCode).then((_) {
          if (!mounted) {
            return;
          }
          _refreshLeaderboards(controller);
        });
      },
    );
  }

  Future<LeaderboardResult> _loadLeaderboards({
    required UserProfile? profile,
  }) async {
    final dateKey = _selectedDateKey();
    final countryCode = profile?.countryCode;
    if (_scope == LeaderboardScope.local &&
        (countryCode == null || countryCode.isEmpty)) {
      return const LeaderboardResult(
        status: LeaderboardStatus.missingCountry,
        entries: {
          SudokuDifficulty.easy: [],
          SudokuDifficulty.medium: [],
          SudokuDifficulty.hard: [],
        },
      );
    }
    final uid = await widget.dependencies.firebaseProfileService.ensureSignedIn();
    if (uid.isEmpty) {
      return const LeaderboardResult(
        status: LeaderboardStatus.authRequired,
        entries: {
          SudokuDifficulty.easy: [],
          SudokuDifficulty.medium: [],
          SudokuDifficulty.hard: [],
        },
      );
    }
    try {
      final localCode =
          _scope == LeaderboardScope.local ? countryCode : null;
      final futures = <Future<List<LeaderboardEntry>>>[
        _leaderboardService.fetchTopEntries(
          dateKey: dateKey,
          difficulty: SudokuDifficulty.easy,
          countryCode: localCode,
        ),
        _leaderboardService.fetchTopEntries(
          dateKey: dateKey,
          difficulty: SudokuDifficulty.medium,
          countryCode: localCode,
        ),
        _leaderboardService.fetchTopEntries(
          dateKey: dateKey,
          difficulty: SudokuDifficulty.hard,
          countryCode: localCode,
        ),
      ];
      final results = await Future.wait(futures);
      return LeaderboardResult(
        status: LeaderboardStatus.ok,
        entries: {
          SudokuDifficulty.easy: results[0],
          SudokuDifficulty.medium: results[1],
          SudokuDifficulty.hard: results[2],
        },
      );
    } catch (error) {
      return const LeaderboardResult(
        status: LeaderboardStatus.error,
        entries: {
          SudokuDifficulty.easy: [],
          SudokuDifficulty.medium: [],
          SudokuDifficulty.hard: [],
        },
      );
    }
  }

  void _refreshLeaderboards(ProfileController controller) {
    setState(() {
      _leaderboardFuture = _loadLeaderboards(profile: controller.profile);
    });
  }

  String _selectedDateKey() {
    final now = DateTime.now();
    if (_day == LeaderboardDay.today) {
      return buildDailyKeyUtc(now: now);
    }
    return buildDailyKeyUtc(now: now.subtract(const Duration(days: 1)));
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    final controller = _controller;
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
    final loc = AppLocalizations.of(context)!;
    final controller = _controller;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: controller == null
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final profile = controller.profile;
                  if (profile == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: [
                      Text(
                        loc.navigationProfile,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      ProfileCard(
                        profile: profile,
                        onEditName: () => _showEditNameSheet(controller),
                        onEditCountry: () =>
                            _showEditCountrySheet(controller),
                        onPickAvatar: _showAvatarPicker,
                      ),
                      const SizedBox(height: 24),
                      _LeaderboardControls(
                        scope: _scope,
                        day: _day,
                        onScopeChanged: (value) {
                          _scope = value;
                          _refreshLeaderboards(controller);
                        },
                        onDayChanged: (value) {
                          _day = value;
                          _refreshLeaderboards(controller);
                        },
                      ),
                      const SizedBox(height: 16),
                      _LeaderboardSections(
                        future: _leaderboardFuture ??
                            _loadLeaderboards(profile: profile),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

enum LeaderboardScope { global, local }

enum LeaderboardDay { today, yesterday }

class _LeaderboardControls extends StatelessWidget {
  const _LeaderboardControls({
    required this.scope,
    required this.day,
    required this.onScopeChanged,
    required this.onDayChanged,
  });

  final LeaderboardScope scope;
  final LeaderboardDay day;
  final ValueChanged<LeaderboardScope> onScopeChanged;
  final ValueChanged<LeaderboardDay> onDayChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<LeaderboardScope>(
          segments: [
            ButtonSegment(
              value: LeaderboardScope.global,
              label: Text(loc.rankingScopeGlobal),
            ),
            ButtonSegment(
              value: LeaderboardScope.local,
              label: Text(loc.rankingScopeLocal),
            ),
          ],
          selected: {scope},
          onSelectionChanged: (value) => onScopeChanged(value.first),
        ),
        const SizedBox(height: 12),
        SegmentedButton<LeaderboardDay>(
          segments: [
            ButtonSegment(
              value: LeaderboardDay.today,
              label: Text(loc.rankingDayToday),
            ),
            ButtonSegment(
              value: LeaderboardDay.yesterday,
              label: Text(loc.rankingDayYesterday),
            ),
          ],
          selected: {day},
          onSelectionChanged: (value) => onDayChanged(value.first),
        ),
      ],
    );
  }
}

class _LeaderboardSections extends StatelessWidget {
  const _LeaderboardSections({
    required this.future,
  });

  final Future<LeaderboardResult> future;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<LeaderboardResult>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(loc.errorGeneric),
          );
        }
        final result = snapshot.data ??
            const LeaderboardResult(
              status: LeaderboardStatus.error,
              entries: {
                SudokuDifficulty.easy: [],
                SudokuDifficulty.medium: [],
                SudokuDifficulty.hard: [],
              },
            );
        if (result.status == LeaderboardStatus.authRequired) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(loc.rankingAuthRequired),
          );
        }
        if (result.status == LeaderboardStatus.missingCountry) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(loc.rankingLocalRequiresCountry),
          );
        }
        if (result.status == LeaderboardStatus.error) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(loc.errorGeneric),
          );
        }
        final data = result.entries;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LeaderboardSection(
              title: loc.difficultyEasy,
              entries: data[SudokuDifficulty.easy] ?? const [],
            ),
            const SizedBox(height: 16),
            _LeaderboardSection(
              title: loc.difficultyMedium,
              entries: data[SudokuDifficulty.medium] ?? const [],
            ),
            const SizedBox(height: 16),
            _LeaderboardSection(
              title: loc.difficultyHard,
              entries: data[SudokuDifficulty.hard] ?? const [],
            ),
          ],
        );
      },
    );
  }
}

enum LeaderboardStatus { ok, authRequired, missingCountry, error }

class LeaderboardResult {
  const LeaderboardResult({
    required this.status,
    required this.entries,
  });

  final LeaderboardStatus status;
  final Map<SudokuDifficulty, List<LeaderboardEntry>> entries;
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.title,
    required this.entries,
  });

  final String title;
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              loc.rankingEmpty,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            )
          else
            Column(
              children: [
                for (var index = 0; index < entries.length; index += 1)
                  _LeaderboardRow(
                    rank: index + 1,
                    entry: entries[index],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.entry,
  });

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            StatisticsViewModel.formatDuration(entry.elapsedSeconds),
            style: textTheme.bodySmall?.copyWith(
              fontFeatures: [StatisticsViewModel.tabularFigures()],
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

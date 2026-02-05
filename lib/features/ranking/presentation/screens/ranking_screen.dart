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
import '../widgets/ranking_difficulty_segment.dart';
import '../widgets/ranking_header.dart';
import '../widgets/ranking_types.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  static const Duration _cacheTtl = Duration(minutes: 10);
  static final Map<String, _LeaderboardCacheEntry> _cache = {};

  ProfileController? _controller;
  Locale? _locale;
  bool _isLoadingController = false;
  final LeaderboardService _leaderboardService = LeaderboardService();
  RankingScope _scope = RankingScope.global;
  DateFilter _dateFilter = DateFilter.today;
  SudokuDifficulty _difficulty = SudokuDifficulty.easy;
  Future<LeaderboardFetchResult>? _leaderboardFuture;

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
    _leaderboardFuture = _resolveLeaderboardFuture(controller);
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

  Future<LeaderboardFetchResult> _loadLeaderboard({
    required UserProfile? profile,
  }) async {
    final dateKey = _selectedDateKey();
    final countryCode = profile?.countryCode;
    if (_scope == RankingScope.local &&
        (countryCode == null || countryCode.isEmpty)) {
      return const LeaderboardFetchResult(
        status: LeaderboardStatus.missingCountry,
        entries: [],
      );
    }
    final uid = await widget.dependencies.firebaseProfileService.ensureSignedIn();
    if (uid.isEmpty) {
      return const LeaderboardFetchResult(
        status: LeaderboardStatus.authRequired,
        entries: [],
      );
    }
    try {
      final localCode = _scope == RankingScope.local ? countryCode : null;
      final entries = await _leaderboardService.fetchTopEntries(
        dateKey: dateKey,
        difficulty: _difficulty,
        countryCode: localCode,
      );
      return LeaderboardFetchResult(
        status: LeaderboardStatus.ok,
        entries: entries,
      );
    } catch (error) {
      return const LeaderboardFetchResult(
        status: LeaderboardStatus.error,
        entries: [],
      );
    }
  }

  void _refreshLeaderboards(ProfileController controller, {bool force = false}) {
    setState(() {
      _leaderboardFuture =
          _resolveLeaderboardFuture(controller, force: force);
    });
  }

  String _selectedDateKey() {
    final now = DateTime.now();
    if (_dateFilter == DateFilter.today) {
      return buildDailyKeyUtc(now: now);
    }
    return buildDailyKeyUtc(now: now.subtract(const Duration(days: 1)));
  }

  String _cacheKey(UserProfile? profile) {
    final countryCode = _scope == RankingScope.local
        ? (profile?.countryCode ?? '')
        : '';
    return '${_selectedDateKey()}|${_difficulty.name}|${_scope.name}|$countryCode';
  }

  Future<LeaderboardFetchResult> _resolveLeaderboardFuture(
    ProfileController controller, {
    bool force = false,
  }) {
    final key = _cacheKey(controller.profile);
    if (force) {
      _cache.remove(key);
    }
    final cached = _cache[key];
    if (cached != null) {
      if (cached.result != null &&
          DateTime.now().difference(cached.fetchedAt) < _cacheTtl) {
        return Future.value(cached.result);
      }
      if (DateTime.now().difference(cached.fetchedAt) < _cacheTtl) {
        return cached.future;
      }
    }
    final future = _loadLeaderboard(profile: controller.profile);
    final entry = _LeaderboardCacheEntry(
      future: future,
      fetchedAt: DateTime.now(),
    );
    _cache[key] = entry;
    future.then((result) {
      _cache[key] = _LeaderboardCacheEntry(
        future: Future.value(result),
        fetchedAt: DateTime.now(),
        result: result,
      );
    });
    return future;
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
                        dateFilter: _dateFilter,
                        difficulty: _difficulty,
                        onScopeChanged: (value) {
                          _scope = value;
                          _refreshLeaderboards(controller);
                        },
                        onDateFilterChanged: (value) {
                          _dateFilter = value;
                          _refreshLeaderboards(controller);
                        },
                        onDifficultyChanged: (value) {
                          _difficulty = value;
                          _refreshLeaderboards(controller);
                        },
                        onRefresh: () => _refreshLeaderboards(
                          controller,
                          force: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LeaderboardSections(
                        future: _leaderboardFuture,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}


class _LeaderboardControls extends StatelessWidget {
  const _LeaderboardControls({
    required this.scope,
    required this.dateFilter,
    required this.difficulty,
    required this.onScopeChanged,
    required this.onDateFilterChanged,
    required this.onDifficultyChanged,
    required this.onRefresh,
  });

  final RankingScope scope;
  final DateFilter dateFilter;
  final SudokuDifficulty difficulty;
  final ValueChanged<RankingScope> onScopeChanged;
  final ValueChanged<DateFilter> onDateFilterChanged;
  final ValueChanged<SudokuDifficulty> onDifficultyChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RankingHeader(
          title: 'Ranking',
          dateFilter: dateFilter,
          scope: scope,
          onDateFilterChanged: onDateFilterChanged,
          onScopeChanged: onScopeChanged,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RankingDifficultySegment(
                value: difficulty,
                onChanged: onDifficultyChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          height: 16,
          color: colorScheme.outlineVariant.withValues(alpha: 120),
        ),
      ],
    );
  }
}

class _LeaderboardSections extends StatelessWidget {
  const _LeaderboardSections({
    required this.future,
  });

  final Future<LeaderboardFetchResult>? future;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final future = this.future;
    if (future == null) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<LeaderboardFetchResult>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: _RankingShimmer(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(loc.errorGeneric),
          );
        }
        final result = snapshot.data ??
            const LeaderboardFetchResult(
              status: LeaderboardStatus.error,
              entries: [],
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
        return _LeaderboardSection(
          title: '',
          entries: result.entries,
          showHeader: false,
        );
      },
    );
  }
}

class _LeaderboardCacheEntry {
  _LeaderboardCacheEntry({
    required this.future,
    required this.fetchedAt,
    this.result,
  });

  final Future<LeaderboardFetchResult> future;
  DateTime fetchedAt;
  final LeaderboardFetchResult? result;
}

enum LeaderboardStatus { ok, authRequired, missingCountry, error }

class LeaderboardFetchResult {
  const LeaderboardFetchResult({
    required this.status,
    required this.entries,
  });

  final LeaderboardStatus status;
  final List<LeaderboardEntry> entries;
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.title,
    required this.entries,
    this.showHeader = true,
  });

  final String title;
  final List<LeaderboardEntry> entries;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  entries.isEmpty ? '—' : '${entries.length}',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
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
                for (var index = 0; index < entries.length; index += 1) ...[
                  _LeaderboardRow(
                    rank: index + 1,
                    entry: entries[index],
                  ),
                  if (index != entries.length - 1)
                    Divider(
                      height: 16,
                      color: colorScheme.outlineVariant.withValues(alpha: 153),
                    ),
                ],
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
    final Color badgeColor;
    final Color badgeTextColor;
    switch (rank) {
      case 1:
        badgeColor = colorScheme.primary;
        badgeTextColor = colorScheme.onPrimary;
        break;
      case 2:
        badgeColor = colorScheme.tertiary;
        badgeTextColor = colorScheme.onTertiary;
        break;
      case 3:
        badgeColor = colorScheme.secondary;
        badgeTextColor = colorScheme.onSecondary;
        break;
      default:
        badgeColor = colorScheme.outlineVariant;
        badgeTextColor = colorScheme.onSurfaceVariant;
    }
    final medalColor = _medalColorForEntry(entry.medal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: rank <= 3 ? 230 : 64),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: badgeTextColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _flagForCountry(entry.countryCode),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                StatisticsViewModel.formatDuration(entry.elapsedSeconds),
                style: textTheme.bodySmall?.copyWith(
                  fontFeatures: [StatisticsViewModel.tabularFigures()],
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (medalColor != null)
                Container(
                  width: 28,
                  height: 6,
                  decoration: BoxDecoration(
                    color: medalColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color? _medalColorForEntry(String medal) {
    switch (medal) {
      case 'gold':
        return const Color(0xFFF6C453);
      case 'silver':
        return const Color(0xFFC0C7D1);
      case 'bronze':
        return const Color(0xFFD09B6A);
      default:
        return null;
    }
  }

  String _flagForCountry(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length != 2) {
      return '—';
    }
    final first = trimmed.codeUnitAt(0);
    final second = trimmed.codeUnitAt(1);
    if (first < 65 || first > 90 || second < 65 || second > 90) {
      return '—';
    }
    return String.fromCharCodes(
      [0x1F1E6 + (first - 65), 0x1F1E6 + (second - 65)],
    );
  }
}

class _RankingShimmer extends StatelessWidget {
  const _RankingShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.surfaceContainerHighest;
    final highlight = colorScheme.surfaceContainerLow;
    return _Shimmer(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 128),
          ),
        ),
        child: Column(
          children: const [
            _ShimmerRow(),
            SizedBox(height: 12),
            Divider(height: 16),
            _ShimmerRow(),
            SizedBox(height: 12),
            Divider(height: 16),
            _ShimmerRow(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: base,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 10,
                width: 28,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 10,
              width: 48,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 28,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final slide = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1.0 + slide, 0),
              end: Alignment(1.0 + slide, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

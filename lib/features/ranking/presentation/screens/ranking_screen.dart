import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:country_picker/country_picker.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../daily_sudoku/shared/daily_key.dart';
import '../../../profile/application/usecases/load_user_profile.dart';
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
import '../widgets/ranking_loading_widget.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with AutomaticKeepAliveClientMixin {
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const Duration _refreshCooldown = Duration(seconds: 10);
  static final Map<String, _LeaderboardCacheEntry> _cache = {};

  ProfileController? _controller;
  Locale? _locale;
  bool _isLoadingController = false;
  final LeaderboardService _leaderboardService = LeaderboardService();
  RankingScope _scope = RankingScope.global;
  DateFilter _dateFilter = DateFilter.today;
  SudokuDifficulty _difficulty = SudokuDifficulty.easy;
  Future<LeaderboardFetchResult>? _leaderboardFuture;
  DateTime? _lastRefreshAt;

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
    bool isSaving = false;
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
                    maxLength: 16,
                    enabled: !isSaving,
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
                    onPressed: isSaving
                        ? null
                        : () async {
                            setState(() => isSaving = true);
                            try {
                      final trimmed = textController.text.trim();
                      if (trimmed.isEmpty) {
                        setState(
                          () => errorText = loc.profileDisplayNameInvalid,
                        );
                        return;
                      }
                      final check = await _checkDisplayName(trimmed);
                      if (!check.allowed) {
                        final reason = check.reason;
                        setState(
                          () => errorText = switch (reason) {
                            _NameCheckReason.unavailable =>
                              loc.profileDisplayNameCheckUnavailable,
                            _NameCheckReason.taken =>
                              loc.profileDisplayNameTakenError,
                            _NameCheckReason.notAllowed =>
                              loc.profileDisplayNameNotAllowed,
                            _ => loc.profileDisplayNameNotAllowed,
                          },
                        );
                        return;
                      }
                      await controller.updateDisplayName(trimmed);
                      if (!context.mounted) {
                        return;
                      }
                      if (controller.isDisplayNameTaken) {
                        setState(
                          () => errorText = loc.profileDisplayNameTakenError,
                        );
                        return;
                      }
                      final syncService =
                          await widget.dependencies.firebaseSyncService;
                      await syncService.uploadAllLocalResults(
                        profile: controller.profile,
                      );
                      if (context.mounted) {
                        _refreshLeaderboards(controller, force: true);
                      }
                      Navigator.of(context).pop();
                            } finally {
                              if (context.mounted) {
                                setState(() => isSaving = false);
                              }
                            }
                    },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(loc.save),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<_NameCheckResult> _checkDisplayName(String name) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('validateDisplayName');
      final result = await callable.call({'displayName': name});
      final data = result.data;
      if (data is Map) {
        final allowed = data['allowed'] == true;
        final reason = data['reason'] as String?;
        return _NameCheckResult(
          allowed: allowed,
          reason: _NameCheckReasonParser.fromString(reason),
        );
      }
      return const _NameCheckResult(
        allowed: false,
        reason: _NameCheckReason.unavailable,
      );
    } on FirebaseFunctionsException {
      return const _NameCheckResult(
        allowed: false,
        reason: _NameCheckReason.unavailable,
      );
    } catch (_) {
      return const _NameCheckResult(
        allowed: false,
        reason: _NameCheckReason.unavailable,
      );
    }
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
    if (force && !_canRefresh()) {
      setState(() {
        _leaderboardFuture = _resolveLeaderboardFuture(controller, force: false);
      });
      return;
    }
    if (force) {
      _lastRefreshAt = DateTime.now();
    }
    setState(() {
      _leaderboardFuture = _resolveLeaderboardFuture(
        controller,
        force: force,
      );
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

  bool _canRefresh() {
    final last = _lastRefreshAt;
    if (last == null) {
      return true;
    }
    return DateTime.now().difference(last) >= _refreshCooldown;
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
      if (!identical(_cache[key], entry)) {
        return;
      }
      _cache[key] = _LeaderboardCacheEntry(
        future: Future.value(result),
        fetchedAt: DateTime.now(),
        result: result,
      );
    });
    return future;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context)!;
    final controller = _controller;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: controller == null
            ? const Padding(
                padding: EdgeInsets.only(top: 16),
                child: RankingLoadingWidget(),
              )
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

  @override
  bool get wantKeepAlive => true;
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
            child: RankingLoadingWidget(),
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
    final content = Column(
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: entries.isEmpty
              ? _EmptyPlaceholder(text: loc.rankingEmpty)
              : Column(
                  key: const ValueKey('rows'),
                  children: [
                    for (var index = 0; index < entries.length; index += 1) ...[
                      _LeaderboardRow(
                        rank: index + 1,
                        entry: entries[index],
                      ),
                      if (index != entries.length - 1)
                        Divider(
                          height: 16,
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 153),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 128),
        ),
      ),
      child: content,
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      key: const ValueKey('empty'),
      height: 120,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
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
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
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

class _NameCheckResult {
  const _NameCheckResult({
    required this.allowed,
    this.reason,
  });

  final bool allowed;
  final _NameCheckReason? reason;
}

enum _NameCheckReason { notAllowed, unavailable, taken }

class _NameCheckReasonParser {
  static _NameCheckReason? fromString(String? value) {
    switch (value) {
      case 'blocked':
        return _NameCheckReason.notAllowed;
      case 'rate_limited':
        return _NameCheckReason.unavailable;
      case 'service_unavailable':
        return _NameCheckReason.unavailable;
      case 'taken':
        return _NameCheckReason.taken;
      case 'invalid_chars':
      case 'too_long':
      case 'flagged':
      case 'blocked':
        return _NameCheckReason.notAllowed;
      default:
        return null;
    }
  }
}

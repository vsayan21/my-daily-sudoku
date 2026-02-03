import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../active_game/application/usecases/clear_active_game.dart';
import '../../../active_game/application/usecases/load_active_game.dart';
import '../../../active_game/application/usecases/reset_active_game_for.dart';
import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../active_game/domain/repositories/active_game_repository.dart';
import '../../../active_game/presentation/widgets/active_game_card.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../daily_sudoku/domain/entities/daily_sudoku.dart';
import '../../../daily_sudoku/shared/daily_key.dart';
import '../../../streak/presentation/streak_section.dart';
import '../../../streak/application/usecases/get_streak_summary.dart';
import '../../../sudoku_play/presentation/screens/sudoku_play_screen.dart';
import '../../../sudoku_play/shared/sudoku_play_args.dart';
import '../../../statistics/application/usecases/get_game_result_for_day.dart';
import '../../../statistics/data/datasources/statistics_local_datasource.dart';
import '../../../statistics/data/repositories/statistics_repository_impl.dart';
import '../../../statistics/domain/entities/game_result.dart';
import '../../domain/models/difficulty_option.dart';
import '../models/difficulty_tile_state.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/difficulty_card.dart';
import '../widgets/page_header.dart';
import '../../../ranking/presentation/screens/ranking_screen.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../../../firebase/firebase_sync_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _currentTab = 0;
  late final PageController _pageController;
  late final Future<ActiveGameRepository> _activeGameRepository;
  late final Future<StatisticsRepositoryImpl> _statisticsRepository;
  late final Future<FirebaseSyncService> _firebaseSyncService;
  ActiveGameSession? _activeSession;
  Map<SudokuDifficulty, GameResult?> _todayResults = {};
  StreakSummary _streakSummary = StreakSummary.empty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _currentTab);
    _activeGameRepository = widget.dependencies.activeGameRepository;
    _statisticsRepository = _buildStatisticsRepository();
    _firebaseSyncService = widget.dependencies.firebaseSyncService;
    _syncFirebase();
    _refreshHomeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshHomeData();
    }
  }

  List<DifficultyOption> _buildOptions(AppLocalizations loc) {
    return [
      DifficultyOption(
        title: loc.difficultyEasy,
        icon: Icons.wb_sunny_outlined,
      ),
      DifficultyOption(
        title: loc.difficultyMedium,
        icon: Icons.auto_graph,
      ),
      DifficultyOption(
        title: loc.difficultyHard,
        icon: Icons.bolt_outlined,
      ),
    ];
  }

  SudokuDifficulty _difficultyForIndex(int index) {
    switch (index) {
      case 0:
        return SudokuDifficulty.easy;
      case 1:
        return SudokuDifficulty.medium;
      case 2:
        return SudokuDifficulty.hard;
      default:
        return SudokuDifficulty.easy;
    }
  }

  Future<DailySudoku> _loadDailySelection(SudokuDifficulty difficulty) async {
    return widget.dependencies.todaySudokuUseCase.execute(difficulty);
  }

  Future<StatisticsRepositoryImpl> _buildStatisticsRepository() async {
    final preferences = await widget.dependencies.sharedPreferences;
    return StatisticsRepositoryImpl(
      dataSource: StatisticsLocalDataSource(preferences),
    );
  }

  Future<SudokuPlayArgs> _loadDailyPuzzle(SudokuDifficulty difficulty) async {
    final selection = await _loadDailySelection(difficulty);
    return SudokuPlayArgs(
      difficulty: difficulty,
      puzzleId: selection.id,
      puzzleString: selection.puzzle,
      solutionString: selection.solution,
      dailyKey: selection.dateKey,
    );
  }

  Future<ActiveGameSession?> _loadActiveSession() async {
    final repository = await _activeGameRepository;
    final loader = LoadActiveGame(repository: repository);
    return loader.execute();
  }

  Future<Map<SudokuDifficulty, GameResult?>> _loadTodayResults() async {
    final repository = await _statisticsRepository;
    final useCase = GetGameResultForDay(repository: repository);
    final dateKey = _todayKey();
    final results = <SudokuDifficulty, GameResult?>{};
    for (final difficulty in SudokuDifficulty.values) {
      results[difficulty] = await useCase.execute(
        dateKey: dateKey,
        difficultyKey: difficulty.name,
      );
    }
    return results;
  }

  String _todayKey() => buildDailyKey();

  bool _isSessionForToday(ActiveGameSession? session) {
    if (session == null) {
      return false;
    }
    return session.dateKey == _todayKey();
  }

  bool _isValidActiveSession(
    ActiveGameSession? session, {
    required SudokuDifficulty selected,
  }) {
    if (!_isSessionForToday(session)) {
      return false;
    }
    return session?.difficulty == selected;
  }

  Future<void> _clearStaleSessionIfNeeded() async {
    final session = _activeSession;
    if (session == null || _isSessionForToday(session)) {
      return;
    }
    final repository = await _activeGameRepository;
    final clearUseCase = ClearActiveGame(repository: repository);
    await clearUseCase.execute();
    if (!mounted) {
      return;
    }
    setState(() => _activeSession = null);
  }

  Future<StreakSummary> _loadStreakSummary() async {
    final preferences = await widget.dependencies.sharedPreferences;
    final useCase = GetStreakSummary(preferences: preferences);
    return useCase.execute();
  }

  Future<void> _syncFirebase() async {
    final service = await _firebaseSyncService;
    final profile = await service.ensureUserProfileExistsAndSynced();
    await service.uploadAllLocalResults(profile: profile);
  }

  Future<void> _refreshHomeData() async {
    final session = await _loadActiveSession();
    ActiveGameSession? updatedSession = session;
    if (session != null && !_isSessionForToday(session)) {
      final repository = await _activeGameRepository;
      final clearUseCase = ClearActiveGame(repository: repository);
      await clearUseCase.execute();
      updatedSession = null;
    }
    final todayResults = await _loadTodayResults();
    final streakSummary = await _loadStreakSummary();
    if (!mounted) {
      return;
    }
    setState(() {
      _activeSession = updatedSession;
      _todayResults = todayResults;
      _streakSummary = streakSummary;
    });
  }

  String _difficultyLabel(AppLocalizations loc, SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return loc.difficultyEasy;
      case SudokuDifficulty.medium:
        return loc.difficultyMedium;
      case SudokuDifficulty.hard:
        return loc.difficultyHard;
    }
  }

  Future<void> _openPlayScreen({
    required SudokuPlayArgs args,
    ActiveGameSession? session,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SudokuPlayScreen(
          args: args,
          initialSession: session,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _refreshHomeData();
  }

  Future<void> _handleStart() async {
    final difficulty = _difficultyForIndex(_selectedIndex);
    if (_todayResults[difficulty] != null) {
      final repository = await _activeGameRepository;
      final resetUseCase = ResetActiveGameFor(repository: repository);
      await resetUseCase.execute(
        dateKey: _todayKey(),
        difficulty: difficulty,
      );
      final args = await _loadDailyPuzzle(difficulty);
      if (!mounted) {
        return;
      }
      await _openPlayScreen(args: args);
      return;
    }
    final session = _activeSession;
    if (_isValidActiveSession(session, selected: difficulty)) {
      final selection = await _loadDailySelection(session!.difficulty);
      if (!mounted) {
        return;
      }
      final args = SudokuPlayArgs(
        difficulty: session.difficulty,
        puzzleId: session.puzzleId ?? 'active',
        puzzleString: session.puzzle,
        solutionString: selection.solution,
        dailyKey: session.dateKey,
      );
      await _openPlayScreen(args: args, session: session);
      return;
    }
    if (session != null && !_isSessionForToday(session)) {
      await _clearStaleSessionIfNeeded();
    }
    final args = await _loadDailyPuzzle(difficulty);
    if (!mounted) {
      return;
    }
    await _openPlayScreen(args: args);
  }

  Future<void> _handleContinue(ActiveGameSession session) async {
    if (!_isSessionForToday(session)) {
      await _clearStaleSessionIfNeeded();
      return;
    }
    final selection = await _loadDailySelection(session.difficulty);
    if (!mounted) {
      return;
    }
    final args = SudokuPlayArgs(
      difficulty: session.difficulty,
      puzzleId: session.puzzleId ?? 'active',
      puzzleString: session.puzzle,
      solutionString: selection.solution,
      dailyKey: session.dateKey,
    );
    await _openPlayScreen(args: args, session: session);
  }

  Future<void> _handleReset() async {
    final repository = await _activeGameRepository;
    final clearUseCase = ClearActiveGame(repository: repository);
    await clearUseCase.execute();
    if (!mounted) {
      return;
    }
    setState(() => _activeSession = null);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final options = _buildOptions(loc);
    final activeSession = _activeSession;
    final selectedDifficulty = _difficultyForIndex(_selectedIndex);
    final isSelectedSolved = _todayResults[selectedDifficulty] != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentTab = index;
                  });
                },
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PageHeader(title: loc.appTitle),
                        const SizedBox(height: 16),
                        StreakSection(summary: _streakSummary),
                        if (activeSession != null) ...[
                          const SizedBox(height: 12),
                          ActiveGameCard(
                            difficultyLabel: _difficultyLabel(loc, activeSession.difficulty),
                            dateKey: activeSession.dateKey,
                            elapsedSeconds: activeSession.elapsedSeconds,
                            isPaused: activeSession.isPaused,
                            onContinue: () => _handleContinue(activeSession),
                            onReset: _handleReset,
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (activeSession == null) ...[
                          const SizedBox(height: 24),
                          Text(
                            loc.selectDifficultyTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          ...options.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DifficultyCard(
                                    option: entry.value,
                                    isSelected: _selectedIndex == entry.key,
                                    tileState: _buildTileState(
                                      difficulty:
                                          _difficultyForIndex(entry.key),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _selectedIndex = entry.key,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _handleStart,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(
                              isSelectedSolved ? loc.tryAgain : loc.start,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                  const StatisticsScreen(),
                  RankingScreen(dependencies: widget.dependencies),
                ],
              ),
            ),
            BottomNavigation(
              currentIndex: _currentTab,
              onDestinationSelected: (index) {
                setState(() => _currentTab = index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  DifficultyTileState _buildTileState({
    required SudokuDifficulty difficulty,
  }) {
    final result = _todayResults[difficulty];
    if (result == null) {
      return DifficultyTileState(
        difficulty: difficulty,
        isSolvedToday: false,
      );
    }
    return DifficultyTileState(
      difficulty: difficulty,
      isSolvedToday: true,
      timeLabel: _formatDuration(result.elapsedSeconds),
      medal: result.medal,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }
}

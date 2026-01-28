import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/active_game/application/usecases/load_active_game.dart';
import '../features/active_game/application/usecases/reset_active_game.dart';
import '../features/active_game/data/datasources/active_game_local_datasource.dart';
import '../features/active_game/data/repositories/active_game_repository_impl.dart';
import '../features/active_game/domain/entities/active_game_session.dart';
import '../features/active_game/domain/repositories/active_game_repository.dart';
import '../features/active_game/presentation/widgets/active_game_card.dart';
import '../features/daily_sudoku/application/usecases/get_today_sudoku.dart';
import '../features/daily_sudoku/data/datasources/sudoku_assets_datasource.dart';
import '../features/daily_sudoku/data/repositories/daily_sudoku_repository_impl.dart';
import '../features/daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../features/daily_sudoku/shared/daily_key.dart';
import '../models/difficulty_option.dart';
import '../screens/profile_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/difficulty_card.dart';
import '../features/streak/presentation/streak_section.dart';
import '../features/sudoku_play/presentation/screens/sudoku_play_screen.dart';
import '../features/sudoku_play/shared/sudoku_play_args.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedIndex = 0;
  int _currentTab = 0;
  late final PageController _pageController;
  late final GetTodaySudoku _getTodaySudoku;
  late final Future<ActiveGameRepository> _activeGameRepository;
  ActiveGameSession? _activeSession;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentTab);
    _getTodaySudoku = GetTodaySudoku(
      repository: DailySudokuRepositoryImpl(
        dataSource: SudokuAssetsDataSource(),
      ),
    );
    _activeGameRepository = _buildActiveGameRepository();
    _refreshActiveSession();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Future<SudokuPlayArgs> _loadDailyPuzzle(SudokuDifficulty difficulty) async {
    final selection = await _getTodaySudoku.execute(difficulty);
    return SudokuPlayArgs(
      difficulty: difficulty,
      puzzleId: selection.id,
      puzzleString: selection.puzzle,
      dailyKey: selection.dateKey,
    );
  }

  Future<ActiveGameRepository> _buildActiveGameRepository() async {
    final preferences = await SharedPreferences.getInstance();
    return ActiveGameRepositoryImpl(
      dataSource: ActiveGameLocalDataSource(preferences),
    );
  }

  Future<void> _refreshActiveSession() async {
    final repository = await _activeGameRepository;
    final loader = LoadActiveGame(repository: repository);
    final session = await loader.execute();
    if (!mounted) {
      return;
    }
    setState(() => _activeSession = session);
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

  bool _hasActiveForDifficulty(SudokuDifficulty difficulty) {
    final session = _activeSession;
    if (session == null) {
      return false;
    }
    return session.difficulty == difficulty;
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
    await _refreshActiveSession();
  }

  Future<void> _handleStart() async {
    final difficulty = _difficultyForIndex(_selectedIndex);
    final session = _activeSession;
    if (session != null && session.difficulty == difficulty) {
      final args = SudokuPlayArgs(
        difficulty: session.difficulty,
        puzzleId: session.puzzleId ?? 'active',
        puzzleString: session.puzzle,
        dailyKey: session.dateKey,
      );
      await _openPlayScreen(args: args, session: session);
      return;
    }
    final args = await _loadDailyPuzzle(difficulty);
    if (!mounted) {
      return;
    }
    await _openPlayScreen(args: args);
  }

  Future<void> _handleContinue(ActiveGameSession session) async {
    final args = SudokuPlayArgs(
      difficulty: session.difficulty,
      puzzleId: session.puzzleId ?? 'active',
      puzzleString: session.puzzle,
      dailyKey: session.dateKey,
    );
    await _openPlayScreen(args: args, session: session);
  }

  Future<void> _handleNewGame(ActiveGameSession session) async {
    final repository = await _activeGameRepository;
    final resetUseCase = ResetActiveGame(repository: repository);
    final refreshed = await resetUseCase.execute(session);
    if (!mounted) {
      return;
    }
    final args = SudokuPlayArgs(
      difficulty: refreshed.difficulty,
      puzzleId: refreshed.puzzleId ?? 'active',
      puzzleString: refreshed.puzzle,
      dailyKey: refreshed.dateKey,
    );
    await _openPlayScreen(args: args, session: refreshed);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final options = _buildOptions(loc);
    final colorScheme = Theme.of(context).colorScheme;
    final activeSession = _activeSession;
    final todayKey = buildDailyKey();
    final hasActive = activeSession != null && activeSession.dateKey == todayKey;
    final hasActiveForSelected =
        hasActive && _hasActiveForDifficulty(_difficultyForIndex(_selectedIndex));
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentTab = index);
            },
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StreakSection(),
                  const SizedBox(height: 24),
                  Text(
                    loc.dailySudokuTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.dailySudokuSubtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  if (hasActive)
                    ActiveGameCard(
                      difficultyLabel:
                          _difficultyLabel(loc, activeSession!.difficulty),
                      dateKey: activeSession.dateKey,
                      elapsedSeconds: activeSession.elapsedSeconds,
                      isPaused: activeSession.isPaused,
                      onContinue: () => _handleContinue(activeSession),
                      onNewGame: () => _handleNewGame(activeSession),
                    ),
                  SizedBox(height: hasActive ? 16 : 24),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DifficultyCard(
                            option: option,
                            isSelected: _selectedIndex == index,
                            onPressed: () {
                              setState(() => _selectedIndex = index);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              const StatisticsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentTab,
        onDestinationSelected: (index) {
          setState(() => _currentTab = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        },
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              onPressed: _handleStart,
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icon(
                hasActiveForSelected
                    ? Icons.play_circle_fill_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(hasActiveForSelected ? 'Continue' : loc.start),
              shape: const StadiumBorder(),
              elevation: 2,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../active_game/application/usecases/clear_active_game.dart';
import '../../../active_game/application/usecases/load_active_game.dart';
import '../../../active_game/domain/entities/active_game_session.dart';
import '../../../active_game/domain/repositories/active_game_repository.dart';
import '../../../active_game/presentation/widgets/active_game_card.dart';
import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../daily_sudoku/shared/daily_key.dart';
import '../../../streak/presentation/streak_section.dart';
import '../../../sudoku_play/presentation/screens/sudoku_play_screen.dart';
import '../../../sudoku_play/shared/sudoku_play_args.dart';
import '../../domain/models/difficulty_option.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/difficulty_card.dart';
import '../widgets/page_header.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';

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
  ActiveGameSession? _activeSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _currentTab);
    _activeGameRepository = widget.dependencies.activeGameRepository;
    _refreshActiveSession();
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
      _clearStaleSessionIfNeeded();
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

  Future<SudokuPlayArgs> _loadDailyPuzzle(SudokuDifficulty difficulty) async {
    final selection = await widget.dependencies.todaySudokuUseCase
        .execute(difficulty);
    return SudokuPlayArgs(
      difficulty: difficulty,
      puzzleId: selection.id,
      puzzleString: selection.puzzle,
      dailyKey: selection.dateKey,
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
    await _refreshActiveSession();
  }

  Future<void> _handleStart() async {
    final difficulty = _difficultyForIndex(_selectedIndex);
    final session = _activeSession;
    if (_isValidActiveSession(session, selected: difficulty)) {
      final args = SudokuPlayArgs(
        difficulty: session!.difficulty,
        puzzleId: session.puzzleId ?? 'active',
        puzzleString: session.puzzle,
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
    final args = SudokuPlayArgs(
      difficulty: session.difficulty,
      puzzleId: session.puzzleId ?? 'active',
      puzzleString: session.puzzle,
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
                        const PageHeader(title: 'MyDailySudoku'),
                        const SizedBox(height: 16),
                        const StreakSection(),
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
                            label: Text(loc.start),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                  const StatisticsScreen(),
                  const ProfileScreen(),
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
}

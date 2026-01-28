import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../features/daily_sudoku/application/usecases/get_today_sudoku.dart';
import '../features/daily_sudoku/data/datasources/sudoku_assets_datasource.dart';
import '../features/daily_sudoku/data/repositories/daily_sudoku_repository_impl.dart';
import '../features/daily_sudoku/domain/entities/sudoku_difficulty.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentTab);
    _getTodaySudoku = GetTodaySudoku(
      repository: DailySudokuRepositoryImpl(
        dataSource: SudokuAssetsDataSource(),
      ),
    );
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

  Future<void> _handleStart() async {
    final difficulty = _difficultyForIndex(_selectedIndex);
    final args = await _loadDailyPuzzle(difficulty);
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SudokuPlayScreen(args: args),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final options = _buildOptions(loc);
    final colorScheme = Theme.of(context).colorScheme;
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
                  const SizedBox(height: 24),
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
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(loc.start),
              shape: const StadiumBorder(),
              elevation: 2,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

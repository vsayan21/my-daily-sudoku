import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../shared/success_screen_args.dart';
import '../widgets/confetti_layer.dart';
import '../widgets/stat_tiles_row.dart';
import '../widgets/streak_pill.dart';
import '../widgets/success_hero.dart';
import '../widgets/time_result_card.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    super.key,
    required this.args,
  });

  final SuccessScreenArgs args;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _animationController;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _timeScale;
  late final Animation<double> _tilesOpacity;
  late final Animation<double> _streakOpacity;

  static const double _maxContentWidth = 420;
  static const Duration _introDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    )..play();
    _animationController = AnimationController(
      vsync: this,
      duration: _introDuration,
    );
    final curved = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _heroOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);
    _timeScale = Tween<double>(begin: 0.98, end: 1).animate(curved);
    _tilesOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
    );
    _streakOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final args = widget.args;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            ConfettiLayer(controller: _confettiController),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxContentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SlideTransition(
                              position: _heroSlide,
                              child: FadeTransition(
                                opacity: _heroOpacity,
                                child: SuccessHero(
                                  title: loc.successSolvedTitle,
                                  subtitle:
                                      '${_difficultyLabel(loc, args.difficulty)} · ${args.dateKey}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            ScaleTransition(
                              scale: _timeScale,
                              child: TimeResultCard(
                                difficulty: args.difficulty,
                                elapsedSeconds: args.elapsedSeconds,
                                medal: args.medal,
                              ),
                            ),
                            const SizedBox(height: 18),
                            FadeTransition(
                              opacity: _tilesOpacity,
                              child: StatTilesRow(
                                hintsUsed: args.hintsUsed,
                                movesCount: args.movesCount,
                                undoCount: args.undoCount,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _streakOpacity,
                              child: StreakPill(
                                label: _streakLabel(loc, args.streakCount),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(loc.done),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _streakLabel(AppLocalizations loc, int count) {
    return loc.streakLabel(count);
  }

}

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../medals/domain/medal.dart';
import '../../shared/success_screen_args.dart';
import '../widgets/confetti_layer.dart';
import '../widgets/stat_tiles_row.dart';
import '../widgets/streak_pill.dart';
import '../widgets/success_hero.dart';
import '../widgets/time_highlight_card.dart';

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
    final args = widget.args;
    final medalLabel = formatMedalLabel(args.medal);
    const heroTitle = 'Solved!';
    const timeLabel = 'Time';
    const doneLabel = 'Done';
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
                                  title: heroTitle,
                                  subtitle:
                                      '${_difficultyLabel(args.difficulty)} · ${args.dateKey}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            ScaleTransition(
                              scale: _timeScale,
                              child: TimeHighlightCard(
                                label: timeLabel,
                                value: _formatDuration(args.elapsedSeconds),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FadeTransition(
                              opacity: _tilesOpacity,
                              child: _MedalBadge(
                                label: medalLabel,
                                color: _medalColor(theme, args.medal),
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
                                label: _streakLabel(args.streakCount),
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
                        child: Text(doneLabel),
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

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  String _difficultyLabel(SudokuDifficulty difficulty) {
    return difficulty.label;
  }

  String _streakLabel(int count) {
    if (count <= 1) {
      return 'Streak started: 1 day';
    }
    return 'Streak: $count days';
  }

  Color _medalColor(ThemeData theme, Medal medal) {
    final scheme = theme.colorScheme;
    switch (medal) {
      case Medal.gold:
        return scheme.tertiary;
      case Medal.silver:
        return scheme.secondary;
      case Medal.bronze:
        return scheme.primary;
    }
  }
}

class _MedalBadge extends StatelessWidget {
  const _MedalBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

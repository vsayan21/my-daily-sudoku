// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Daily Sudoku';

  @override
  String get start => 'Start';

  @override
  String get today => 'Today';

  @override
  String get solved => 'Solved';

  @override
  String get cancel => 'Cancel';

  @override
  String get streakTitle => 'Day Streak';

  @override
  String get streakSubtitleSolved => 'Done for today';

  @override
  String get streakSubtitleOpen => 'Solve today to keep your streak';

  @override
  String get dailySudokuTitle => 'Your daily Sudoku';

  @override
  String get dailySudokuSubtitle => 'Choose a level and start right away';

  @override
  String get todaysEasy => 'Today\'s Easy Sudoku';

  @override
  String get todaysMedium => 'Today\'s Medium Sudoku';

  @override
  String get todaysHard => 'Today\'s Hard Sudoku';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationStatistics => 'Statistics';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get sudoku => 'Sudoku';

  @override
  String get activeGameContinueTitle => 'Continue your Sudoku';

  @override
  String activeGameStatusPaused(String elapsed) {
    return 'Paused · $elapsed';
  }

  @override
  String get activeGameStatusInProgress => 'In progress';

  @override
  String get activeGameContinue => 'Continue';

  @override
  String get activeGameReset => 'Reset';

  @override
  String get sudokuActionHint => 'Hint';

  @override
  String get sudokuActionErase => 'Erase';

  @override
  String get sudokuActionUndo => 'Undo';
}

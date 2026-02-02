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
  String get selectDifficultyTitle => 'Select Difficulty';

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
  String activeGameStatusPaused(Object elapsed) {
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

  @override
  String get tryAgain => 'Try Again';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String debugPuzzleId(Object id) {
    return 'Puzzle ID: $id';
  }

  @override
  String debugRowLabel(Object row) {
    return 'Row 1: $row';
  }

  @override
  String get statsHintsUsed => 'Hints used';

  @override
  String get statsMoves => 'Moves';

  @override
  String get statsUndo => 'Undo';

  @override
  String get timeResultGoldAchieved => 'Gold achieved';

  @override
  String timeResultToGold(Object delta) {
    return '$delta to Gold';
  }

  @override
  String get medalGold => 'Gold';

  @override
  String get medalSilver => 'Silver';

  @override
  String get medalBronze => 'Bronze';

  @override
  String timeWithMedalSemantics(Object medal, num minutes, num seconds) {
    return '$medal medal, time ${intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      one: '1 minute',
      other: '$minutes minutes',
    )} ${intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      one: '1 second',
      other: '$seconds seconds',
    )}';
  }

  @override
  String get successSolvedTitle => 'Solved!';

  @override
  String get done => 'Done';

  @override
  String streakLabel(num count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'Streak started: 1 day',
      other: 'Streak: $count days',
    );
  }

  @override
  String get hintSolutionUnavailable => 'Solution unavailable';

  @override
  String get hintConflictsFound => 'Conflicts found';

  @override
  String get hintSelectEmptyCell => 'Select an empty cell';

  @override
  String get hintClearCellOrSelectEmpty =>
      'Clear the cell or select an empty one.';

  @override
  String get hintNoEmptyCells => 'No empty cells';

  @override
  String hintPenaltyLabel(Object seconds) {
    return '+$seconds sec';
  }
}

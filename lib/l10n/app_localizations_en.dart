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
  String get save => 'Save';

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
  String get navigationProfile => 'Ranking';

  @override
  String get rankingComingSoon => 'Ranking coming soon';

  @override
  String get rankingScopeGlobal => 'Global';

  @override
  String get rankingScopeLocal => 'Local';

  @override
  String get rankingDayToday => 'Today';

  @override
  String get rankingDayYesterday => 'Yesterday';

  @override
  String get rankingEmpty => 'No results yet.';

  @override
  String get rankingLocalRequiresCountry =>
      'Set a country to see the local leaderboard.';

  @override
  String get rankingAuthRequired => 'Sign in to see the leaderboard.';

  @override
  String get profileEditDisplayNameTitle => 'Edit display name';

  @override
  String get profileDisplayNameLabel => 'Display name';

  @override
  String get profileEditNameTooltip => 'Edit name';

  @override
  String get profileEditCountryTitle => 'Edit country';

  @override
  String get profileCountryLabel => 'Country';

  @override
  String get profileCountryHelper => 'Use 2-letter code (e.g., US)';

  @override
  String get profileCountryInvalidError => 'Enter a valid 2-letter code.';

  @override
  String get profileEditCountryTooltip => 'Edit country';

  @override
  String get profileCountryUnset => 'Not set';

  @override
  String get profileDisplayNameTakenError => 'Name already taken. Try another.';

  @override
  String get profileDisplayNameNotAllowed => 'Name not allowed.';

  @override
  String get profileDisplayNameInvalid => 'Please enter a valid name.';

  @override
  String get profileDisplayNameCheckUnavailable =>
      'Name check unavailable. Try again.';

  @override
  String get offlineSyncNotice =>
      'You are offline. Results will sync when you are back online.';

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
  String get restartGameTitle => 'Restart game?';

  @override
  String get restartGameMessage =>
      'This will clear your current progress and restart the timer.';

  @override
  String get restartGameConfirm => 'Restart';

  @override
  String get sudokuActionHint => 'Hint';

  @override
  String get sudokuActionNotes => 'Notes';

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
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return '$medal achievement, time $_temp0 $_temp1';
  }

  @override
  String get successSolvedTitle => 'Solved!';

  @override
  String get done => 'Done';

  @override
  String get checkLeaderboard => 'Ranking';

  @override
  String streakLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak: $count days',
      one: 'Streak started: 1 day',
    );
    return '$_temp0';
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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Daily Sudoku'**
  String get appTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solved;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get streakTitle;

  /// No description provided for @streakSubtitleSolved.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get streakSubtitleSolved;

  /// No description provided for @streakSubtitleOpen.
  ///
  /// In en, this message translates to:
  /// **'Solve today to keep your streak'**
  String get streakSubtitleOpen;

  /// No description provided for @dailySudokuTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily Sudoku'**
  String get dailySudokuTitle;

  /// No description provided for @dailySudokuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a level and start right away'**
  String get dailySudokuSubtitle;

  /// No description provided for @selectDifficultyTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficultyTitle;

  /// No description provided for @todaysEasy.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Easy Sudoku'**
  String get todaysEasy;

  /// No description provided for @todaysMedium.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Medium Sudoku'**
  String get todaysMedium;

  /// No description provided for @todaysHard.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Hard Sudoku'**
  String get todaysHard;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navigationStatistics;

  /// No description provided for @navigationProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @sudoku.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get sudoku;

  /// No description provided for @activeGameContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your Sudoku'**
  String get activeGameContinueTitle;

  /// No description provided for @activeGameStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused · {elapsed}'**
  String activeGameStatusPaused(Object elapsed);

  /// No description provided for @activeGameStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get activeGameStatusInProgress;

  /// No description provided for @activeGameContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get activeGameContinue;

  /// No description provided for @activeGameReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get activeGameReset;

  /// No description provided for @sudokuActionHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get sudokuActionHint;

  /// No description provided for @sudokuActionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sudokuActionNotes;

  /// No description provided for @sudokuActionErase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get sudokuActionErase;

  /// No description provided for @sudokuActionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get sudokuActionUndo;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @debugPuzzleId.
  ///
  /// In en, this message translates to:
  /// **'Puzzle ID: {id}'**
  String debugPuzzleId(Object id);

  /// No description provided for @debugRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Row 1: {row}'**
  String debugRowLabel(Object row);

  /// No description provided for @statsHintsUsed.
  ///
  /// In en, this message translates to:
  /// **'Hints used'**
  String get statsHintsUsed;

  /// No description provided for @statsMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get statsMoves;

  /// No description provided for @statsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get statsUndo;

  /// No description provided for @timeResultGoldAchieved.
  ///
  /// In en, this message translates to:
  /// **'Gold achieved'**
  String get timeResultGoldAchieved;

  /// No description provided for @timeResultToGold.
  ///
  /// In en, this message translates to:
  /// **'{delta} to Gold'**
  String timeResultToGold(Object delta);

  /// No description provided for @medalGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get medalGold;

  /// No description provided for @medalSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get medalSilver;

  /// No description provided for @medalBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get medalBronze;

  /// No description provided for @timeWithMedalSemantics.
  ///
  /// In en, this message translates to:
  /// **'{medal} achievement, time {minutes, plural, =1{1 minute} other{{minutes} minutes}} {seconds, plural, =1{1 second} other{{seconds} seconds}}'**
  String timeWithMedalSemantics(Object medal, num minutes, num seconds);

  /// No description provided for @successSolvedTitle.
  ///
  /// In en, this message translates to:
  /// **'Solved!'**
  String get successSolvedTitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Streak started: 1 day} other{Streak: {count} days}}'**
  String streakLabel(num count);

  /// No description provided for @hintSolutionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Solution unavailable'**
  String get hintSolutionUnavailable;

  /// No description provided for @hintConflictsFound.
  ///
  /// In en, this message translates to:
  /// **'Conflicts found'**
  String get hintConflictsFound;

  /// No description provided for @hintSelectEmptyCell.
  ///
  /// In en, this message translates to:
  /// **'Select an empty cell'**
  String get hintSelectEmptyCell;

  /// No description provided for @hintClearCellOrSelectEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clear the cell or select an empty one.'**
  String get hintClearCellOrSelectEmpty;

  /// No description provided for @hintNoEmptyCells.
  ///
  /// In en, this message translates to:
  /// **'No empty cells'**
  String get hintNoEmptyCells;

  /// No description provided for @hintPenaltyLabel.
  ///
  /// In en, this message translates to:
  /// **'+{seconds} sec'**
  String hintPenaltyLabel(Object seconds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

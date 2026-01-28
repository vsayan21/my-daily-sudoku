// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mein tägliches Sudoku';

  @override
  String get start => 'Start';

  @override
  String get today => 'Heute';

  @override
  String get solved => 'Gelöst';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get streakTitle => 'Tage in Folge';

  @override
  String get streakSubtitleSolved => 'Für heute erledigt';

  @override
  String get streakSubtitleOpen =>
      'Löse heute ein Sudoku, um deine Serie zu halten';

  @override
  String get dailySudokuTitle => 'Dein tägliches Sudoku';

  @override
  String get dailySudokuSubtitle => 'Wähle ein Level und leg direkt los.';

  @override
  String get todaysEasy => 'Heutiges leichtes Sudoku';

  @override
  String get todaysMedium => 'Heutiges mittleres Sudoku';

  @override
  String get todaysHard => 'Heutiges schweres Sudoku';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get navigationHome => 'Start';

  @override
  String get navigationStatistics => 'Statistik';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get comingSoon => 'Bald verfügbar';

  @override
  String get sudoku => 'Sudoku';
}

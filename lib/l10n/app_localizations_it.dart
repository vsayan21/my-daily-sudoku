// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Il mio Sudoku quotidiano';

  @override
  String get start => 'Inizia';

  @override
  String get today => 'Oggi';

  @override
  String get solved => 'Risolto';

  @override
  String get cancel => 'Annulla';

  @override
  String get streakTitle => 'Giorni consecutivi';

  @override
  String get streakSubtitleSolved => 'Fatto per oggi';

  @override
  String get streakSubtitleOpen =>
      'Risolvi un Sudoku oggi per mantenere la serie';

  @override
  String get dailySudokuTitle => 'Il tuo Sudoku quotidiano';

  @override
  String get dailySudokuSubtitle => 'Scegli un livello e inizia subito';

  @override
  String get todaysEasy => 'Il Sudoku facile di oggi';

  @override
  String get todaysMedium => 'Il Sudoku medio di oggi';

  @override
  String get todaysHard => 'Il Sudoku difficile di oggi';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get loading => 'Caricamento…';

  @override
  String get errorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationStatistics => 'Statistiche';

  @override
  String get navigationProfile => 'Profilo';

  @override
  String get comingSoon => 'In arrivo';

  @override
  String get sudoku => 'Sudoku';
}

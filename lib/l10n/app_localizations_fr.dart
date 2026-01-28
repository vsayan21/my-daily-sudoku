// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mon Sudoku du jour';

  @override
  String get start => 'Commencer';

  @override
  String get today => 'Aujourd’hui';

  @override
  String get solved => 'Résolu';

  @override
  String get cancel => 'Annuler';

  @override
  String get streakTitle => 'Jours d’affilée';

  @override
  String get streakSubtitleSolved => 'Fait pour aujourd’hui';

  @override
  String get streakSubtitleOpen =>
      'Résous un Sudoku aujourd’hui pour conserver ta série';

  @override
  String get dailySudokuTitle => 'Ton Sudoku du jour';

  @override
  String get dailySudokuSubtitle =>
      'Choisis un niveau et commence tout de suite';

  @override
  String get todaysEasy => 'Le Sudoku facile du jour';

  @override
  String get todaysMedium => 'Le Sudoku moyen du jour';

  @override
  String get todaysHard => 'Le Sudoku difficile du jour';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get loading => 'Chargement…';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessaie.';

  @override
  String get navigationHome => 'Accueil';

  @override
  String get navigationStatistics => 'Statistiques';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get sudoku => 'Sudoku';
}

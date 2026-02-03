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
  String get selectDifficultyTitle => 'Sélectionner la difficulté';

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
  String get navigationProfile => 'Classement';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get sudoku => 'Sudoku';

  @override
  String get activeGameContinueTitle => 'Reprendre votre Sudoku';

  @override
  String activeGameStatusPaused(Object elapsed) {
    return 'En pause · $elapsed';
  }

  @override
  String get activeGameStatusInProgress => 'En cours';

  @override
  String get activeGameContinue => 'Continuer';

  @override
  String get activeGameReset => 'Réinitialiser';

  @override
  String get restartGameTitle => 'Recommencer la partie ?';

  @override
  String get restartGameMessage =>
      'Cela effacera votre progression actuelle et redémarrera le minuteur.';

  @override
  String get restartGameConfirm => 'Redémarrer';

  @override
  String get sudokuActionHint => 'Indice';

  @override
  String get sudokuActionNotes => 'Notes';

  @override
  String get sudokuActionErase => 'Effacer';

  @override
  String get sudokuActionUndo => 'Annuler';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get pausedLabel => 'En pause';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String debugPuzzleId(Object id) {
    return 'ID du puzzle : $id';
  }

  @override
  String debugRowLabel(Object row) {
    return 'Ligne 1 : $row';
  }

  @override
  String get statsHintsUsed => 'Astuces utilisées';

  @override
  String get statsMoves => 'Coups';

  @override
  String get statsUndo => 'Annuler';

  @override
  String get timeResultGoldAchieved => 'Or obtenu';

  @override
  String timeResultToGold(Object delta) {
    return '$delta jusqu\'à l\'or';
  }

  @override
  String get medalGold => 'Or';

  @override
  String get medalSilver => 'Argent';

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
      other: '$seconds secondes',
      one: '1 seconde',
    );
    return 'Succès $medal, temps $_temp0 $_temp1';
  }

  @override
  String get successSolvedTitle => 'Résolu !';

  @override
  String get done => 'Terminé';

  @override
  String streakLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série : $count jours',
      one: 'Série commencée : 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get hintSolutionUnavailable => 'Solution indisponible';

  @override
  String get hintConflictsFound => 'Conflits trouvés';

  @override
  String get hintSelectEmptyCell => 'Sélectionnez une cellule vide';

  @override
  String get hintClearCellOrSelectEmpty =>
      'Effacez la cellule ou sélectionnez-en une vide.';

  @override
  String get hintNoEmptyCells => 'Aucune cellule vide';

  @override
  String hintPenaltyLabel(Object seconds) {
    return '+$seconds s';
  }
}

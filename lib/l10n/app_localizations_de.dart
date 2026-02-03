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
  String get save => 'Speichern';

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
  String get selectDifficultyTitle => 'Schwierigkeit auswählen';

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
  String get navigationProfile => 'Ranking';

  @override
  String get rankingComingSoon => 'Ranking kommt bald';

  @override
  String get profileEditDisplayNameTitle => 'Anzeigenamen bearbeiten';

  @override
  String get profileDisplayNameLabel => 'Anzeigename';

  @override
  String get profileEditNameTooltip => 'Namen bearbeiten';

  @override
  String get profileAvatarGallery => 'Aus Galerie auswählen';

  @override
  String get profileAvatarCamera => 'Foto aufnehmen';

  @override
  String get profileAvatarPickError =>
      'Der Bildauswahldialog konnte nicht geöffnet werden.';

  @override
  String get comingSoon => 'Bald verfügbar';

  @override
  String get sudoku => 'Sudoku';

  @override
  String get activeGameContinueTitle => 'Sudoku fortsetzen';

  @override
  String activeGameStatusPaused(Object elapsed) {
    return 'Pausiert · $elapsed';
  }

  @override
  String get activeGameStatusInProgress => 'Läuft';

  @override
  String get activeGameContinue => 'Weiter';

  @override
  String get activeGameReset => 'Zurücksetzen';

  @override
  String get sudokuActionHint => 'Tipp';

  @override
  String get sudokuActionNotes => 'Notizen';

  @override
  String get sudokuActionErase => 'Löschen';

  @override
  String get sudokuActionUndo => 'Zurück';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get pausedLabel => 'Pausiert';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String debugPuzzleId(Object id) {
    return 'Rätsel-ID: $id';
  }

  @override
  String debugRowLabel(Object row) {
    return 'Zeile 1: $row';
  }

  @override
  String get statsHintsUsed => 'Hinweise verwendet';

  @override
  String get statsMoves => 'Züge';

  @override
  String get statsUndo => 'Rückgängig';

  @override
  String get timeResultGoldAchieved => 'Gold erreicht';

  @override
  String timeResultToGold(Object delta) {
    return '$delta bis Gold';
  }

  @override
  String get medalGold => 'Gold';

  @override
  String get medalSilver => 'Silber';

  @override
  String get medalBronze => 'Bronze';

  @override
  String timeWithMedalSemantics(Object medal, num minutes, num seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds Sekunden',
      one: '1 Sekunde',
    );
    return '$medal-Erfolg, Zeit $_temp0 $_temp1';
  }

  @override
  String get successSolvedTitle => 'Gelöst!';

  @override
  String get done => 'Fertig';

  @override
  String streakLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie: $count Tage',
      one: 'Serie gestartet: 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get hintSolutionUnavailable => 'Lösung nicht verfügbar';

  @override
  String get hintConflictsFound => 'Konflikte gefunden';

  @override
  String get hintSelectEmptyCell => 'Wähle eine leere Zelle';

  @override
  String get hintClearCellOrSelectEmpty =>
      'Leere die Zelle oder wähle eine leere.';

  @override
  String get hintNoEmptyCells => 'Keine leeren Zellen';

  @override
  String hintPenaltyLabel(Object seconds) {
    return '+$seconds Sek.';
  }
}

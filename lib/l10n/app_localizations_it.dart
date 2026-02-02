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
  String get selectDifficultyTitle => 'Seleziona difficoltà';

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

  @override
  String get activeGameContinueTitle => 'Riprendi il tuo Sudoku';

  @override
  String activeGameStatusPaused(Object elapsed) {
    return 'In pausa · $elapsed';
  }

  @override
  String get activeGameStatusInProgress => 'In corso';

  @override
  String get activeGameContinue => 'Continua';

  @override
  String get activeGameReset => 'Reimposta';

  @override
  String get sudokuActionHint => 'Suggerimento';

  @override
  String get sudokuActionNotes => 'Note';

  @override
  String get sudokuActionErase => 'Cancella';

  @override
  String get sudokuActionUndo => 'Annulla';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get pausedLabel => 'In pausa';

  @override
  String get pause => 'Pausa';

  @override
  String get resume => 'Riprendi';

  @override
  String debugPuzzleId(Object id) {
    return 'ID puzzle: $id';
  }

  @override
  String debugRowLabel(Object row) {
    return 'Riga 1: $row';
  }

  @override
  String get statsHintsUsed => 'Suggerimenti usati';

  @override
  String get statsMoves => 'Mosse';

  @override
  String get statsUndo => 'Annulla';

  @override
  String get timeResultGoldAchieved => 'Oro raggiunto';

  @override
  String timeResultToGold(Object delta) {
    return '$delta all\'oro';
  }

  @override
  String get medalGold => 'Oro';

  @override
  String get medalSilver => 'Argento';

  @override
  String get medalBronze => 'Bronzo';

  @override
  String timeWithMedalSemantics(Object medal, num minutes, num seconds) {
    return 'Medaglia $medal, tempo ${intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      one: '1 minuto',
      other: '$minutes minuti',
    )} ${intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      one: '1 secondo',
      other: '$seconds secondi',
    )}';
  }

  @override
  String get successSolvedTitle => 'Risolto!';

  @override
  String get done => 'Fatto';

  @override
  String streakLabel(num count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'Serie iniziata: 1 giorno',
      other: 'Serie: $count giorni',
    );
  }

  @override
  String get hintSolutionUnavailable => 'Soluzione non disponibile';

  @override
  String get hintConflictsFound => 'Conflitti trovati';

  @override
  String get hintSelectEmptyCell => 'Seleziona una cella vuota';

  @override
  String get hintClearCellOrSelectEmpty =>
      'Cancella la cella o selezionane una vuota.';

  @override
  String get hintNoEmptyCells => 'Nessuna cella vuota';

  @override
  String hintPenaltyLabel(Object seconds) {
    return '+$seconds sec';
  }
}

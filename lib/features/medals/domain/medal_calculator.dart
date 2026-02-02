import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import 'medal.dart';
import 'medal_rules.dart';

class MedalCalculator {
  const MedalCalculator();

  Medal getMedal(SudokuDifficulty difficulty, int elapsedSeconds) {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        if (elapsedSeconds <= MedalRules.easyGoldSeconds) {
          return Medal.gold;
        }
        if (elapsedSeconds <= MedalRules.easySilverSeconds) {
          return Medal.silver;
        }
        return Medal.bronze;
      case SudokuDifficulty.medium:
        if (elapsedSeconds <= MedalRules.mediumGoldSeconds) {
          return Medal.gold;
        }
        if (elapsedSeconds <= MedalRules.mediumSilverSeconds) {
          return Medal.silver;
        }
        return Medal.bronze;
      case SudokuDifficulty.hard:
        if (elapsedSeconds <= MedalRules.hardGoldSeconds) {
          return Medal.gold;
        }
        if (elapsedSeconds <= MedalRules.hardSilverSeconds) {
          return Medal.silver;
        }
        return Medal.bronze;
    }
  }
}

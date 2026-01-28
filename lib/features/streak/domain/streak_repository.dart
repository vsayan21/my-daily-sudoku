import 'streak_state.dart';

abstract class StreakRepository {
  Future<StreakState> fetchStreakState();
}

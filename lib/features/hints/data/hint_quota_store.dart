import 'package:shared_preferences/shared_preferences.dart';

/// Stores hint usage information.
class HintQuotaStore {
  /// Creates a quota store with the given preferences instance.
  HintQuotaStore(this._preferences);

  static const String hintDateKey = 'hint_dateKey';
  static const String hintUsedCountKey = 'hint_used_count';

  final SharedPreferences _preferences;

  /// Returns the number of hints used for the given date key.
  Future<int> getHintCount(String dateKey) async {
    await _ensureDate(dateKey);
    return _preferences.getInt(hintUsedCountKey) ?? 0;
  }

  /// Increments hint usage for the given date key.
  Future<void> incrementHintCount(String dateKey) async {
    await _ensureDate(dateKey);
    final current = _preferences.getInt(hintUsedCountKey) ?? 0;
    await _preferences.setInt(hintUsedCountKey, current + 1);
  }

  Future<void> _ensureDate(String dateKey) async {
    final storedDate = _preferences.getString(hintDateKey);
    if (storedDate != dateKey) {
      await _preferences.setString(hintDateKey, dateKey);
      await _preferences.setInt(hintUsedCountKey, 0);
    }
  }
}

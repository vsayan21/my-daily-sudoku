import 'package:shared_preferences/shared_preferences.dart';

class HintQuotaState {
  const HintQuotaState({
    required this.usedCount,
    required this.adUsed,
  });

  final int usedCount;
  final bool adUsed;
}

class HintQuotaStore {
  HintQuotaStore({
    Future<SharedPreferences>? preferencesFuture,
  }) : _preferencesFuture =
            preferencesFuture ?? SharedPreferences.getInstance();

  static const String _dateKey = 'hint_dateKey';
  static const String _usedCountKey = 'hint_used_count';
  static const String _adUsedKey = 'hint_ad_used';

  final Future<SharedPreferences> _preferencesFuture;

  Future<HintQuotaState> loadQuota(String dateKey) async {
    final prefs = await _preferencesFuture;
    final storedDate = prefs.getString(_dateKey);
    if (storedDate != dateKey) {
      await prefs.setString(_dateKey, dateKey);
      await prefs.setInt(_usedCountKey, 0);
      await prefs.setBool(_adUsedKey, false);
      return const HintQuotaState(usedCount: 0, adUsed: false);
    }
    return HintQuotaState(
      usedCount: prefs.getInt(_usedCountKey) ?? 0,
      adUsed: prefs.getBool(_adUsedKey) ?? false,
    );
  }

  Future<void> recordHintUse({
    required String dateKey,
    required bool fromAd,
  }) async {
    final prefs = await _preferencesFuture;
    final storedDate = prefs.getString(_dateKey);
    var usedCount = prefs.getInt(_usedCountKey) ?? 0;
    var adUsed = prefs.getBool(_adUsedKey) ?? false;

    if (storedDate != dateKey) {
      usedCount = 0;
      adUsed = false;
      await prefs.setString(_dateKey, dateKey);
    }

    usedCount += 1;
    if (fromAd) {
      adUsed = true;
    }

    await prefs.setInt(_usedCountKey, usedCount);
    await prefs.setBool(_adUsedKey, adUsed);
  }
}

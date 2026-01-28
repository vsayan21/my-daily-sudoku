import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/active_game_keys.dart';
import '../models/active_game_session_model.dart';

class ActiveGameLocalDataSource {
  const ActiveGameLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  ActiveGameSessionModel? fetchSession() {
    final raw = _preferences.getString(ActiveGameKeys.activeGameSession);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return ActiveGameSessionModel.fromJson(decoded);
  }

  Future<void> persistSession(ActiveGameSessionModel session) {
    final encoded = jsonEncode(session.toJson());
    return _preferences.setString(ActiveGameKeys.activeGameSession, encoded);
  }

  Future<void> clearSession() {
    return _preferences.remove(ActiveGameKeys.activeGameSession);
  }
}

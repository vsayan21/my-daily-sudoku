import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/statistics_keys.dart';
import '../models/game_result_model.dart';

class StatisticsLocalDataSource {
  const StatisticsLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  Map<String, GameResultModel> fetchAll() {
    final raw = _preferences.getString(StatisticsKeys.records);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }
    return decoded.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, GameResultModel.fromJson(value));
      }
      return MapEntry(
        key,
        GameResultModel.fromJson(const <String, dynamic>{}),
      );
    });
  }

  Future<void> persist(GameResultModel model) async {
    final records = fetchAll();
    final recordKey = _buildRecordKey(model.dateKey, model.difficulty.name);
    records[recordKey] = model;
    final encoded = jsonEncode(
      records.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _preferences.setString(StatisticsKeys.records, encoded);
  }

  GameResultModel? fetchOne({
    required String dateKey,
    required String difficultyKey,
  }) {
    final records = fetchAll();
    final recordKey = _buildRecordKey(dateKey, difficultyKey);
    return records[recordKey];
  }

  String _buildRecordKey(String dateKey, String difficultyKey) {
    return '${dateKey}_$difficultyKey';
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_result_model.dart';

class StatisticsLocalDataSource {
  const StatisticsLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  Map<String, GameResultModel> fetchAll({required String recordsKey}) {
    final raw = _preferences.getString(recordsKey);
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

  Future<void> persist(
    GameResultModel model, {
    required String recordsKey,
  }) async {
    final records = fetchAll(recordsKey: recordsKey);
    final recordKey = _buildRecordKey(model.dateKey, model.difficulty.name);
    records[recordKey] = model;
    await saveAll(records, recordsKey: recordsKey);
  }

  Future<void> saveAll(
    Map<String, GameResultModel> records, {
    required String recordsKey,
  }) async {
    final encoded = jsonEncode(
      records.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _preferences.setString(recordsKey, encoded);
  }

  GameResultModel? fetchOne({
    required String recordsKey,
    required String dateKey,
    required String difficultyKey,
  }) {
    final records = fetchAll(recordsKey: recordsKey);
    final recordKey = _buildRecordKey(dateKey, difficultyKey);
    return records[recordKey];
  }

  String _buildRecordKey(String dateKey, String difficultyKey) {
    return '${dateKey}_$difficultyKey';
  }
}

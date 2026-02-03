import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';

class UserProfileLocalDataSource {
  UserProfileLocalDataSource(this.preferences);

  static const storageKey = 'user_profile_v1';

  final SharedPreferences preferences;

  UserProfileModel? loadProfile() {
    final raw = preferences.getString(storageKey);
    if (raw == null) {
      return null;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfileModel.fromJson(json);
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    final raw = jsonEncode(profile.toJson());
    await preferences.setString(storageKey, raw);
  }
}

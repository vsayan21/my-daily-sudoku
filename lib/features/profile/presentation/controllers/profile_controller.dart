import 'package:flutter/foundation.dart';

import '../../application/usecases/load_user_profile.dart';
import '../../application/usecases/update_country_code.dart';
import '../../application/usecases/update_display_name.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/exceptions/username_taken_exception.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required LoadUserProfile loadUserProfile,
    required UpdateDisplayName updateDisplayName,
    required UpdateCountryCode updateCountryCode,
  })  : _loadUserProfile = loadUserProfile,
        _updateDisplayName = updateDisplayName,
        _updateCountryCode = updateCountryCode;

  final LoadUserProfile _loadUserProfile;
  final UpdateDisplayName _updateDisplayName;
  final UpdateCountryCode _updateCountryCode;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isDisplayNameTaken = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isDisplayNameTaken => _isDisplayNameTaken;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    final loaded = await _loadUserProfile.execute();
    _profile = loaded;
    _isDisplayNameTaken = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    final current = _profile;
    if (current == null) {
      return;
    }
    _isDisplayNameTaken = false;
    try {
      final updated = await _updateDisplayName.execute(
        profile: current,
        displayName: displayName,
      );
      _profile = updated;
      notifyListeners();
    } on UsernameTakenException {
      _isDisplayNameTaken = true;
      notifyListeners();
    }
  }

  Future<void> updateCountryCode(String? countryCode) async {
    final current = _profile;
    if (current == null) {
      return;
    }
    final updated = await _updateCountryCode.execute(
      profile: current,
      countryCode: countryCode,
    );
    _profile = updated;
    notifyListeners();
  }
}

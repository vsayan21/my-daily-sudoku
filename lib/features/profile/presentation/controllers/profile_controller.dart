import 'package:flutter/foundation.dart';

import '../../application/usecases/load_user_profile.dart';
import '../../application/usecases/update_avatar_path.dart';
import '../../application/usecases/update_display_name.dart';
import '../../domain/entities/user_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required LoadUserProfile loadUserProfile,
    required UpdateDisplayName updateDisplayName,
    required UpdateAvatarPath updateAvatarPath,
  })  : _loadUserProfile = loadUserProfile,
        _updateDisplayName = updateDisplayName,
        _updateAvatarPath = updateAvatarPath;

  final LoadUserProfile _loadUserProfile;
  final UpdateDisplayName _updateDisplayName;
  final UpdateAvatarPath _updateAvatarPath;

  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    final loaded = await _loadUserProfile.execute();
    _profile = loaded;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    final current = _profile;
    if (current == null) {
      return;
    }
    final updated = await _updateDisplayName.execute(
      profile: current,
      displayName: displayName,
    );
    _profile = updated;
    notifyListeners();
  }

  Future<void> updateAvatarPath(String? avatarPath) async {
    final current = _profile;
    if (current == null) {
      return;
    }
    final updated = await _updateAvatarPath.execute(
      profile: current,
      avatarPath: avatarPath,
    );
    _profile = updated;
    notifyListeners();
  }
}

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UpdateCountryCode {
  const UpdateCountryCode({required UserProfileRepository repository})
      : _repository = repository;

  final UserProfileRepository _repository;

  Future<UserProfile> execute({
    required UserProfile profile,
    required String? countryCode,
  }) async {
    final normalized = _normalize(countryCode);
    final updated = profile.copyWith(countryCode: normalized);
    await _repository.saveUserProfile(updated);
    return updated;
  }

  String? _normalize(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return null;
    }
    if (RegExp(r'^[A-Z]{2}$').hasMatch(trimmed)) {
      return trimmed;
    }
    return null;
  }
}

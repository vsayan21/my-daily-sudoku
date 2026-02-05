import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../profile/data/datasources/user_profile_local_datasource.dart';
import '../profile/data/models/user_profile_model.dart';
import '../profile/data/services/firebase_profile_service.dart';
import '../profile/domain/entities/user_profile.dart';
import '../profile/domain/exceptions/username_taken_exception.dart';
import '../statistics/data/datasources/statistics_local_datasource.dart';
import '../statistics/shared/statistics_keys.dart';
import '../daily_sudoku/shared/daily_key.dart';

class FirebaseSyncService {
  FirebaseSyncService({
    required FirebaseProfileService profileService,
    required UserProfileLocalDataSource profileLocalDataSource,
    required StatisticsLocalDataSource statisticsLocalDataSource,
    FirebaseFirestore? firestore,
  })  : _profileService = profileService,
        _profileLocalDataSource = profileLocalDataSource,
        _statisticsLocalDataSource = statisticsLocalDataSource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseProfileService _profileService;
  final UserProfileLocalDataSource _profileLocalDataSource;
  final StatisticsLocalDataSource _statisticsLocalDataSource;
  final FirebaseFirestore _firestore;

  // Firestore rules (MVP): users/{uid} + results/{uid} write only by owner,
  // usernames/{name} create for authed users, update/delete only by owner uid.

  Future<String> ensureSignedIn() => _profileService.ensureSignedIn();

  Future<UserProfile> ensureUserProfileExistsAndSynced({
    String? locale,
    String? countryCode,
  }) async {
    final uid = await ensureSignedIn();
    final stored = _profileLocalDataSource.loadProfile();
    if (uid.isEmpty) {
      if (stored != null) {
        return stored;
      }
      final fallback = UserProfileModel(
        userId: '',
        displayName: UserProfile.defaultDisplayName,
      );
      await _profileLocalDataSource.saveProfile(fallback);
      return fallback;
    }
    final normalizedStored =
        _profileService.normalizeDisplayName(stored?.displayName ?? '');
    final isDefaultName = normalizedStored.isEmpty ||
        normalizedStored.toLowerCase() ==
            UserProfile.defaultDisplayName.toLowerCase();
    final proposedName = isDefaultName
        ? _profileService.defaultDisplayNameForUid(uid)
        : normalizedStored;
    final resolvedName = _profileService.isValidDisplayName(proposedName)
        ? proposedName
        : _profileService.defaultDisplayNameForUid(uid);
    final previousLower = stored?.displayName == null
        ? null
        : _profileService
            .normalizeDisplayName(stored!.displayName)
            .toLowerCase();

    String reservedName;
    try {
      reservedName = await _profileService.reserveDisplayName(
        uid: uid,
        displayName: resolvedName,
        previousDisplayNameLower: previousLower,
        locale: locale,
      );
    } on UsernameTakenException {
      reservedName = await _reserveFallbackDefault(
        uid: uid,
        locale: locale,
        previousDisplayNameLower: previousLower,
      );
    }

    final updated = UserProfileModel(
      userId: uid,
      displayName: reservedName,
      countryCode: _resolveCountryCode(
        existing: stored?.countryCode,
        localeTag: locale,
        countryCode: countryCode,
      ),
    );
    await _profileLocalDataSource.saveProfile(updated);
    return updated;
  }

  Future<void> uploadAllLocalResults({UserProfile? profile}) async {
    final uid = await ensureSignedIn();
    if (uid.isEmpty) {
      return;
    }
    final storedProfile = profile ?? _profileLocalDataSource.loadProfile();
    final displayName = storedProfile?.displayName ??
        _profileService.defaultDisplayNameForUid(uid);
    final shortId = _profileService.shortIdFromUid(uid);
    final countryCode = storedProfile?.countryCode;
    final records = _statisticsLocalDataSource.fetchAll(
      recordsKey: StatisticsKeys.recordsV2,
    );
    if (records.isEmpty) {
      return;
    }
    final batch = _firestore.batch();
    for (final result in records.values) {
      final completedAt =
          DateTime.fromMillisecondsSinceEpoch(result.completedAtEpochMs);
      final dateKeyUtc = buildDailyKeyUtc(now: completedAt);
      final dateKeyLocal = buildDailyKeyLocal(now: completedAt);
      final docId = '${dateKeyUtc}_${result.difficulty.name}';
      final ref =
          _firestore.collection('results').doc(uid).collection('daily').doc(
                docId,
              );
      final data = <String, dynamic>{
        'uid': uid,
        'displayName': displayName,
        'shortId': shortId,
        'dateKey': dateKeyUtc,
        'dateKeyUtc': dateKeyUtc,
        'dateKeyLocal': dateKeyLocal,
        'difficulty': result.difficulty.name,
        'elapsedSeconds': result.elapsedSeconds,
        'hintsUsed': result.hintsUsed,
        'movesCount': result.movesCount,
        'undoCount': result.undoCount,
        'medal': result.medal.name,
        'resetsCount': result.resetsCount,
        'completedAt': FieldValue.serverTimestamp(),
      };
      if (countryCode != null && countryCode.trim().isNotEmpty) {
        data['countryCode'] = countryCode.trim().toUpperCase();
      }
      if (result.appVersion != null) {
        data['appVersion'] = result.appVersion;
      }
      if (result.deviceLocale != null) {
        data['deviceLocale'] = result.deviceLocale;
      }
      batch.set(ref, data, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<String> _reserveFallbackDefault({
    required String uid,
    String? locale,
    String? previousDisplayNameLower,
  }) async {
    final baseName = _profileService.defaultDisplayNameForUid(uid);
    final random = math.Random();
    for (var attempt = 0; attempt < 3; attempt += 1) {
      final suffix = random.nextInt(90) + 10;
      final candidate = '$baseName $suffix';
      try {
        return await _profileService.reserveDisplayName(
          uid: uid,
          displayName: candidate,
          previousDisplayNameLower: previousDisplayNameLower,
          locale: locale,
        );
      } on UsernameTakenException {
        continue;
      }
    }
    return await _profileService.reserveDisplayName(
      uid: uid,
      displayName: baseName,
      previousDisplayNameLower: previousDisplayNameLower,
      locale: locale,
    );
  }

  String? _resolveCountryCode({
    required String? existing,
    required String? localeTag,
    required String? countryCode,
  }) {
    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim().toUpperCase();
    }
    if (countryCode != null && countryCode.trim().isNotEmpty) {
      return countryCode.trim().toUpperCase();
    }
    if (localeTag == null || localeTag.trim().isEmpty) {
      return null;
    }
    final normalized = localeTag.replaceAll('_', '-');
    final parts = normalized.split('-');
    if (parts.length < 2) {
      return null;
    }
    final candidate = parts[1].trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(candidate)) {
      return null;
    }
    return candidate;
  }
}

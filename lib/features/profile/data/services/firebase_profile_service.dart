import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/exceptions/username_taken_exception.dart';

class FirebaseProfileService {
  FirebaseProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<String> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } on FirebaseAuthException catch (error) {
        debugPrint('Anonymous sign-in failed: ${error.code}');
      } on FirebaseException catch (error) {
        debugPrint('Firebase sign-in failed: ${error.code}');
      }
    }
    return _auth.currentUser?.uid ?? '';
  }

  String shortIdFromUid(String uid) {
    if (uid.isEmpty) {
      return '0000';
    }
    final start = math.max(0, uid.length - 4);
    return uid.substring(start).toUpperCase();
  }

  String defaultDisplayNameForUid(String uid) {
    return 'Player ${shortIdFromUid(uid)}';
  }

  String normalizeDisplayName(String displayName) {
    final trimmed = displayName.trim();
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  bool isValidDisplayName(String displayName) {
    final normalized = normalizeDisplayName(displayName);
    if (normalized.isEmpty || normalized.length > 16) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9 _-]+$').hasMatch(normalized);
  }

  Future<String> reserveDisplayName({
    required String uid,
    required String displayName,
    String? previousDisplayNameLower,
    String? locale,
  }) async {
    final normalized = normalizeDisplayName(displayName);
    final lower = normalized.toLowerCase();
    final usernamesRef = _firestore.collection('usernames').doc(lower);
    final userRef = _firestore.collection('users').doc(uid);
    final shortId = shortIdFromUid(uid);

    await _firestore.runTransaction((transaction) async {
      final usernameSnap = await transaction.get(usernamesRef);
      final userSnap = await transaction.get(userRef);
      DocumentSnapshot<Map<String, dynamic>>? previousSnap;
      DocumentReference<Map<String, dynamic>>? previousRef;
      if (previousDisplayNameLower != null &&
          previousDisplayNameLower.isNotEmpty &&
          previousDisplayNameLower != lower) {
        previousRef =
            _firestore.collection('usernames').doc(previousDisplayNameLower);
        previousSnap = await transaction.get(previousRef);
      }

      if (usernameSnap.exists) {
        final data = usernameSnap.data();
        final existingUid = data?['uid'] as String?;
        if (existingUid != uid) {
          throw UsernameTakenException(normalized);
        }
      }

      final now = FieldValue.serverTimestamp();
      final userData = <String, dynamic>{
        'uid': uid,
        'displayName': normalized,
        'displayNameLower': lower,
        'shortId': shortId,
        'updatedAt': now,
      };
      if (!userSnap.exists) {
        userData['createdAt'] = now;
      }
      if (locale != null && locale.isNotEmpty) {
        userData['locale'] = locale;
      }
      transaction.set(userRef, userData, SetOptions(merge: true));

      if (!usernameSnap.exists) {
        transaction.set(usernamesRef, {
          'uid': uid,
          'displayName': normalized,
          'createdAt': now,
        });
      } else {
        transaction.set(
          usernamesRef,
          {'displayName': normalized},
          SetOptions(merge: true),
        );
      }

      if (previousRef != null && previousSnap != null) {
        final previousUid = previousSnap.data()?['uid'] as String?;
        if (previousSnap.exists && previousUid == uid) {
          transaction.delete(previousRef);
        }
      }
    });

    return normalized;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../domain/entities/ranking_entry.dart';

class RankingRemoteDataSource {
  RankingRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<RankingEntry>> fetchRanking({
    required String dateKey,
    required SudokuDifficulty difficulty,
    int limit = 100,
  }) async {
    final docId = '${dateKey}_${difficulty.name}';
    final snapshot = await _firestore
        .collection('leaderboards')
        .doc(docId)
        .collection('scores')
        .orderBy('elapsedSeconds')
        .orderBy('hintsUsed')
        .orderBy('movesCount')
        .orderBy('undoCount')
        .orderBy('completedAt')
        .orderBy('displayNameLower')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final displayName = data['displayName'] as String? ?? 'Player';
      final displayNameLower = data['displayNameLower'] as String? ??
          displayName.toLowerCase();
      final completedAt = data['completedAt'] as Timestamp?;
      return RankingEntry(
        uid: data['uid'] as String? ?? doc.id,
        displayName: displayName,
        displayNameLower: displayNameLower,
        elapsedSeconds: data['elapsedSeconds'] as int? ?? 0,
        hintsUsed: data['hintsUsed'] as int? ?? 0,
        movesCount: data['movesCount'] as int? ?? 0,
        undoCount: data['undoCount'] as int? ?? 0,
        completedAt: completedAt?.toDate(),
        medal: data['medal'] as String?,
        shortId: data['shortId'] as String?,
      );
    }).toList();
  }
}

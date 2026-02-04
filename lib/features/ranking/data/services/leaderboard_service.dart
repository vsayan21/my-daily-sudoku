import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<LeaderboardEntry>> fetchTopEntries({
    required String dateKey,
    required SudokuDifficulty difficulty,
    String? countryCode,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collectionGroup('daily')
        .where('dateKey', isEqualTo: dateKey)
        .where('difficulty', isEqualTo: difficulty.name);

    if (countryCode != null && countryCode.trim().isNotEmpty) {
      query = query.where('countryCode', isEqualTo: countryCode);
    }

    final snapshot = await query
        .orderBy('elapsedSeconds')
        .orderBy('hintsUsed')
        .orderBy('movesCount')
        .orderBy('undoCount')
        .orderBy('completedAt')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => LeaderboardEntry.fromJson(doc.data()))
        .toList(growable: false);
  }
}

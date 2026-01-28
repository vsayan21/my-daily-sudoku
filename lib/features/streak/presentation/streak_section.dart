import 'package:flutter/material.dart';

import '../data/streak_repository_impl.dart';
import '../domain/streak_repository.dart';
import '../domain/streak_state.dart';
import 'widgets/streak_card.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({
    super.key,
    StreakRepository? repository,
  }) : _repository = repository;

  final StreakRepository? _repository;

  Future<StreakState> _loadState() async {
    final repo = _repository ?? await StreakRepositoryImpl.create();
    return repo.fetchStreakState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StreakState>(
      future: _loadState(),
      builder: (context, snapshot) {
        final state = snapshot.data ??
            const StreakState(
              streakCount: 0,
              todaySolved: false,
            );
        return StreakCard(
          state: state,
        );
      },
    );
  }
}

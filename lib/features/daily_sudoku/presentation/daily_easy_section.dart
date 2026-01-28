import 'package:flutter/material.dart';

import '../application/usecases/get_today_easy_sudoku.dart';
import '../data/datasources/sudoku_assets_datasource.dart';
import '../data/repositories/daily_sudoku_repository_impl.dart';
import '../domain/entities/daily_sudoku.dart';
import '../shared/daily_key.dart';
import 'widgets/daily_sudoku_header.dart';

/// Section widget displaying today's easy Sudoku.
class DailyEasySection extends StatefulWidget {
  /// Creates the daily easy section.
  const DailyEasySection({super.key});

  @override
  State<DailyEasySection> createState() => _DailyEasySectionState();
}

class _DailyEasySectionState extends State<DailyEasySection> {
  late final Future<DailySudoku> _future;
  late final String _dailyKey;

  @override
  void initState() {
    super.initState();
    _dailyKey = dailyKeyToday();
    final repository = DailySudokuRepositoryImpl(
      dataSource: SudokuAssetsDataSource(),
    );
    _future = GetTodayEasySudoku(repository: repository).execute();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailySudoku>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }
        if (snapshot.hasError) {
          return const _ErrorState();
        }
        final sudoku = snapshot.data;
        if (sudoku == null) {
          return const _ErrorState();
        }
        return _LoadedState(
          dailyKey: _dailyKey,
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Unable to load today\'s Sudoku. Please try again later.',
    );
  }
}

class _LoadedState extends StatelessWidget {
  final String dailyKey;

  const _LoadedState({
    required this.dailyKey,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailySudokuHeader(dailyKey: dailyKey),
        ],
      ),
    );
  }
}

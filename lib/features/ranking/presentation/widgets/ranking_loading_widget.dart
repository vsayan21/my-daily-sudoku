import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/sudoku_loading_widget.dart';

class RankingLoadingWidget extends StatefulWidget {
  const RankingLoadingWidget({super.key});

  @override
  State<RankingLoadingWidget> createState() => _RankingLoadingWidgetState();
}

class _RankingLoadingWidgetState extends State<RankingLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return const SudokuLoadingWidget(
      label: 'Ranking is loading...',
    );
  }
}

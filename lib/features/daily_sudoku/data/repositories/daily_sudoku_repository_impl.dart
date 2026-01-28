import '../../domain/entities/daily_sudoku.dart';
import '../../domain/entities/sudoku_difficulty.dart';
import '../../domain/repositories/daily_sudoku_repository.dart';
import '../datasources/sudoku_assets_datasource.dart';

/// Loads daily Sudoku data from bundled assets.
class DailySudokuRepositoryImpl implements DailySudokuRepository {
  final SudokuAssetsDataSource dataSource;

  const DailySudokuRepositoryImpl({required this.dataSource});

  @override
  Future<List<DailySudoku>> fetchPuzzles(SudokuDifficulty difficulty) async {
    final models = await dataSource.loadPuzzles(difficulty);
    return models
        .map(
          (model) => model.toEntity(
            difficulty: difficulty,
            dateKey: '',
          ),
        )
        .toList();
  }
}

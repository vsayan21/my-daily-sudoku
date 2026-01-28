import '../../domain/entities/daily_sudoku.dart';
import '../../domain/repositories/daily_sudoku_repository.dart';
import '../datasources/sudoku_assets_datasource.dart';

/// Loads daily Sudoku data from bundled assets.
class DailySudokuRepositoryImpl implements DailySudokuRepository {
  final SudokuAssetsDataSource dataSource;

  const DailySudokuRepositoryImpl({required this.dataSource});

  @override
  Future<List<DailySudoku>> fetchEasyPuzzles() async {
    final models = await dataSource.loadEasyPuzzles();
    return models.map((model) => model.toEntity()).toList();
  }
}

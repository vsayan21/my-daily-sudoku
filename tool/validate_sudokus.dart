import 'dart:convert';
import 'dart:io';

const List<String> sudokuFiles = [
  'assets/sudoku/easy.json',
  'assets/sudoku/medium.json',
  'assets/sudoku/hard.json',
];

void main() {
  var anyInvalid = false;
  var totalPuzzles = 0;
  var totalValid = 0;
  var totalInvalid = 0;

  for (final path in sudokuFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('Missing file: $path');
      anyInvalid = true;
      continue;
    }

    final content = file.readAsStringSync();
    final dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (error) {
      stderr.writeln('Failed to parse JSON in $path: $error');
      anyInvalid = true;
      continue;
    }

    if (decoded is! List) {
      stderr.writeln('Expected a JSON array in $path');
      anyInvalid = true;
      continue;
    }

    var fileTotal = 0;
    var fileValid = 0;
    var fileInvalid = 0;

    for (final entry in decoded) {
      fileTotal += 1;
      totalPuzzles += 1;
      final errors = <String>[];

      if (entry is! Map<String, dynamic>) {
        errors.add('entry is not an object');
        _reportInvalid(path, '<unknown>', errors);
        fileInvalid += 1;
        totalInvalid += 1;
        anyInvalid = true;
        continue;
      }

      final id = entry['id'] is String ? entry['id'] as String : '<unknown>';
      final puzzle = entry['puzzle'];
      final solution = entry['solution'];

      if (puzzle is! String) {
        errors.add('puzzle is not a string');
      }
      if (solution is! String) {
        errors.add('solution is not a string');
      }

      List<List<int>>? puzzleGrid;
      List<List<int>>? solutionGrid;

      if (puzzle is String) {
        final formatError = validatePuzzleFormat(puzzle);
        if (formatError != null) {
          errors.add(formatError);
        } else {
          puzzleGrid = parseGrid(puzzle);
        }
      }

      if (solution is String) {
        final formatError = validateSolutionFormat(solution);
        if (formatError != null) {
          errors.add(formatError);
        } else {
          solutionGrid = parseGrid(solution);
        }
      }

      if (puzzleGrid != null) {
        final givensError = isValidGivens(puzzleGrid);
        if (givensError != null) {
          errors.add(givensError);
        }
      }

      if (solutionGrid != null) {
        final solutionError = isValidSolution(solutionGrid);
        if (solutionError != null) {
          errors.add(solutionError);
        }
      }

      if (puzzleGrid != null && solutionGrid != null && puzzle is String && solution is String) {
        final matchError = puzzleMatchesSolution(puzzle, solution);
        if (matchError != null) {
          errors.add(matchError);
        }
      }

      if (puzzleGrid != null && solutionGrid != null && errors.isEmpty) {
        final solverGrid = cloneGrid(puzzleGrid);
        final solutions = countSolutions(solverGrid, limit: 2);
        if (solutions == 0) {
          errors.add('no solutions found by solver');
        } else if (solutions > 1) {
          errors.add('multiple solutions found by solver');
        } else {
          final solved = solveOne(cloneGrid(puzzleGrid));
          if (solved != null && !gridsEqual(solved, solutionGrid)) {
            errors.add('solver solution does not match provided solution');
          }
        }
      }

      if (errors.isNotEmpty) {
        _reportInvalid(path, id, errors);
        fileInvalid += 1;
        totalInvalid += 1;
        anyInvalid = true;
      } else {
        fileValid += 1;
        totalValid += 1;
      }
    }

    stdout.writeln('File: $path');
    stdout.writeln('  total puzzles: $fileTotal');
    stdout.writeln('  valid puzzles: $fileValid');
    stdout.writeln('  invalid puzzles: $fileInvalid');
  }

  stdout.writeln('Overall summary:');
  stdout.writeln('  total puzzles: $totalPuzzles');
  stdout.writeln('  valid puzzles: $totalValid');
  stdout.writeln('  invalid puzzles: $totalInvalid');

  if (anyInvalid) {
    exitCode = 1;
  }
}

void _reportInvalid(String file, String id, List<String> errors) {
  stdout.writeln('Invalid puzzle:');
  stdout.writeln('  file: $file');
  stdout.writeln('  id: $id');
  stdout.writeln('  reasons:');
  for (final error in errors) {
    stdout.writeln('    - $error');
  }
}

String? validatePuzzleFormat(String puzzle) {
  if (puzzle.length != 81) {
    return 'puzzle length is ${puzzle.length}, expected 81';
  }
  if (!RegExp(r'^[0-9]{81}$').hasMatch(puzzle)) {
    return 'puzzle contains non-digit characters';
  }
  return null;
}

String? validateSolutionFormat(String solution) {
  if (solution.length != 81) {
    return 'solution length is ${solution.length}, expected 81';
  }
  if (!RegExp(r'^[1-9]{81}$').hasMatch(solution)) {
    return 'solution must contain digits 1-9 only';
  }
  return null;
}

List<List<int>> parseGrid(String value) {
  final grid = <List<int>>[];
  for (var row = 0; row < 9; row++) {
    final start = row * 9;
    final rowValues = value
        .substring(start, start + 9)
        .split('')
        .map(int.parse)
        .toList();
    grid.add(rowValues);
  }
  return grid;
}

String? isValidGivens(List<List<int>> grid) {
  for (var row = 0; row < 9; row++) {
    final seen = <int>{};
    for (var col = 0; col < 9; col++) {
      final value = grid[row][col];
      if (value == 0) {
        continue;
      }
      if (seen.contains(value)) {
        return 'givens conflict in row ${row + 1}';
      }
      seen.add(value);
    }
  }

  for (var col = 0; col < 9; col++) {
    final seen = <int>{};
    for (var row = 0; row < 9; row++) {
      final value = grid[row][col];
      if (value == 0) {
        continue;
      }
      if (seen.contains(value)) {
        return 'givens conflict in column ${col + 1}';
      }
      seen.add(value);
    }
  }

  for (var boxRow = 0; boxRow < 3; boxRow++) {
    for (var boxCol = 0; boxCol < 3; boxCol++) {
      final seen = <int>{};
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 3; col++) {
          final value = grid[boxRow * 3 + row][boxCol * 3 + col];
          if (value == 0) {
            continue;
          }
          if (seen.contains(value)) {
            return 'givens conflict in box ${boxRow * 3 + boxCol + 1}';
          }
          seen.add(value);
        }
      }
    }
  }

  return null;
}

String? isValidSolution(List<List<int>> grid) {
  for (var row = 0; row < 9; row++) {
    final seen = <int>{};
    for (var col = 0; col < 9; col++) {
      final value = grid[row][col];
      if (value < 1 || value > 9) {
        return 'solution contains invalid digit at row ${row + 1}, col ${col + 1}';
      }
      if (seen.contains(value)) {
        return 'solution has duplicate in row ${row + 1}';
      }
      seen.add(value);
    }
  }

  for (var col = 0; col < 9; col++) {
    final seen = <int>{};
    for (var row = 0; row < 9; row++) {
      final value = grid[row][col];
      if (seen.contains(value)) {
        return 'solution has duplicate in column ${col + 1}';
      }
      seen.add(value);
    }
  }

  for (var boxRow = 0; boxRow < 3; boxRow++) {
    for (var boxCol = 0; boxCol < 3; boxCol++) {
      final seen = <int>{};
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 3; col++) {
          final value = grid[boxRow * 3 + row][boxCol * 3 + col];
          if (seen.contains(value)) {
            return 'solution has duplicate in box ${boxRow * 3 + boxCol + 1}';
          }
          seen.add(value);
        }
      }
    }
  }

  return null;
}

String? puzzleMatchesSolution(String puzzle, String solution) {
  for (var i = 0; i < 81; i++) {
    if (puzzle[i] == '0') {
      continue;
    }
    if (puzzle[i] != solution[i]) {
      return 'puzzle givens do not match solution';
    }
  }
  return null;
}

int countSolutions(List<List<int>> grid, {int limit = 2}) {
  final empty = findEmpty(grid);
  if (empty == null) {
    return 1;
  }

  final row = empty[0];
  final col = empty[1];
  var count = 0;

  for (var value = 1; value <= 9; value++) {
    if (isSafe(grid, row, col, value)) {
      grid[row][col] = value;
      count += countSolutions(grid, limit: limit);
      if (count >= limit) {
        grid[row][col] = 0;
        return count;
      }
      grid[row][col] = 0;
    }
  }

  return count;
}

List<List<int>>? solveOne(List<List<int>> grid) {
  final empty = findEmpty(grid);
  if (empty == null) {
    return grid;
  }

  final row = empty[0];
  final col = empty[1];

  for (var value = 1; value <= 9; value++) {
    if (isSafe(grid, row, col, value)) {
      grid[row][col] = value;
      final solved = solveOne(grid);
      if (solved != null) {
        return solved;
      }
      grid[row][col] = 0;
    }
  }

  return null;
}

List<int>? findEmpty(List<List<int>> grid) {
  for (var row = 0; row < 9; row++) {
    for (var col = 0; col < 9; col++) {
      if (grid[row][col] == 0) {
        return [row, col];
      }
    }
  }
  return null;
}

bool isSafe(List<List<int>> grid, int row, int col, int value) {
  for (var i = 0; i < 9; i++) {
    if (grid[row][i] == value || grid[i][col] == value) {
      return false;
    }
  }

  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;
  for (var r = 0; r < 3; r++) {
    for (var c = 0; c < 3; c++) {
      if (grid[boxRow + r][boxCol + c] == value) {
        return false;
      }
    }
  }

  return true;
}

List<List<int>> cloneGrid(List<List<int>> grid) {
  return grid.map((row) => List<int>.from(row)).toList();
}

bool gridsEqual(List<List<int>> a, List<List<int>> b) {
  for (var row = 0; row < 9; row++) {
    for (var col = 0; col < 9; col++) {
      if (a[row][col] != b[row][col]) {
        return false;
      }
    }
  }
  return true;
}

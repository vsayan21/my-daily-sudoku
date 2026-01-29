# My Daily Sudoku

A daily Sudoku experience built with Flutter. The app focuses on a clean, modular
architecture so features (daily puzzle, streaks, active game recovery) are easy
to evolve and test.

## ✨ Features

- Daily Sudoku puzzles with Easy/Medium/Hard difficulties.
- Active game recovery so you can continue where you left off.
- Streak tracking to keep you motivated.
- Localized UI (EN/DE/IT/FR).

## 🧱 Architecture

This project uses **feature-first clean architecture**:

```
lib/
  app/                # App entry, DI, theme
  features/
    <feature>/
      application/    # Use cases, controllers, services
      data/           # Repositories, datasources, DTO/models
      domain/         # Entities, repository interfaces, value objects
      presentation/   # Screens, widgets, view models
      shared/         # Feature helpers, constants
```

Dependencies flow inward: `presentation → application → domain` and
`data → domain`. Domain stays Flutter-agnostic.

For coding standards, see
[docs/FLUTTER_DART_GUIDELINES.md](docs/FLUTTER_DART_GUIDELINES.md).

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)

### Install

```
flutter pub get
```

### Run

```
flutter run
```

### Tests

```
flutter test
```

## 🧩 Sudoku Asset Validation

Validate the bundled Sudoku JSON from the project root:

```
dart run tool/validate_sudokus.dart
```

## 🌍 Localization

Strings live in `lib/l10n/*.arb`. Add new keys there and regenerate
localizations via Flutter's gen-l10n.

## 📁 Useful Paths

- `lib/app/di/app_dependencies.dart` - app-level dependency wiring
- `lib/features/home/...` - home screen & navigation
- `lib/features/daily_sudoku/...` - daily puzzle feature

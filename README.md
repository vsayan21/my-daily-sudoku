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

## 🔥 Firebase Setup (Local)

Firebase config files are intentionally **not** committed. Each developer must
generate them locally.

1) Install Firebase CLI and login:

```
firebase login
```

2) Install FlutterFire CLI:

```
dart pub global activate flutterfire_cli
```

3) Configure Firebase for this project (from the repo root):

```
flutterfire configure
```

During configuration:
- Select the Firebase project.
- Select platforms **iOS** + **Android**.
- Confirm iOS bundle ID: `ch.polyapps.app.myDailySudoku`.

4) Confirm the generated files exist locally (do **not** commit them):
- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

5) Ensure Firebase is initialized in Flutter:
- `main.dart` should include:

```
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

These config files are generated locally and ignored by git. Do **not** commit
them.

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

## 🔐 Security Remediation (Leaked Firebase Config)

If a Firebase config file was committed, **rotate or restrict** the affected
API key(s) in Google Cloud Console. Close any GitHub secret scanning alerts only
after the key is rotated or appropriately restricted.

If this repository was ever public, consider rewriting git history to remove
the leaked files entirely. **Do not run automatically**; suggested commands:

```
# Install git-filter-repo if needed.
# https://github.com/newren/git-filter-repo

git filter-repo --path ios/Runner/GoogleService-Info.plist --invert-paths
git filter-repo --path android/app/google-services.json --invert-paths

git push --force --all
git push --force --tags
```

After a history rewrite, collaborators must re-clone the repository.

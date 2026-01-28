# Flutter & Dart Code Guidelines

These guidelines describe how we design, structure, and maintain the codebase.
They are optimized for readable, testable, and scalable Flutter apps.

## 1) Architecture

We follow **feature-first, layered clean architecture**:

```
lib/
  app/                # App entry, DI, theme, routing
  features/
    <feature>/
      application/    # Use cases, controllers, services
      data/           # Repositories, datasources, DTO/models
      domain/         # Entities, repository interfaces, value objects
      presentation/   # Screens, widgets, view models
      shared/         # Feature helpers, constants
```

**Rules**
- Presentation depends on application/domain.
- Application depends on domain.
- Data depends on domain.
- Domain has **no** Flutter dependencies.

## 2) File & Folder Naming

- Folders: `snake_case`.
- Dart files: `snake_case.dart`.
- Public types: `UpperCamelCase`.
- Private helpers: `_lowerCamelCase`.

## 3) Imports

- Use package imports for public APIs: `package:my_daily_sudoku/...`.
- Keep relative imports **inside the same feature** when practical.
- Sort: Dart SDK → Flutter → packages → local.
- Avoid unused imports; prefer `dart format` to keep ordering consistent.

## 4) UI Composition

- Keep widgets small and focused (one responsibility).
- Prefer composition over inheritance.
- Stateless first; Stateful only when needed.
- Keep UI state inside the widget tree; domain/application is for logic.

## 5) State & Async

- Use `Future`/`Stream` APIs explicitly.
- Avoid doing heavy work in `build`.
- Always guard `setState` with `mounted` checks after async calls.

## 6) Error Handling

- Use domain errors/exceptions in the domain layer.
- Map to UI-friendly messages in presentation.
- Log unexpected errors; show friendly fallback UI.

## 7) Testing

- Unit test domain and application logic.
- Widget tests for critical UI flows.
- Prefer fast, isolated tests.

## 8) Styling

- Centralize theme in `app/theme`.
- Keep colors/typography consistent.
- Avoid inline magic numbers; prefer constants when reused.

## 9) Localization

- Strings live in `lib/l10n/*.arb`.
- Use `AppLocalizations` in UI (no hard-coded user-facing strings).

## 10) Documentation

- Add a README section when adding new features.
- Update this document if you change the architectural rules.

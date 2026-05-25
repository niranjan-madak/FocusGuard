# Contributing to FocusGuard

## Getting Started

```bash
git clone https://github.com/your-username/FocusGuard
cd FocusGuard
flutter pub get
flutter run -d windows   # or android / macos / linux
```

## Project Structure

```
lib/models/timer_model.dart    All business logic — start here
lib/screens/home_screen.dart   Main UI and keyboard shortcuts
lib/widgets/                   Reusable Flutter widgets
lib/services/                  Audio and notification services
lib/theme.dart                 Colors and font helpers
assets/sounds/                 WAV audio files
windows/CMakeLists.txt         Windows-specific build config
```

## Development Commands

```bash
flutter pub get          # install / refresh dependencies
flutter run -d windows   # launch with hot reload
flutter analyze          # lint check — must pass before PR
flutter test             # run test suite
flutter build windows --release   # release build
```

**Hot reload** (while running): press `r`  
**Hot restart**: press `R`  
**Quit**: press `q`

## Architecture

State lives entirely in `TimerModel` (a `ChangeNotifier`). Widgets read state with `context.watch<TimerModel>()` and call methods via `context.read<TimerModel>()`. No business logic belongs in widgets.

## Code Style

- Follow `flutter_lints` — `flutter analyze` must report zero errors
- Dart naming: `camelCase` methods/variables, `PascalCase` classes, `snake_case` files
- Prefer `StatelessWidget`; only use `StatefulWidget` for local animation state
- No `print()` — use `debugPrint()` only during development
- No comments explaining *what* code does — only *why* (non-obvious constraints)

## Submitting Changes

1. Fork the repo and create a feature branch
2. Make changes following the code style above
3. Run `flutter analyze` — zero errors required
4. Run `flutter test` — all tests must pass
5. Open a pull request with a clear description of what and why

## Adding a Dependency

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Update `memory/DEPENDENCIES.md`
4. Confirm the dependency is offline-safe (no unexpected network calls at runtime)

## Reporting Bugs

Open a GitHub Issue with:
- Flutter version (`flutter --version`)
- Platform (Windows / Android / etc.)
- Steps to reproduce
- Expected vs actual behaviour

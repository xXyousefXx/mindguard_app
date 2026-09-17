# MindGuard (Flutter Android app)

AI-assisted support system for Alzheimer's patients and their caregivers.
This package contains the **Flutter client** only. The AI engine, database and
smartwatch integration are owned by other teams and are reached through the
REST contracts documented in `ANALYSIS.md`.

## Run it locally

You need Flutter 3.19+ (Dart 3.3+).

```bash
cd mindguard_app

# One time only: generate the android/ (and other) platform folders
flutter create .

flutter pub get
flutter analyze
flutter run
```

The app starts on mock data, so it runs with no backend at all.

### Pointing it at the Node.js backend

```bash
flutter run \
  --dart-define=USE_MOCK_DATA=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

`10.0.2.2` is how the Android emulator reaches `localhost` on your machine.

## What is inside

```
lib/
  main.dart                     app entry, theme, locale, RTL
  app/router.dart               every route in the app
  core/
    theme/                      colors + Material 3 theme
    localization/               Arabic/English strings, language provider
    network/                    api config, http client, result types
    storage/                    token + role persistence
    services/                   Arabic text-to-speech
    widgets/                    shared cards, headers, async/error views
  features/<feature>/
    data/                       models + repository (mock and API impl)
    state/                      Riverpod providers/controllers
    presentation/               screens and widgets
```

Rules that keep it maintainable:

- Screens never call `http` directly - they go through a repository.
- Every repository has a mock and an API implementation behind one interface;
  flipping `USE_MOCK_DATA` swaps them with no UI change.
- No hardcoded strings in widgets - all text comes from `AppStrings`.
- No hardcoded colors in widgets - all colors come from `AppColors`.
- All routes live in `app/router.dart`; screens navigate by named path.

## Screens implemented

Auth: welcome / role choice, login, create account.
Patient (Arabic, RTL, large text): home, memory exercises, medicines,
familiar faces, health.
Caregiver (Arabic/English): dashboard, medicine manager, reports.

Still to come once the designs arrive: live tracking and safe zones,
notifications centre, family management, caregiver settings.

See `ANALYSIS.md` for the full feature split, screen map, API map and phases.

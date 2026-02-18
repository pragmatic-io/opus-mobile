# OPUS Mobile

Flutter application with modular architecture targeting Android & iOS.

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | 3.19.x (stable) |
| Dart | 3.3.x |
| Android Studio / Xcode | Latest stable |

Install Flutter: https://docs.flutter.dev/get-started/install

## Local Setup

```bash
# 1. Clone the repository
git clone https://github.com/pragmatic-io/opus-mobile.git
cd opus-mobile

# 2. Copy environment variables
cp .env.example .env
# Edit .env and fill in the required values

# 3. Install dependencies
flutter pub get

# 4. Run code generation (freezed, json_serializable, retrofit)
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run -t lib/main_dev.dart        # Development
flutter run -t lib/main_staging.dart    # Staging
flutter run -t lib/main_prod.dart       # Production
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # FlavorConfig — environment-aware settings
│   ├── network/        # DioClient — HTTP client with interceptors
│   ├── router/         # GoRouter — navigation & deep linking
│   ├── storage/        # HiveService — offline-first local storage
│   └── theme/          # AppTheme — light/dark themes
├── features/
│   └── <feature>/      # One folder per feature (e.g. auth, profile)
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── pages/
│           ├── providers/
│           └── widgets/
├── app.dart            # Root widget (MaterialApp.router + Riverpod)
├── main_dev.dart       # Dev entry point
├── main_staging.dart   # Staging entry point
├── main_prod.dart      # Production entry point
└── main.dart           # Default entry point (delegates to dev)
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation & deep linking |
| `dio` | HTTP client |
| `retrofit` | Type-safe API layer |
| `hive_flutter` | Offline-first local storage |
| `freezed` | Immutable data models |
| `json_serializable` | JSON serialization |

## Running Tests

```bash
flutter test
```

## Code Generation

Whenever you add or modify a `@freezed`, `@JsonSerializable`, or `@RestApi` class, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

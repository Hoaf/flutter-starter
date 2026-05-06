# flutter_demo

Flutter client for the `nt-flutter-starter` project.

## Prerequisites

1. Install Flutter SDK (stable channel): https://docs.flutter.dev/get-started/install
2. Verify your environment:

```bash
flutter doctor
```

3. Ensure at least one device is available:
   - Android Emulator
   - iOS Simulator (macOS only)
   - Chrome (for web)

Check connected targets:

```bash
flutter devices
```

## Install Dependencies

From the `flutter` folder:

```bash
flutter pub get
```

## Run The App

Start with default target:

```bash
flutter run
```

Run on a specific platform:

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web (Chrome)
flutter run -d chrome

# macOS desktop
flutter run -d macos
```

If multiple devices are connected, choose one:

```bash
flutter run -d <device-id>
```

## Build Release Artifacts

```bash
# Android APK
flutter build apk --release

# iOS (requires Xcode signing)
flutter build ios --release

# Web
flutter build web
```

## Useful Commands

```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Clean build cache
flutter clean
```

## Troubleshooting

- If dependencies fail, run `flutter clean && flutter pub get`.
- If iOS build fails, run:

```bash
cd ios && pod install && cd ..
```

- Re-check setup with `flutter doctor -v`.

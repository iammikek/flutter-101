# flutter-101 (FastAPI client)

This is a fundamentals Flutter project that builds a simple **frontend** for the companion FastAPI project at `/Users/mike/Projects/fastAPI-101`.

## What’s inside

- **Flutter app**: iPhone Simulator + macOS desktop targets
- **Mock vs Live API**: toggle in-app to develop UI without the backend running
- **Example feature**: Items list + detail + create + delete
  - Delete requires an API key header (`x-api-key`)

## Prerequisites

- Flutter SDK installed (`flutter doctor` is clean)
- FastAPI backend available locally (see below)

## Run the FastAPI backend

From the backend repo:

```bash
cd /Users/mike/Projects/fastAPI-101
uvicorn main:app --reload --port 8000
```

The API should be available at `http://localhost:8000`.

## Run the Flutter app

List devices:

```bash
flutter devices
```

### Android (emulator)

To run on Android you need the **Android SDK** installed (via Android Studio). If `flutter doctor` says it can’t find the SDK, install Android Studio and then install:

- Android SDK Platform
- Android SDK Build-Tools
- Android Emulator

Then create and start an emulator:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
```

Run the app:

```bash
flutter run -d <emulator-id>
```

Important: on the Android emulator, **your Mac’s `localhost` is `10.0.2.2`**.
So if your FastAPI is running on `http://localhost:8000` on your Mac, set the Flutter base URL to:

- `http://10.0.2.2:8000`

Run on iPhone 13 Simulator:

```bash
flutter run -d "iPhone 13"
```

Run on macOS desktop:

```bash
flutter run -d macos
```

### In-app settings

Open **Settings** (top-right):

- **Use mock data**: ON uses local fake data, OFF calls FastAPI
- **Base URL**: `http://localhost:8000`
- **API Key**: default dev key is `dev-key-123` (sent as `x-api-key`)

## Tests

### Flutter

```bash
flutter test
```

### Integration tests (Android / iOS)

Run on iPhone Simulator:

```bash
flutter test integration_test -d "iPhone 13"
```

Run on Android emulator (replace with your emulator id from `flutter devices`):

```bash
flutter test integration_test -d <emulator-id>
```

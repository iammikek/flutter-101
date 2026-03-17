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

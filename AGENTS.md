# AGENTS

This repo is a fundamentals project for building Flutter apps that talk to a FastAPI backend.

## Engineering note

We support changes with tests.

## Running tests

### Flutter

```bash
flutter test
```

## Testing guidelines

- **Prefer fast tests**: most coverage should be unit + widget tests; keep integration tests few.
- **Be deterministic**: avoid real network/time in unit/widget tests; inject fakes (e.g. a fake `ApiService`).
- **Test behavior**: assert user-visible outcomes (text, enabled/disabled, navigation) over widget tree details.
- **Cover states**: happy path, loading, validation errors, and API failures.
- **Use stable selectors**: add `Key(...)` for critical widgets once tests start relying on them.
- **Keep CI green**: `flutter test` must pass locally and in GitHub Actions.


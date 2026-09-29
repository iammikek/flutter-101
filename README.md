# Getting Fast at Flutter

A step-by-step **Flutter** client for the *-101 items API — same JSON contract as [fastAPI-101](https://github.com/iammikek/fastAPI-101), with parity to [vue-101](https://github.com/iammikek/vue-101) on mobile and desktop.

**Audience:** Mobile/desktop developers learning how a Laravel-style API maps to a client app (JWT auth, categories, paginated items, stats).

**Client-only:** This repo does not run a backend. Point it at any *-101 API (or use **mock mode** for UI work without a server).

---

## What's Included

1. **Flutter** — iOS Simulator, macOS desktop, Android emulator
2. **Provider** — `AppConfig`, `AuthStore`, `ItemsStore`, `CategoriesStore`
3. **Bottom navigation** — Items, Categories, Stats
4. **JWT auth** — register, login, Bearer token on write endpoints
5. **Categories** — list, detail, create, edit, delete
6. **Items** — list with filters + pagination, detail, create, edit, delete
7. **Stats** — `GET /items/stats/summary`
8. **Mock mode** — in-memory fake API (default) for offline UI work
9. **Live mode** — calls a real *-101 backend via `BASE_URL`
10. **Tests** — widget and store tests (`flutter test`)

---

## Quick Start

### Mock mode (no backend)

```bash
cd flutter-101
cp .env.example .env
flutter pub get
flutter run -d macos   # or: flutter run -d "iPhone 16"
```

Browse items, categories, and stats with fake data. Writes work without signing in.

### Live mode (fastAPI-101)

```bash
# Terminal 1 — backend
cd ../fastAPI-101
uvicorn main:app --reload --port 8000

# Terminal 2 — app
cd ../flutter-101
# .env: USE_MOCK=false, BASE_URL=http://localhost:8000
flutter run -d macos
```

Sign in from the app bar, then create categories and items.

### Tests

```bash
flutter test
```

---

## Project Structure

```
flutter-101/
├── lib/
│   ├── api/              # ApiClient + MockApiClient
│   ├── auth/             # AuthStore (JWT)
│   ├── categories/       # CategoriesStore
│   ├── items/            # ItemsStore + ItemsRepository
│   ├── models/           # Item, Category, User, ItemStats
│   └── pages/            # Shell, items, categories, stats, login
├── test/
├── .env.example
└── pubspec.yaml
```

---

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `BASE_URL` | `http://localhost:8000` | API root |
| `USE_MOCK` | `true` | Mock data vs live API |

**Android emulator:** Mac `localhost` is `10.0.2.2` — set `BASE_URL=http://10.0.2.2:8000`.

---

## API Endpoints (client coverage)

| Path | Method | Auth | UI |
|------|--------|------|-----|
| `/` | GET | — | API client |
| `/health` | GET | — | API client |
| `/auth/register` | POST | — | Login page |
| `/auth/login` | POST | — | Login page |
| `/auth/me` | GET | JWT | Account menu |
| `/categories` | GET/POST | JWT on POST | Categories tab |
| `/categories/{id}` | GET/PATCH/DELETE | JWT on writes | detail + forms |
| `/items` | GET/POST | JWT on POST | Items tab + FAB |
| `/items/stats/summary` | GET | — | Stats tab |
| `/items/{id}` | GET/PATCH/DELETE | JWT on writes | detail + edit |

Query params on `GET /items`: `skip`, `limit`, `category_id`, `name_contains`.

---

## Laravel → Flutter Mapping

| Laravel | flutter-101 |
|---------|-------------|
| Sanctum personal access token | JWT `Authorization: Bearer` |
| Blade views | Flutter widgets (Material 3) |
| Form Request validation | `TextFormField` validators + API errors |
| Eloquent `category_id` | `category_id` + nested `category` |
| `paginate()` | `{ items, total, skip, limit }` + load more |
| `@auth` middleware | `auth.canWrite` (or mock mode) |

---

## *-101 Family

Full family list, ports, and clone-with-submodules: **[learning-101](https://github.com/iammikek/learning-101)**. Site catalogue: [automica.io/learning-101](https://automica.io/learning-101.html).

---

## Quick Reference

| Goal | Command |
|------|---------|
| Copy env | `cp .env.example .env` |
| Install | `flutter pub get` |
| List devices | `flutter devices` |
| Run macOS | `flutter run -d macos` |
| Run iOS | `flutter run -d "iPhone 16"` |
| Run Android | `flutter run -d <emulator-id>` |
| Tests | `flutter test` |
| Pair with API | Set `USE_MOCK=false`, `BASE_URL=http://localhost:8000` |

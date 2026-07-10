# flutter-101 (*-101 Flutter client)

Step-by-step **Flutter** client for the *-101 items API — same JSON contract as [fastAPI-101](https://github.com/iammikek/fastAPI-101), [nest-101](https://github.com/iammikek/nest-101), and [express-101](https://github.com/iammikek/express-101).

**Audience:** Mobile/desktop developers learning how a Laravel-style API maps to a client app (JWT auth, categories, paginated items, stats).

## API coverage

| Area | Endpoints | UI |
|------|-----------|-----|
| Health | `GET /`, `GET /health` | Via API client (settings / live mode) |
| Auth | `POST /auth/register`, `POST /auth/login`, `GET /auth/me` | Sign-in page |
| Categories | Full CRUD + list/detail | Categories tab |
| Items | List (filters, pagination), detail, create, **edit**, delete | Items tab |
| Stats | `GET /items/stats/summary` | Stats tab |

Writes use **JWT Bearer** tokens (like Laravel Sanctum). Reads are public. **Mock mode** works without signing in; **live mode** requires login for create/update/delete.

## Prerequisites

- Flutter SDK (`flutter doctor` clean)
- A running *-101 API (e.g. fastAPI-101 on port 8000)

## Configuration

```bash
cp .env.example .env
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `BASE_URL` | `http://localhost:8000` | API root |
| `USE_MOCK` | `true` | Local fake data vs live API |

Android emulator: use `http://10.0.2.2:8000` for `BASE_URL`.

## Run the backend

```bash
cd ../fastAPI-101
uvicorn main:app --reload --port 8000
```

## Run the app

```bash
flutter pub get
flutter run -d macos   # or iPhone simulator / Android emulator
```

## Tests

```bash
flutter test
```

## Laravel mapping

| Laravel | Flutter client |
|---------|----------------|
| Sanctum / session | JWT Bearer in `Authorization` header |
| Blade views | Flutter widgets (Material) |
| Form Request validation | Form validators + API 422 responses |
| Eloquent relationships | `category_id` + nested `category` on items |
| `paginate()` | `skip` / `limit` + `total` metadata |

## Related *-101 repos

Pair this client with any API-only backend: **fastAPI-101** (8000), **nest-101** (8006), **express-101** (8007), or **go-101**.

For server-rendered shop UIs, see **laravel-101**, **symfony-101**, **django-101**, or **orchestr-101**.

For a web SPA client, see **vue-101**.

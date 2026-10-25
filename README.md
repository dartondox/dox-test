# dox-test

A small blog app (users, profiles, posts, comments, tags) that runs on the
**local** Dox framework code in `../dox/packages` (see `pubspec_overrides.yaml`).
It uses every Dox package: ORM, migrations, auth, validation, cache, storage,
OpenAPI and Socket.IO.
An end-to-end test calls every endpoint over HTTP and Socket.IO.

**Check it by hand:** see [MANUAL_TEST.md](MANUAL_TEST.md).

## Setup (once)

```bash
cp .env.example .env
dart pub get
dart run build_runner build      # models + lib/openapi.g.dart
```

## 1. Start the databases

```bash
docker compose up -d --wait     # postgres 5452, mysql 3326, redis 6459, minio 9110 (console 9111)
docker compose down             # stop them when done
```

## 2. Run the app

```bash
dart run bin/server.dart        # http://127.0.0.1:3100 , Socket.IO /chat
dart run bin/migrate.dart       # only run the migrations (also: rollback, reset, refresh, status)
```

## 3. Run the checks

```bash
dart test                       # starts the server on a fresh database, then checks everything
```

The test rolls back all migrations first, so every run starts empty.
It needs redis and minio from docker compose (also for SQLite).

## Switch database

`DB_CONNECTION` picks the database: `postgres` (default), `mysql` or `sqlite`.
Set it in `.env`, or just for one run:

```bash
dart test                         # postgres
DB_CONNECTION=mysql dart test
DB_CONNECTION=sqlite dart test    # no docker needed
DB_CONNECTION=mysql dart run bin/server.dart
```

A shell variable wins over `.env`. `DB_PORT` defaults to 5452 (postgres) or 3326 (mysql).
SQLite uses a file: `DB_DATABASE`, default `<system temp>/dox_test.sqlite`.
A file (not `:memory:`) lets every isolate see the same data.

## Production build (AOT)

`dart run` is JIT: slow start, about 390 MB memory. Use the AOT build in production.

```bash
dart run ../dox/packages/dox-cli/bin/dox.dart build   # or: dox build
./build/bundle/bin/server        # run from the project folder, so it finds .env, public/ and storage/
```

It starts in about 0.05 s and uses about 16 MB.

## OpenAPI files

```bash
dart run ../dox/packages/dox-cli/bin/dox.dart openapi:generate   # storage/openapi/openapi.json + .yaml
```

## CI

`.github/workflows/test.yaml` runs `dart test` three times: on Postgres, MySQL and SQLite.
It checks out this repo into `dox-test` and `dartondox/dox` into `dox`, so the
`../dox/packages` paths still work. Pick the dox branch with the `dox_ref` input
(default `develop`). Redis is a service. MinIO starts with `docker run`.

## Code layout

- `lib/routes` -> `lib/app/http/controllers` -> `lib/app/services` -> `lib/app/repositories` -> `lib/app/models`
- `lib/providers`: dox providers (database + observers, auth, IoC container)
- `lib/app/ws`: the Socket.IO `/chat` namespace
- `lib/app/http/dtos`: `@Dto` classes for request input. `lib/app/http/rules`: custom rules
- `public/playground.html`: the browser test page at `/playground`
- `lib/config`: all config. Env keys are typed in `lib/config/env.dart` (`@DoxEnv`). `lib/constants`: global constants.
- `db/migration`: Dart migrations, written with the schema builder.
  The same file works on Postgres, MySQL and SQLite.
  `db/migration/migrations.dart` lists them. Do not edit it: `dox make:migration`
  and `dox migration:*` make it again. Add a migration with
  `dart run ../dox/packages/dox-cli/bin/dox.dart make:migration <name>`.

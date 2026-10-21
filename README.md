# dox-test

A small blog app (users, profiles, posts, comments, tags) that runs on the
**local** Dox framework code in `../dox/packages` (see `pubspec_overrides.yaml`).
An end-to-end test calls every endpoint over HTTP and the websocket.

## Setup (once)

```bash
cp .env.example .env
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

## 1. Start the databases

```bash
docker compose up -d --wait     # dox-test-pg on 5452, dox-test-mysql on 3326
docker compose down             # stop them when done
```

## 2. Run the app

```bash
dart run bin/server.dart        # http://127.0.0.1:3100 , ws://127.0.0.1:3100/ws
dart run bin/migrate.dart       # only run the migrations (also: rollback, reset, refresh, status)
```

## 3. Run the checks

```bash
dart test                       # starts the server on a fresh database, then checks everything
```

The test rolls back all migrations first, so every run starts empty.

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

## CI

`.github/workflows/test.yaml` runs `dart test` three times: on Postgres, MySQL and SQLite.
It checks out this repo into `dox-test` and `dartondox/dox` into `dox`, so the
`../dox/packages` paths still work. Pick the dox branch with the `dox_ref` input.
The default is `schema-builder-and-docs` for now.
Set it back to `develop` after dartondox/dox PR #115 merges.

## Code layout

- `lib/routes` -> `lib/app/http/controllers` -> `lib/app/services` -> `lib/app/repositories` -> `lib/app/models`
- `lib/providers`: dox services (database, auth, websocket, IoC container)
- `lib/config`: all config. `lib/constants`: global constants.
- `db/migration`: Dart migrations, written with the schema builder.
  The same file works on Postgres, MySQL and SQLite.
  `db/migration/migrations.dart` lists them. Do not edit it: `dox make:migration`
  and `dox migration:*` make it again. Add a migration with
  `dart run ../dox/packages/dox-cli/bin/dox.dart make:migration <name>`.

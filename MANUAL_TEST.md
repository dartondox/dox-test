# Manual test guide

Check every Dox package by hand. One section per package.
Each step: a command, then what you should see.

## 0. Start (once)

```bash
cp .env.example .env
dart pub get
dart run build_runner build                 # models, DTOs, env.g.dart, openapi.g.dart
dart run ../dox/packages/dox-cli/bin/dox.dart env:check   # → The env is valid.
docker compose up -d --wait                 # postgres, mysql, redis, minio
dart run bin/migrate.dart run               # optional: the server also migrates
dart run bin/server.dart                    # http://127.0.0.1:3100
```

Leave the server running. Use a second terminal for the commands below.

```bash
B=http://127.0.0.1:3100
K='X-Api-Key: secret-api-key'               # needed for /api/system/*
J='Content-Type: application/json'
```

Other database: `DB_CONNECTION=mysql dart run bin/server.dart` (or `sqlite`).

Env keys are typed in `lib/config/env.dart` (`@DoxEnv`). A bad value stops the app:
`APP_PORT=abc dart run ../dox/packages/dox-cli/bin/dox.dart env:check`
→ `APP_PORT must be an int, not "abc"`, exit code 1.

Stop: `Ctrl+C`, then `docker compose down`.

---

## 1. dox_core: routing, middleware, CORS

- [ ] `curl -i $B/ping`
  → `pong`, header `x-app-name: dox-test`
- [ ] `curl -i -H 'Origin: x.com' $B/ping`
  → `access-control-allow-origin: *`
- [ ] `curl -i $B/no-cors`
  → no `access-control-*` headers
- [ ] `curl -i -X OPTIONS -H 'Origin: x.com' -H 'Access-Control-Request-Method: POST' $B/api/posts`
  → `204`
- [ ] `curl -i $B/api/system/env`
  → `403 invalid api key` (no key)
- [ ] `curl -H "$K" $B/api/system/env`
  → `{"app_name":"dox-test",...}`

## 2. dox_core: request, response, limits

- [ ] `curl -H "$K" "$B/api/system/query?a=1&b=two"`
  → `query`, `only`, `has_a: true`
- [ ] `curl -H "$K" -c /tmp/c.txt $B/api/system/cookie` then `curl -H "$K" -b /tmp/c.txt $B/api/system/cookie/read`
  → `{"theme":"dark"}` (the cookie itself is encrypted)
- [ ] `curl -i -H "$K" $B/api/system/teapot`
  → `418`, header `x-custom: yes`
- [ ] `curl -H "$K" $B/api/system/crash`
  → `500`
- [ ] Body too big (limit 1 MB):
  `head -c 2000000 /dev/zero | tr '\0' a | curl -s -o /dev/null -w '%{http_code}\n' -H "$K" -H "$J" --data-binary @- $B/api/system/echo`
  → `413`
- [ ] Upload too big (limit 5 MB):
  `head -c 6000000 /dev/zero > /tmp/big.bin && curl -s -o /dev/null -w '%{http_code}\n' -F file=@/tmp/big.bin $B/api/storage/memory`
  → `413`
- [ ] Trusted proxy:
  `curl -H "$K" -H 'X-Forwarded-For: 203.0.113.9' -H 'X-Forwarded-Proto: https' $B/api/system/ip`
  → `{"ip":"203.0.113.9","scheme":"https","secure":true}`
- [ ] File response with Range:
  `echo 'hello range' > /tmp/r.txt && curl -F note=x -F file=@/tmp/r.txt $B/api/files`
  → copy `name`, then `curl -i -H 'Range: bytes=0-4' $B/api/files/<name>/raw`
  → `206`, body `hello`, `content-range: bytes 0-4/12`
- [ ] Typed path param (`int n`): `curl -H "$K" $B/api/system/twice/21` → `{"result":42}`.
  `.../twice/abc` → `404`. Same for `curl -i $B/api/posts/abc`

## 3. dox_auth (JWT)

- [ ] Register:
  `curl -H "$J" -d '{"name":"Ann","first_name":"Ann","last_name":"Lee","email":"Ann@Mail.COM","password":"secret123","password_confirmation":"secret123"}' $B/api/auth/register`
  → `201`, `email: ann@mail.com` (lower case), `full_name: Ann Lee`, no password
- [ ] Login: `curl -H "$J" -d '{"email":"ann@mail.com","password":"secret123"}' $B/api/auth/login`
  → copy `token`, then `T='Authorization: Bearer <token>'`
- [ ] `curl -H "$T" $B/api/auth/me` → Ann. Without `-H "$T"` → `401`

### Session login (`web` guard)

Guards are in `lib/config/auth.dart`: `api` (JWT, the default) and `web` (session).
Sessions are kept in Redis (`session:` in `lib/config/app.dart`), so a logout also ends a copied cookie.
Routes: `/web-auth/*` in `lib/routes/web.dart` (JSON), `/inertia/*` pages in section 10.

```bash
C=/tmp/web.txt; rm -f $C
curl -s -c $C -b $C $B/web-auth/me -o /dev/null      # gets the XSRF-TOKEN cookie
X="X-XSRF-TOKEN: $(awk '$6=="XSRF-TOKEN"{print $7}' $C | python3 -c 'import sys,urllib.parse;print(urllib.parse.unquote(sys.stdin.read().strip()))')"
```

- [ ] `curl -i -H "$J" -d '{"email":"ann@mail.com","password":"secret123"}' $B/web-auth/login`
  → `419` (no CSRF token)
- [ ] `curl -i -c $C -b $C -H "$J" -H "$X" -d '{"email":"ann@mail.com","password":"wrong"}' $B/web-auth/login`
  → `401`, `Wrong email or password`
- [ ] `curl -c $C -b $C -H "$J" -H "$X" -d '{"email":"ann@mail.com","password":"secret123"}' $B/web-auth/login`
  → Ann. `cat $C`: `dox_session` and `XSRF-TOKEN` have new values (the session got a new id)
- [ ] Read the new token again (the `X=...` line), then `curl -b $C $B/web-auth/me` → Ann
- [ ] `cp $C /tmp/old.txt`, then `curl -c $C -b $C -H "$X" -X POST $B/web-auth/logout` → `{"logged_out":true}`
- [ ] `curl -i -b $C $B/web-auth/me` → `401`. `curl -i -b /tmp/old.txt $B/web-auth/me` → `401` (old cookie is no use)
- [ ] `curl -i -b /tmp/old.txt $B/api/auth/me` → `401` (a session is not a JWT)

## 4. dox_orm + dox_migration

- [ ] Create post: `curl -H "$T" -H "$J" -d '{"title":"Hi","body":"text","status":"published","tags":["dart"]}' $B/api/posts`
  → `201`, `author`, `tags` (belongsTo, manyToMany)
- [ ] `curl "$B/api/posts?page=1&per_page=2"` → `total`, `per_page`, `data` (pagination)
- [ ] `curl $B/api/posts/1` → post with `author`, `comments`, `tags`
- [ ] `curl $B/api/users/1` → `first_name`, `full_name` (@Computed), `profile`, `posts`
- [ ] Soft delete: `curl -X DELETE -H "$T" $B/api/posts/1`, then `curl $B/api/posts/trashed`
  → the post, with `deleted_at` (whereNotNull)
- [ ] Stats (join, groupBy, whereNull, cache): `curl $B/api/posts/stats` twice
  → second answer has `"cached":true`
- [ ] Transaction rollback: `curl -H "$J" -d '{"names":["alpha","beta"],"fail":true}' $B/api/tags`
  → `{"saved":false,...}`, `total` does not change
- [ ] Transaction commit: same without `"fail":true` → `{"saved":true,...}`
- [ ] whereNotIn: `curl "$B/api/tags?except=alpha,dart"` → no `alpha`, no `dart`
- [ ] Observer: the server log prints `user created` after each register
- [ ] Migrations: `dart run bin/migrate.dart status`
  → 6 migrations, the last is `add_names_to_users_table`

## 5. Validation (DTOs)

Every request input is a `@Dto` class in `lib/app/http/dtos/`.
Bad input gets `422` with `{"key": "message"}`. The controller does not run.

| Feature | Good | Bad → 422 body |
| --- | --- | --- |
| required + `@Dto(messages:)` | — | `curl -H "$J" -d '{}' $B/api/auth/register` → `{"name":"name is missing","email":"email is missing",...}` |
| `@Length`, `@Email`, `@MinLength` | see step 3 | `-d '{"name":"A","email":"x","password":"1","password_confirmation":"1"}' .../register` → `{"name":"The name must be between 2 and 100 characters","email":"The email is not a valid email","password":"The password must be at least 6 characters"}` |
| `validate()` (cross field) | see step 3 | `"password_confirmation":"other"` → `{"password_confirmation":"The passwords do not match"}` |
| `@Unique` (+ `@Trim @Lowercase`) | — | register `" ANN@mail.com "` again → `{"email":"The email has already been taken"}` |
| `@Unique(ignoreParam: 'id')` | `curl -X PUT -H "$T" -H "$J" -d '{"name":"Ann","email":"ann@mail.com"}' $B/api/users/1` → `200` (own email is fine) | same with the email of another user → `{"email":"The email has already been taken"}` |
| query DTO: defaults, `@Min`, `@Max`, text → int | `curl "$B/api/users?search=%20an%20"` → `per_page: 10` | `curl "$B/api/users?page=0&per_page=101"` → `{"page":"The page must be greater than or equal 1","per_page":"The per_page must be less than or equal 100"}`. `?page=abc` → `{"page":"The page must be an integer"}` |
| enum list + `@Exists` | `curl "$B/api/posts?status=draft&status=published&author_id=1"` | `?author_id=999` → `{"author_id":"The selected author_id is invalid"}`. `?status=nope` → `{"status.0":"The selected status is invalid. ..."}` |
| enum + default, `@Trim` | `-d '{"title":" Hi ","body":"b"}' $B/api/posts` (with `$T`) → `title: Hi`, `status: draft` | `-d '{"status":"x"}'` → `title`, `body`, `status` errors |
| custom rule `@Slug` + `@MaxItems(5)` | `"tags":[" Dart-Tips "]` → saved as `dart-tips` | `"tags":["not a slug"]` → `{"tags.0":"The tags must be a slug, like dart-tips"}`. 6 tags → `{"tags":"The tags may not have more than 5 items"}` |
| `@Url`, nullable optional | `curl -X PUT -H "$T" -H "$J" -d '{"website":"https://a.dev"}' $B/api/auth/me/profile` | `{"website":"a.dev"}` → `{"website":"The website must be a url"}` |
| `Maybe<T>` (PATCH) | `curl -X PATCH -H "$T" -H "$J" -d '{"bio":null}' $B/api/auth/me/profile` → `bio: null`, `website` stays. `-d '{}'` → nothing changes | `{"website":"nope"}` → `{"website":"The website must be a url"}` |
| nested DTO, `List<Dto>`, `@Regex`, `@Min/@Max` | `curl -H "$K" -H "$J" -d '{"address":{"city":"Bangkok","post_code":"10110"},"items":[{"name":"Shoes","quantity":2}]}' $B/api/system/orders` → `total_quantity: 2` | `post_code "1011a"`, `quantity 0` → `{"address.post_code":"The post_code format is invalid","items.0.quantity":"The quantity must be greater than or equal 1"}` |
| `@Dto(strict: true)` | — | add `"coupon":"FREE"` → `{"coupon":"The coupon field is not allowed"}` |
| `_root` | — | `curl -H "$J" -d '[1,2]' $B/api/auth/register` → `{"_root":"The _root must be an object"}` |
| `@MinItems`, items `@Length` | `-d '{"names":["  MiXed  "]}' $B/api/tags` → saved as `mixed` | `{"names":[]}` → `{"names":"The names must have at least 1 items"}` |
| file `@Image`, `@MaxSize` | `echo iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg== \| base64 -d > /tmp/a.png && curl -F avatar=@/tmp/a.png $B/api/files/avatar` → `201` | `-F avatar=@/tmp/r.txt` → `{"avatar":"The avatar must be an image"}`. A png over 64 KB → `{"avatar":"The avatar may not be larger than 64KB"}` |
| file is required | — | `curl -F note=x $B/api/files` → `{"file":"The file is required"}` |

## 6. dox_openapi

- [ ] Open http://127.0.0.1:3100/docs → Scalar page
- [ ] "Register a user" shows the body from `RegisterUser` with snake_case keys
  (`password_confirmation`, `first_name`) and a `422` answer (`ValidationError`)
- [ ] "List users" shows the query params `page`, `per_page`, `search`
- [ ] In the page: "Log in" has a summary, a description and a `401` answer (annotations)
- [ ] Tag "Cache" holds all cache routes (`@Tags` on the class)
- [ ] `GET /api/tags` shows "List tags (lower case annotation)"
- [ ] http://127.0.0.1:3100/openapi.json and http://127.0.0.1:3100/openapi.yaml → the document
- [ ] Files: `dart run ../dox/packages/dox-cli/bin/dox.dart openapi:generate`
  → `storage/openapi/openapi.json` and `openapi.yaml`

## 7. dox_cache (memory, file, redis)

Swap `redis` for `memory` or `file` in every URL.

- [ ] Put: `curl -X PUT -H "$J" -d '{"value":{"name":"Ann"},"ttl":60}' $B/api/cache/redis/items/user`
- [ ] Get: `curl $B/api/cache/redis/items/user` → `"has":true`
- [ ] Forget: `curl -X DELETE $B/api/cache/redis/items/user` → `"forgot":true`
- [ ] Remember: `curl -X POST $B/api/cache/redis/remember/now` twice
  → first `"computed":true`, then `false` with the same value
- [ ] Increment: `curl -X POST -H "$J" -d '{"by":5}' $B/api/cache/redis/increment/hits` → 5, 10, ...
- [ ] Tags:
  `curl -X PUT -H "$J" -d '{"value":"Ann"}' $B/api/cache/redis/tags/users/a`,
  `curl -X DELETE $B/api/cache/redis/tags/users`,
  `curl $B/api/cache/redis/tags/users/a` → `"value":null`
- [ ] Lock: `curl -X POST $B/api/cache/redis/locks/report` twice
  → first `"got":true` + `owner`, second `"got":false`.
  Release: `curl -X DELETE "$B/api/cache/redis/locks/report?owner=<owner>"` → `"released":true`
- [ ] `file` store lock → `422` (file has no locks)
- [ ] See the keys in redis: `docker exec dox-test-redis redis-cli keys 'dox_test:*'`

## 8. dox_storage (local, memory, s3 = MinIO)

Swap `s3` for `local` or `memory`.

- [ ] Upload: `echo hello > /tmp/a.txt && curl -F file=@/tmp/a.txt $B/api/storage/s3`
  → `201`, `key` like `uploads/<uuid>.txt`
- [ ] Stream: `curl $B/api/storage/s3/stream/<key>` → `hello`
- [ ] Download: `curl -i $B/api/storage/s3/download/<key>` → `content-disposition: attachment`
- [ ] Signed URL: `curl $B/api/storage/s3/signed/<key>` → a MinIO URL on port 9110.
  `curl '<url>'` → `hello`
- [ ] Local signed URL: same with `local` → a `/files/...` URL (Storage.route).
  `curl '<url>'` → `hello`. Change one letter of `signature` → `403`
- [ ] Delete: `curl -X DELETE $B/api/storage/s3/files/<key>`, then stream → `404`
- [ ] MinIO console: http://127.0.0.1:9111 (minioadmin / minioadmin), bucket `dox-test`

## 9. dox_socketio (browser)

- [ ] Open http://127.0.0.1:3100/playground in **two tabs**
- [ ] Socket.IO box: Connect → `connected, id ..., welcome {...}`
  (transport becomes `websocket` after the polling start)
- [ ] Ping → `ack: pong`
- [ ] Join "lobby" in both tabs, Message in tab 1 → tab 1 `ack: sent`, tab 2 `message {...}`
- [ ] Type a space as name, Connect → `connect_error: name is empty` (namespace middleware)

## 10. dox_inertia (React + Vite, browser)

The pages are in `resources/js/Pages`, the routes in `lib/routes/inertia.dart`.
Needs Node. Run `npm install` once.

Dev mode (hot reload):

```bash
npm run dev                                                    # terminal 1, Vite on :5173
VITE_DEV_SERVER=http://localhost:5173 dart run bin/server.dart # terminal 2
```

Production build:

```bash
npm run build              # → public/build, with .vite/manifest.json
dart run bin/server.dart   # restart after each build: the asset version is read once
```

- [ ] Open http://127.0.0.1:3100/inertia → "Hello from Dox", `dox-test` in the nav (shared prop)
- [ ] "Loading stats..." then `Notes: 0` (deferred prop)
- [ ] "Load tip" → `Props can load later.` (optional prop, partial reload)
- [ ] Notes: add `x` → `The text must be between 2 and 100 characters` (redirect back, errors from the session).
  Reload → the error is gone
- [ ] Add `hello` → green `Note saved` and `hello` in the list. Reload → `Note saved` is gone (flash shows once)
- [ ] `x` deletes the note (Network tab: `DELETE` gets `303`)
- [ ] DevTools → Application → Cookies: `dox_session` (HttpOnly) and `XSRF-TOKEN` (not HttpOnly)
- [ ] `curl -i -X POST -H 'X-Inertia: true' -H 'Content-Type: application/json' -d '{"text":"hi"}' $B/inertia/notes`
  → `419`, `csrf_token_mismatch` (no CSRF token)
- [ ] Click Home / Notes: no full page reload (Network tab: JSON with `x-inertia: true`)
- [ ] `curl -i $B/inertia` → HTML with `<script data-page="app" type="application/json">` and the script tags
- [ ] Production only: `curl -I $B/build/assets/<file>.js` → `content-type: text/javascript`,
  `cache-control: max-age=31536000`, no `content-disposition`
- [ ] `curl -i -H 'X-Inertia: true' -H 'X-Inertia-Version: old' $B/inertia` → `409`, `x-inertia-location`

Session login pages (`Login.jsx`, `Dashboard.jsx`, the nav in `Nav.jsx`). Use the user from section 3.

- [ ] Logged out: the nav shows `Login`. Open http://127.0.0.1:3100/inertia/dashboard → you land on `/inertia/login`
- [ ] Log in with a wrong password → red `Wrong email or password` next to the email. The email stays, the password is empty
- [ ] Email `nope` → red `The email is not a valid email`
- [ ] Right password → `/inertia/dashboard`, "Logged in as **Ann** (ann@mail.com)".
  The nav shows `Dashboard | Ann [Logout]` (shared prop `auth.user`)
- [ ] Click `Logout` → `/inertia/login`, the nav shows `Login` again. Open `/inertia/dashboard` → back on the login page

## 11. Production build (AOT)

- [ ] `dart run ../dox/packages/dox-cli/bin/dox.dart build` → `build/bundle/bin/server`
- [ ] Stop `dart run`, then `./build/bundle/bin/server` from the project folder
  → starts in well under a second. `curl $B/ping` → `pong`

## 12. Automatic checks

- [ ] `dart test` (postgres), `DB_CONNECTION=mysql dart test`, `DB_CONNECTION=sqlite dart test`
  → all pass (123 checks)
- [ ] `npm ci && npm run build` → `public/build/.vite/manifest.json` (CI runs it too)

## Known issues (framework, not this app)

- **OpenAPI file uploads**: `POST /api/files`, `/api/files/avatar` and `/api/storage/{disk}`
  show an `application/json` body in `/docs`, not `multipart/form-data`.
  So you can not send a file from the Scalar page. Use curl.
- **Client IP**: `req.ip()` gives `::ffff:127.0.0.1`, not `127.0.0.1`, for a local client.
- **OpenAPI docs of two routes with the same method name**: dox_openapi drops the `Route.group`
  prefix from the route path it saves (`/web-auth/login` is saved as `/login`). It then matches
  a route by HTTP method, the end of the path and the method name only, not the controller.
  So `POST /web-auth/login` with a method named `login` gave its docs to `POST /api/auth/login`.
  This app names the session methods `sessionLogin`, `sessionUser`, `sessionLogout` to avoid it.

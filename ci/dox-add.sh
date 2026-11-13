#!/usr/bin/env bash
# Checks `dox add` for every Dox package on a new app.
#
# Steps: make an app from the dox-sample template (branch v3.x), point all
# Dox packages to the clones next to dox-test (ci/clone-siblings.sh of the
# dox repo, plus dox-mcp), run `dox add` for all 11 packages, then
# build_runner, analyze, migrate, start the server and call /ping.
# Then it runs `dox add` for all 11 again: the second run must change no
# file.
#
# The dox CLI comes from ../dox-cli, compiled once. It must use
# the same local clones, so its pubspec_overrides.yaml is written first.
#
# Env: DOX_SAMPLE_REF (default v3.x), APP_PORT (default 39124), DOX_PARENT
# (the folder of the clones, default the folder above dox-test).
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
parent=$(cd "${DOX_PARENT:-$root/..}" && pwd)
ref=${DOX_SAMPLE_REF:-v3.x}
port=${APP_PORT:-39124}
# each entry: the package, then the options of its install command
packages=("orm --driver=sqlite" queue scheduler mailer "cache --store=database"
  auth storage "socketio --broadcasting" view inertia mcp)

# Prints a pubspec_overrides.yaml that points every Dox package to the
# clones in $parent.
overrides() {
  echo "# the Dox packages of the clones, not the ones on pub.dev"
  echo "dependency_overrides:"
  for dir in "$parent"/dox/packages/*/ "$parent"/dox-orm/packages/*/ \
    "$parent"/dox-queue/packages/*/ "$parent"/dox-auth/ "$parent"/dox-openapi/ \
    "$parent"/dox-validation/ "$parent"/dox-socketio/ "$parent"/dox-storage/ \
    "$parent"/dox-mailer/ "$parent"/dox-view/ "$parent"/dox-inertia/ \
    "$parent"/dox-scheduler/ "$parent"/dox-mcp/ "$parent"/ioredis/ \
    "$parent"/dox-http-native/ "$parent"/dox-postgres-native/ \
    "$parent"/dox-mysql-native/; do
    [ -f "$dir/pubspec.yaml" ] || continue
    name=$(sed -nE 's/^name:[[:space:]]*([a-z0-9_]+).*/\1/p' "$dir/pubspec.yaml")
    printf '  %s:\n    path: %s\n' "$name" "${dir%/}"
  done
}

work=$(mktemp -d)
echo "work folder: $work"

# the CLI, on the local clones
cli="$parent/dox-cli"
# A local pubspec_overrides.yaml of your own is kept.
if [ -n "${CI:-}" ] || [ ! -f "$cli/pubspec_overrides.yaml" ]; then
  overrides > "$cli/pubspec_overrides.yaml"
fi
[ -z "${CI:-}" ] || "$parent/dox/ci/system-sqlite.sh" "$cli/pubspec.yaml"
(cd "$cli" && dart pub get)
mkdir -p "$work/bin"
# a kernel file: `dart compile exe` does not take packages with build hooks
dart compile kernel "$cli/bin/dox.dart" -o "$work/dox.dill"
printf '#!/usr/bin/env bash\nexec dart "%s" "$@"\n' "$work/dox.dill" > "$work/bin/dox"
chmod +x "$work/bin/dox"
export PATH="$work/bin:$PATH"

# what `dox create` does, but from the template branch
cd "$work"
git clone -q --depth 1 --branch "$ref" https://github.com/dartondox/dox-sample.git add_app
rm -rf add_app/.git
cd add_app
grep -rlI dox_sample . | while read -r f; do
  sed -i.bak 's/dox_sample/add_app/g' "$f" && rm "$f.bak"
done
cp .env.example .env
dox key:generate --force
sed -i.bak "s/^APP_PORT=.*/APP_PORT=$port/" .env && rm .env.bak
overrides > pubspec_overrides.yaml
[ -z "${CI:-}" ] || "$parent/dox/ci/system-sqlite.sh" pubspec.yaml
dart pub get

add_all() {
  for p in "${packages[@]}"; do
    echo "::group::dox add $p"
    # shellcheck disable=SC2086 # split the package and its options
    dox add $p
    echo "::endgroup::"
  done
}

add_all
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
dox migrate

dart run bin/server.dart > "$work/server.log" 2>&1 &
pid=$!
trap 'kill $pid 2>/dev/null || true' EXIT
ok=""
for _ in $(seq 1 120); do
  if curl -fsS "http://127.0.0.1:$port/ping" >/dev/null 2>&1; then ok=1; break; fi
  sleep 1
done
if [ -z "$ok" ]; then
  echo "::error::the server did not answer /ping"
  cat "$work/server.log"
  exit 1
fi
echo "GET /ping -> $(curl -fsS "http://127.0.0.1:$port/ping")"
kill $pid
wait $pid 2>/dev/null || true

# keep this state, then add every package again
git init -q
git add -A
git -c user.name=ci -c user.email=ci@example.com commit -qm "after the first dox add"
add_all
if [ -n "$(git status --porcelain)" ]; then
  echo "::error::the second dox add changed files"
  git status --short
  git diff
  exit 1
fi
echo "dox add check passed"

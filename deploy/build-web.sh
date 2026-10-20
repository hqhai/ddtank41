#!/usr/bin/env bash
# Build the ASP.NET web apps (Tank.Request = game "Request" API, Tank.Flash = portal/login site)
# and assemble deployable folders.
#   usage: deploy/build-web.sh [OUT_DIR]        (default: deploy/out/web)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/deploy/out/web}"
TMP="$ROOT/deploy/out/.build-web"
SRC="$TMP/src"
rm -rf "$SRC" && mkdir -p "$SRC" "$OUT"
(cd "$ROOT" && tar -cf - --exclude=bin --exclude=obj libdll packages Bussiness SqlDataProvider Game.Base \
   Road.Flash Tank.Request Tank.Flash) | tar -xf - -C "$SRC"
python3 -I "$ROOT/deploy/gen_web_csproj.py" "$SRC"

for app in Tank.Request Tank.Flash; do
  echo "==> building $app"
  dotnet build "$SRC/$app/$app.build.csproj" -c Release -nologo -v q -o "$TMP/$app"
  dest="$OUT/$app"
  mkdir -p "$dest/bin"
  # site content: everything except sources / project files / VS folders
  (cd "$ROOT/$app" && tar -cf - --exclude=bin --exclude=obj --exclude=.vs --exclude='*.cs' --exclude='*.csproj' \
      --exclude='*.csproj.user' --exclude='*.sln' --exclude='*.bak' --exclude=Properties --exclude=lib .) | tar -xf - -C "$dest"
  # language files etc. that live in the committed bin folder
  [ -d "$ROOT/$app/bin/Languages" ] && cp -r "$ROOT/$app/bin/Languages" "$dest/bin/"
  cp "$TMP/$app"/*.dll "$dest/bin/"
  rm -f "$dest"/bin/System.Configuration*.dll "$dest"/bin/System.ServiceProcess.dll
done
echo "==> done: $OUT"

#!/usr/bin/env bash
# Build Center/Fighting/Road services from source and assemble ready-to-run folders.
#   usage: deploy/build-server.sh [OUT_DIR]      (default: deploy/out/server)
# Requires: .NET SDK 6+ (builds net472/net48 via reference assemblies). Run with Mono on Linux,
# or directly on Windows (.NET Framework 4.8).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/deploy/out/server}"
TMP="$ROOT/deploy/out/.build"
mkdir -p "$OUT" "$TMP"

# build from a clean copy so the committed bin/obj folders in the repo are left untouched
SRC="$TMP/src"
rm -rf "$SRC" && mkdir -p "$SRC"
(cd "$ROOT" && tar -cf - --exclude=bin --exclude=obj libdll packages Bussiness SqlDataProvider \
   Game.Base Game.Logic Game.Server Center.Server Center.Service Fighting.Server Fighting.Service Road.Service) \
  | tar -xf - -C "$SRC"

for svc in Center Fighting Road; do
  p="$svc.Service"
  echo "==> building $p"
  dotnet build "$SRC/$p/$p.csproj" -c Release -nologo -v q -clp:ErrorsOnly -o "$TMP/$p"
  dest="$OUT/$p"
  mkdir -p "$dest"
  # runtime data (maps, bombs, languages, ...) shipped with the repo
  (cd "$ROOT/$p/bin/Debug/net48" && find . -type f ! -name '*.dll' ! -name '*.pdb' ! -name '*.exe' ! -name '*.config' ! -name '*.nrproj' ! -name '*.xml' -exec cp --parents {} "$dest/" \;)
  cp -r "$ROOT/$p/bin/Debug/net48/Languages" "$dest/" 2>/dev/null || true
  cp "$TMP/$p"/*.dll "$TMP/$p"/*.exe "$TMP/$p/$p.exe.config" "$dest/"
  cp "$ROOT/$p/logconfig.xml" "$dest/"
  [ -f "$ROOT/$p/battle.xml" ] && cp "$ROOT/$p/battle.xml" "$dest/"
  # never ship Windows copies of framework assemblies (they break Mono)
  rm -f "$dest"/System.Configuration*.dll "$dest"/System.ServiceProcess.dll
done
echo "==> done: $OUT"

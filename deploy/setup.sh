#!/usr/bin/env bash
# One-shot: build everything and assemble a ready-to-run deployment in deploy/out/.
#   deploy/setup.sh            build + download resources + configure
#   deploy/setup.sh configure  only re-apply deploy/server.env to the configs
#
# Layout produced:
#   deploy/out/server/{Center,Fighting,Road}.Service   game servers (run with mono, or natively on Windows)
#   deploy/out/web/{Tank.Flash,Tank.Request}           ASP.NET sites (portal "/" and API "/request")
#   deploy/out/site/{flash,resource,ruffle}            static files: Flash client, resources, Ruffle
#   deploy/out/sql/                                    SQL to run after restoring the databases
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
D="$ROOT/deploy"
OUT="$D/out"
RUFFLE_VERSION=0.7.1
DEJAVU_VERSION=2.37.3

[ -f "$D/server.env" ] || cp "$D/server.env.example" "$D/server.env"

if [ "${1:-}" != "configure" ]; then
  "$D/build-server.sh" "$OUT/server"
  "$D/build-web.sh" "$OUT/web"
  "$D/fetch-resources.sh" "$OUT/site"

  echo "==> assembling flash client"
  rm -rf "$OUT/site/flash"
  cp -r "$ROOT/Source Flash/FlashSV1" "$OUT/site/flash"
  cp -r "$OUT/site/flash-extra/." "$OUT/site/flash/"
  rm -f "$OUT/site/flash/"*.bak
  # the client also reads a few client data files from the resource site
  mkdir -p "$OUT/site/resource/flash"
  cp "$OUT/site/flash/"{characterdefine.xml,partical.xml,particallite.xml} "$OUT/site/resource/flash/"

  if [ ! -f "$OUT/site/ruffle/ruffle.js" ]; then
    echo "==> downloading Ruffle $RUFFLE_VERSION"
    mkdir -p "$OUT/cache" "$OUT/site/ruffle"
    curl -fsSL -o "$OUT/cache/ruffle.tgz" "https://registry.npmjs.org/@ruffle-rs/ruffle/-/ruffle-$RUFFLE_VERSION.tgz"
    tar -xzf "$OUT/cache/ruffle.tgz" -C "$OUT/site/ruffle" --strip-components=1
  fi
  if [ ! -f "$OUT/site/fonts/DejaVuSans.ttf" ]; then
    echo "==> downloading DejaVu fonts (Vietnamese glyphs for Ruffle's device text)"
    mkdir -p "$OUT/cache/dejavu" "$OUT/site/fonts"
    curl -fsSL -o "$OUT/cache/dejavu.tgz" "https://registry.npmjs.org/dejavu-fonts-ttf/-/dejavu-fonts-ttf-$DEJAVU_VERSION.tgz"
    tar -xzf "$OUT/cache/dejavu.tgz" -C "$OUT/cache/dejavu" --strip-components=1
    cp "$OUT/cache/dejavu/ttf/"{DejaVuSans,DejaVuSans-Bold,DejaVuSerif,DejaVuSansMono}.ttf "$OUT/site/fonts/"
  fi
fi

echo "==> configuring"
rm -rf "$OUT/sql" && mkdir -p "$OUT/sql"
cp "$D"/sql/*.sql "$OUT/sql/" 2>/dev/null || true
python3 -I "$D/configure.py" "$D/server.env" "$OUT"
echo "==> deployment ready in $OUT"

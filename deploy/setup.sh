#!/usr/bin/env bash
# Build everything and assemble a ready-to-run deployment in deploy/out/ (or $OUT).
#   deploy/setup.sh            build + download resources + assemble + configure
#   deploy/setup.sh assemble   only assemble the static site (flash client, Ruffle, fonts)
#   deploy/setup.sh configure  only re-apply deploy/server.env to the configs
#
# Layout produced:
#   out/server/{Center,Fighting,Road}.Service   game servers (run with mono, or natively on Windows)
#   out/web/{Tank.Flash,Tank.Request}           ASP.NET sites (portal "/" and API "/request")
#   out/site/{flash,resource,ruffle,fonts}      static files: Flash client, resources, Ruffle
#   out/sql/                                    SQL to run after restoring the databases
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
D="$ROOT/deploy"
OUT="${OUT:-$D/out}"
MODE="${1:-all}"
RUFFLE_VERSION=0.7.1
DEJAVU_VERSION=2.37.3

assemble() {
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
}

configure() {
  [ -f "$D/server.env" ] || cp "$D/server.env.example" "$D/server.env"
  echo "==> configuring"
  rm -rf "$OUT/sql" && mkdir -p "$OUT/sql"
  cp "$D"/sql/*.sql "$OUT/sql/"
  python3 -I "$D/configure.py" "$D/server.env" "$OUT"
}

case "$MODE" in
  all)
    "$D/build-server.sh" "$OUT/server"
    "$D/build-web.sh" "$OUT/web"
    "$D/fetch-resources.sh" "$OUT/site"
    assemble
    configure
    ;;
  assemble) assemble ;;
  configure) configure ;;
  *) echo "usage: $0 [all|assemble|configure]"; exit 1 ;;
esac
echo "==> done ($OUT)"

#!/usr/bin/env bash
# Download the Flash client "resource" site (item/equipment images, maps, bomb SWFs, sounds...) that is
# NOT included in this repository, and the few SWFs missing from Source Flash/FlashSV1.
#
# The original resource CDN (gunny.vcdn.vn) is dead. The files are taken from two public GitHub repos
# of the same game family and merged (later source wins on conflicts):
#   1. dk-khoado/Gunny-3.0   inetpub/wwwroot/Resource      (~600 MB, most complete: 14k equip images, 260 maps)
#                            inetpub/wwwroot/gunny/bombs + Catharine.swf (missing from FlashSV1)
#   2. phucdz2kk4/Gunny      Tank.Flash/resource/v1.1      (~140 MB, the 4.1 assets for this exact client)
#
#   usage: deploy/fetch-resources.sh [OUT_DIR]       (default: deploy/out/site)
#   result: OUT_DIR/resource/...   and   OUT_DIR/flash-extra/{bombs/,Catharine.swf}
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/deploy/out/site}"
CACHE="$ROOT/deploy/out/cache"
mkdir -p "$CACHE" "$OUT/resource" "$OUT/flash-extra"

# repo  commit  sparse paths...
sparse_clone() {
  local url="$1" commit="$2" dir="$3"; shift 3
  if [ ! -d "$dir/.git" ]; then
    git clone --filter=blob:none --no-checkout "$url" "$dir"
  fi
  git -C "$dir" sparse-checkout set --no-cone "$@"
  git -C "$dir" checkout -q "$commit"
}

echo "==> fetching dk-khoado/Gunny-3.0"
G3="$CACHE/Gunny-3.0"
sparse_clone https://github.com/dk-khoado/Gunny-3.0 16e24b119f96b93b34ddb148f9a035f71a234e67 "$G3" \
  /inetpub/wwwroot/Resource/ /inetpub/wwwroot/gunny/bombs/ /inetpub/wwwroot/gunny/Catharine.swf

echo "==> fetching phucdz2kk4/Gunny (resource only)"
G4="$CACHE/Gunny-4.1"
sparse_clone https://github.com/phucdz2kk4/Gunny 057c71aab877b42ebf08258aa5c642adc6a039ec "$G4" \
  /Tank.Flash/resource/v1.1/

echo "==> merging into $OUT/resource"
cp -r "$G3/inetpub/wwwroot/Resource/." "$OUT/resource/"
cp -r "$G4/Tank.Flash/resource/v1.1/." "$OUT/resource/"
rm -f "$OUT/resource/web.config"

cp -r "$G3/inetpub/wwwroot/gunny/bombs" "$OUT/flash-extra/"
cp "$G3/inetpub/wwwroot/gunny/Catharine.swf" "$OUT/flash-extra/"

echo "==> done ($(du -sh "$OUT/resource" | cut -f1) of resources)"

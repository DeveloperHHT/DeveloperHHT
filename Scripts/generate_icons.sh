#!/usr/bin/env bash
# Generates icon tiles for technologies that skillicons.dev does not serve.
# Each tile is a 256x256 rounded dark square (same look as skillicons' dark
# theme) with a single-colour glyph in the middle.
#
# Usage:  ./Scripts/generate_icons.sh
# Output: assets/icons/<name>.svg
# Needs only bash and curl. Safe to re-run: every file is rewritten.
#
# Glyph sources:
#   simple-icons (24x24 viewBox)  https://github.com/simple-icons/simple-icons
#   devicon      (128x128 viewBox) https://github.com/devicons/devicon
# Both are fetched at generation time; the glyph path is copied INTO the tile,
# so the finished SVGs have no external references.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/assets/icons"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

SI_VERSION="13.21.0"
TILE="#242938"   # skillicons dark tile colour
GLYPH=176        # glyph size inside the 256 tile (skillicons fills about this much)

fetch() { curl -fsSL --max-time 30 "$1" -o "$2"; }

# tile <name> <source: si|dv> <slug> <colour>
tile() {
  local name="$1" src="$2" slug="$3" colour="$4" url vb raw

  if [ "$src" = "si" ]; then
    url="https://cdn.jsdelivr.net/npm/simple-icons@${SI_VERSION}/icons/${slug}.svg"; vb=24
  else
    url="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${slug}/${slug}-plain.svg"; vb=128
  fi

  raw="$TMP/$name.raw.svg"
  fetch "$url" "$raw" || { echo "FAILED  $name ($url)" >&2; return 1; }

  # Collect every path's "d" attribute (a glyph may be split into several paths).
  local paths
  paths="$(tr '\n' ' ' < "$raw" | grep -oE ' d="[^"]+"' | sed -E 's/^ d="/<path d="/; s/"$/"\/>/')"
  [ -n "$paths" ] || { echo "FAILED  $name (no path found)" >&2; return 1; }

  # scale glyph to GLYPH px and centre it in the 256 tile
  local scale offset milli
  milli=$(( GLYPH * 1000 / vb ))                       # scale in thousandths, integer maths only
  scale="$(printf '%d.%03d' $(( milli / 1000 )) $(( milli % 1000 )))"
  offset="$(( (256 - GLYPH) / 2 ))"

  cat > "$OUT/$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-label="$name">
  <title>$name</title>
  <rect width="256" height="256" rx="60" fill="$TILE"/>
  <g transform="translate($offset $offset) scale($scale)" fill="$colour">
$(printf '%s\n' "$paths" | sed 's/^/    /')
  </g>
</svg>
SVG
  echo "wrote   assets/icons/$name.svg"
}

# name          src  slug              glyph colour (lightened where the brand colour is too dark)
tile pandas       si  pandas            "#e70488"
tile numpy        si  numpy             "#4dabcf"
tile trello       si  trello            "#2684ff"
tile slack        si  slack             "#e01e5a"
tile canva        si  canva             "#00c4cc"
tile pytest       si  pytest            "#0a9edc"
tile sqlalchemy   si  sqlalchemy        "#f0432a"
tile expo         si  expo              "#f0f6fc"
tile huggingface  si  huggingface       "#ffd21e"
tile claude       si  claude            "#d97757"
tile openai       si  openai            "#f0f6fc"
tile gemini       si  googlegemini      "#a98fd6"
tile nvidia       si  nvidia            "#76b900"
tile mssql        dv  microsoftsqlserver "#ee352c"
tile playwright   dv  playwright        "#45ba4b"

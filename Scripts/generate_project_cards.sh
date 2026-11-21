#!/usr/bin/env bash
# Generates the project card SVGs used in the profile README.
# Usage: ./Scripts/generate_project_cards.sh
# Output: assets/cards/<repo-name>.svg
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/assets/cards"
mkdir -p "$OUT"

# card <file-name> <language> <language-color> <line1> <line2> <line3> <tags>
# Set TITLE=... before the call to show a title different from the file name.
# Text is XML-escaped by the caller (use &amp; for an ampersand).
card() {
  local repo="$1" lang="$2" color="$3" l1="$4" l2="$5" l3="$6" tags="$7"
  local title="${TITLE:-$repo}"
  local size=17
  # long titles get a smaller font so they stay inside the card
  if [ "${#title}" -gt 34 ]; then size=14; fi

  cat > "$OUT/$repo.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 170" width="420" height="170" role="img" aria-label="$repo">
  <defs>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#58a6ff"/><stop offset="1" stop-color="#bc8cff"/>
    </linearGradient>
  </defs>
  <style>
    .sans { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; }
    .mono { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
    .shine { animation: shine 4s ease-in-out infinite; }
    @keyframes shine { 0%,100% { opacity: .55; } 50% { opacity: 1; } }
  </style>
  <rect x="1" y="1" width="418" height="168" rx="14" fill="#0d1117" stroke="#30363d" stroke-width="2"/>
  <rect class="shine" x="1" y="1" width="418" height="4" rx="2" fill="url(#accent)"/>

  <text class="sans" x="24" y="42" font-size="$size" font-weight="700" fill="#58a6ff">$title</text>

  <text class="sans" x="24" y="72"  font-size="14" fill="#c9d1d9">$l1</text>
  <text class="sans" x="24" y="94"  font-size="14" fill="#c9d1d9">$l2</text>
  <text class="sans" x="24" y="116" font-size="14" fill="#c9d1d9">$l3</text>

  <line x1="24" y1="130" x2="396" y2="130" stroke="#21262d"/>
  <circle cx="30" cy="150" r="6" fill="$color"/>
  <text class="sans" x="44" y="155" font-size="13" fill="#8b949e">$lang</text>
  <text class="mono" x="396" y="155" font-size="12" fill="#7d8590" text-anchor="end">$tags</text>
</svg>
SVG
  echo "wrote $OUT/$repo.svg"
}

card "Defect-Detection-using-Deep-Learning" "Python" "#3572A5" \
  "A CNN that sorts photos of metal buttons" \
  "into OK and defective, with metrics," \
  "figures and a command line." \
  "tensorflow · cnn"

card "Realtime-Handwritten-Digit-Recognition" "Python" "#3572A5" \
  "A CNN trained on MNIST (99.1% test" \
  "accuracy). Draw a digit, use a webcam" \
  "or read image files." \
  "tensorflow · opencv"

card "Denpointment" "Python" "#3572A5" \
  "A dentist appointment system with Flask:" \
  "booking, treatments and statistics. Layered" \
  "backend, light/dark interface, tests, guide." \
  "flask · refactor"

# Work projects: private, so no code or screenshots. Described in general terms only.
TITLE="Question-answering assistants" card "private-customer-assistants" "Private · work" "#8b949e" \
  "Assistants that read incoming customer" \
  "questions and draft accurate, kind replies." \
  "" \
  "llm · customer experience"

TITLE="Agent teams for content and marketing" card "private-agent-teams" "Private · work" "#8b949e" \
  "Agents that work side by side, from SEO" \
  "analysis to promotional film production." \
  "" \
  "multi-agent · generative ai"

TITLE="Business processes and ERP" card "private-business-processes" "Private · work" "#8b949e" \
  "Following daily workflows, finding where" \
  "work gets stuck and smoothing it out," \
  "including the ERP side." \
  "processes · erp"

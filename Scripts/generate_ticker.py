#!/usr/bin/env python3
"""Generates assets/ticker.svg: a slowly scrolling strip of what I work with.

Usage:  python3 Scripts/generate_ticker.py
Needs only the standard library. The strip is two identical copies of the item list that slide
left by exactly one copy, so the loop has no visible jump. Item widths are fixed with textLength,
so the loop length does not depend on the font the viewer happens to have.
"""
from pathlib import Path
from xml.sax.saxutils import escape

ITEMS = [
    "LLM agents", "tool calling", "RAG", "evals and guardrails", "multi-agent systems",
    "YOLO and OCR", "NVIDIA Jetson Orin NX", "FastAPI", "Docker and CI/CD", "Google Cloud Run",
]
WIDTH, HEIGHT = 1200, 52
CHAR = 9.6      # width of one character at 16px in a monospace font
GAP = 56        # space between two items, with the separator in the middle
SPEED = 38      # pixels per second

OUT = Path(__file__).resolve().parents[1] / "assets" / "ticker.svg"


def strip(offset: float):
    """The items of one copy, starting at x=offset. Returns (svg, width of the copy)."""
    parts, x = [], offset
    for item in ITEMS:
        length = round(len(item) * CHAR, 1)
        parts.append(f'<text class="mono" x="{x:.1f}" y="32" font-size="16" fill="#c9d1d9" '
                     f'textLength="{length}" lengthAdjust="spacing">{escape(item)}</text>')
        x += length + GAP / 2
        parts.append(f'<circle cx="{x:.1f}" cy="26" r="3" fill="url(#accent)"/>')
        x += GAP / 2
    return "\n      ".join(parts), x - offset


def main() -> None:
    first, copy_width = strip(0)
    second, _ = strip(copy_width)
    duration = round(copy_width / SPEED, 1)
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" width="{WIDTH}" height="{HEIGHT}" role="img" aria-labelledby="t">
  <title id="t">What I work with: LLM agents, tool calling, RAG, evals, computer vision, edge AI and production</title>
  <defs>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#58a6ff"/><stop offset="1" stop-color="#bc8cff"/>
    </linearGradient>
    <linearGradient id="edge" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#fff" stop-opacity="0"/>
      <stop offset=".08" stop-color="#fff"/>
      <stop offset=".92" stop-color="#fff"/>
      <stop offset="1" stop-color="#fff" stop-opacity="0"/>
    </linearGradient>
    <mask id="fade"><rect width="{WIDTH}" height="{HEIGHT}" fill="url(#edge)"/></mask>
  </defs>
  <style>
    .mono {{ font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace; }}
    .slide {{ animation: slide {duration}s linear infinite; }}
    @keyframes slide {{ to {{ transform: translateX(-{copy_width:.1f}px); }} }}
  </style>
  <rect x="1" y="1" width="{WIDTH - 2}" height="{HEIGHT - 2}" rx="12" fill="#0d1117" stroke="#30363d" stroke-width="2"/>
  <g mask="url(#fade)">
    <g class="slide">
      {first}
      {second}
    </g>
  </g>
</svg>
'''
    OUT.write_text(svg, encoding="utf-8")
    print(f"wrote {OUT} (loop {duration}s)")


if __name__ == "__main__":
    main()

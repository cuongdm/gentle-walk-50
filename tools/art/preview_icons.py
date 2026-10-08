#!/usr/bin/env python3
"""Write the icon preview sheet: every AppIcon (Bold + Fill) at 20/28/36 pt on the watercolour-wash chip,
on app paper (light) and the dark background, labelled by concept. Reads the asset catalog that
build_icons.py produced, so it shows exactly what ships. Stdlib only, self-contained HTML (inline SVG).

    python3 tools/art/preview_icons.py
    open docs/design/research-2026-10-08/icon-sources/app-icons-preview.html   # ?part=1&of=5 for slices

Colours: glyph = the "-ink" tint (light) / light tint (dark) from nguon-icon.md section 4a; wash = the
role colour at 16 % (the IconChip rule). The wash outline is the app's WashShape (4 lobes, variant
hashed from the key) so neighbours differ the same way they will in the app.
"""
import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "tools/art/icons-manifest.json"
CATALOG = ROOT / "iOS/App/Assets.xcassets/Icons"
OUT = ROOT / "docs/design/research-2026-10-08/icon-sources/app-icons-preview.html"

# glyph (light, dark) and wash colours per role, from nguon-icon.md 4a
TINTS = {
    "sap": ("#4C6A2C", "#9DBE78", "#5E7F3A"),
    "sky": ("#3F6A8A", "#9DBBD4", "#7FA3C0"),
    "ochre": ("#8A5F12", "#E0B45A", "#D9A441"),
    "sienna": ("#964624", "#E0915F", "#A9512C"),
    "danger": ("#A8463B", "#D9776B", "#C0533F"),
}
# two-tone icons (LayeredIcon): figure = ink at 55 %, mark = sienna; chip wash = ochre 24 % (section 2c)
LAYER_INK = {"light": "#2A241F", "dark": "#EDE4D6"}
LAYER_MARK = {"light": "#A9512C", "dark": "#E0915F"}
LAYER_WASH = {"light": "#D9A441", "dark": "#E0B45A"}
SIZES = (20, 28, 36)
CHIP = {20: 36, 28: 50, 36: 64}


def symbol(asset):
    svg = (CATALOG / f"{asset}.imageset/{asset}.svg").read_text()
    inner = re.sub(r"^<svg[^>]*>|</svg>\s*$", "", svg.strip())
    attrs = re.search(r"^<svg([^>]*)>", svg.strip()).group(1)
    root_fill = ' fill="currentColor"' if 'fill="#000000"' in attrs else ""
    inner = inner.replace("#000000", "currentColor")
    return f'<symbol id="i-{asset}" viewBox="0 0 256 256"{root_fill}>{inner}</symbol>'


def main():
    manifest = json.loads(MANIFEST.read_text())
    icons = manifest["icons"]
    symbols, rows = [], []
    for icon in icons:
        layers = ("-base", "-base-fill", "-mark") if icon.get("layers") else ()
        for suffix in ("", "-fill") + layers:
            symbols.append(symbol(icon["asset"] + suffix))
    for index, icon in enumerate(icons):
        light, dark, wash = TINTS[icon["tint"]]
        cells = []
        for theme, glyph_colour in (("light", light), ("dark", dark)):
            wash_colour = wash if theme == "light" else dark
            wash_opacity = 0.16
            if icon.get("layers"):
                wash_colour, wash_opacity = LAYER_WASH[theme], 0.24
            chips = []
            for weight in ("", "-fill"):
                for size in SIZES:
                    if icon.get("layers"):
                        glyph = (f'<svg class="glyph" style="color:{LAYER_INK[theme]};opacity:.55">'
                                 f'<use href="#i-{icon["asset"]}-base{weight}"/></svg>'
                                 f'<svg class="glyph layer" style="color:{LAYER_MARK[theme]}">'
                                 f'<use href="#i-{icon["asset"]}-mark"/></svg>')
                    else:
                        glyph = f'<svg class="glyph"><use href="#i-{icon["asset"]}{weight}"/></svg>'
                    chips.append(
                        f'<span class="chip" style="--c:{CHIP[size]}px;--g:{size}px;color:{glyph_colour}">'
                        f'<svg class="wash" viewBox="0 0 100 100" data-key="{icon["asset"]}" '
                        f'data-opacity="{wash_opacity}" style="color:{wash_colour}"></svg>{glyph}</span>')
                chips.append('<span class="sep"></span>' if weight == "" else "")
            cells.append(f'<td class="{theme}">{"".join(chips)}</td>')
        source = "Phosphor" if icon["source"] == "phosphor" else (
            "custom two-tone (LayeredIcon)" if icon.get("layers") else "custom")
        label = (f'<td class="label"><b>{html.escape(icon["concept"])}</b><br>'
                 f'<code>AppIcon.{camel(icon["asset"])}</code> · {source} <code>{icon["glyph"]}</code> · {icon["tint"]}'
                 f'<br><span class="meaning">{html.escape(icon["meaning"])}</span></td>')
        rows.append(f'<tr data-i="{index}">{label}{"".join(cells)}</tr>')
    pin = manifest["phosphor"]
    page = TEMPLATE.format(
        count=len(icons),
        phosphor=sum(i["source"] == "phosphor" for i in icons),
        custom=sum(i["source"] == "custom" for i in icons),
        version=pin["version"],
        symbols="\n".join(symbols),
        rows="\n".join(rows),
    )
    OUT.write_text(page)
    print(f"wrote {OUT.relative_to(ROOT)} ({len(icons)} concepts)")


def camel(asset):
    head, *rest = asset.split("-")
    return head + "".join(w.upper() if w == "tv" else w.capitalize() for w in rest)


TEMPLATE = """<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Good Footing icons</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Generated by tools/art/preview_icons.py; do not edit. -->
<style>
  body {{ margin: 0; font: 13px/1.35 -apple-system, system-ui, sans-serif; color: #2A241F; background: #F8F1E6; }}
  header {{ padding: 14px 16px 6px; }}
  h1 {{ font: 600 20px ui-serif, Georgia, serif; margin: 0 0 4px; }}
  table {{ border-collapse: collapse; }}
  td {{ padding: 6px 12px; border-bottom: 1px solid #E4D9C6; vertical-align: middle; white-space: nowrap; }}
  td.label {{ width: 380px; white-space: normal; }}
  td.dark {{ background: #1F1B17; border-bottom-color: #3a332c; }}
  td.light {{ background: #F8F1E6; }}
  code {{ font: 11px ui-monospace, Menlo, monospace; }}
  .meaning {{ color: #5b5149; font-size: 12px; }}
  .chip {{ position: relative; display: inline-flex; align-items: center; justify-content: center;
           width: var(--c); height: var(--c); margin-right: 8px; vertical-align: middle; }}
  .wash {{ position: absolute; inset: 0; width: 100%; height: 100%; }}
  .glyph {{ position: relative; width: var(--g); height: var(--g); }}
  .glyph.layer {{ position: absolute; }}
  .sep {{ display: inline-block; width: 1px; height: 40px; background: #CDBFA8; margin: 0 12px 0 4px; vertical-align: middle; }}
  td.dark .sep {{ background: #4a4239; }}
  th {{ text-align: left; padding: 6px 12px; font-weight: 600; }}
</style></head>
<body>
<header><h1>App icons</h1>
{count} concepts: {phosphor} Phosphor {version} (Bold = normal, Fill = selected) and {custom} custom glyphs on the same grid and weight.
Each half: Bold at 20 / 28 / 36 pt, then Fill at 20 / 28 / 36 pt, on the watercolour wash (role colour 16 %).
Body and limitation icons are two-tone (<code>LayeredIcon</code>): figure in ink at 55 %, mark in sienna, on an ochre wash (24 %).</header>
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
{symbols}
</svg>
<table><thead><tr><th>Concept</th><th>Light (#F8F1E6)</th><th style="background:#1F1B17;color:#EDE4D6">Dark (#1F1B17)</th></tr></thead>
<tbody>
{rows}
</tbody></table>
<script>
// WashShape from IconChip.swift: four lobes, radii per variant, variant hashed from the key.
const LOBES = [[1.00, 0.90, 0.97, 0.86], [0.92, 1.00, 0.86, 0.95], [0.88, 0.94, 1.00, 0.90], [0.97, 0.86, 0.92, 1.00]];
function variant(key) {{ let s = 0; for (const ch of key) s = (s + ch.codePointAt(0)) % 997; return s % LOBES.length; }}
function washPath(key) {{
  const r = LOBES[variant(key)], c = 50, h = 50;
  const pts = [0, 1, 2, 3].map(i => {{ const a = i * Math.PI / 2; return [c + Math.cos(a) * h * r[i], c + Math.sin(a) * h * r[i]]; }});
  let d = `M${{pts[0][0]}} ${{pts[0][1]}}`;
  for (let i = 0; i < 4; i++) {{
    const n = pts[(i + 1) % 4], a = i * Math.PI / 2 + Math.PI / 4, k = 1.32 * (r[i] + r[(i + 1) % 4]) / 2;
    d += `Q${{c + Math.cos(a) * h * k}} ${{c + Math.sin(a) * h * k}} ${{n[0]}} ${{n[1]}}`;
  }}
  return d + 'Z';
}}
for (const svg of document.querySelectorAll('svg.wash')) {{
  svg.innerHTML = `<path d="${{washPath(svg.dataset.key)}}" fill="currentColor" fill-opacity="${{svg.dataset.opacity}}"/>`;
}}
// ?part=N&of=M shows the Nth of M slices of the rows, for screenshots.
const query = new URLSearchParams(location.search);
const part = Number(query.get('part')), of = Number(query.get('of')) || 4;
if (part) {{
  const rows = [...document.querySelectorAll('tbody tr')], per = Math.ceil(rows.length / of);
  rows.forEach((row, i) => {{ if (Math.floor(i / per) + 1 !== part) row.remove(); }});
}}
</script>
</body></html>
"""


if __name__ == "__main__":
    main()

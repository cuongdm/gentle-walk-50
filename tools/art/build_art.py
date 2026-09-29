#!/usr/bin/env python3
"""Cut illustration sheets into single images for the app's asset catalog.

Source sheets live in assets/art/ (drawn in the ChatGPT thread "Gental Walk", character
version B = the coach from the exercise clips, gouache/watercolour style). Each sheet is an
equal grid; tools/art/art-manifest.json names every cell. Output:
iOS/App/Assets.xcassets/Art/<name>.imageset/<name>.jpg (+ Contents.json). Figures (a person or a tree
on plain paper) become PNGs whose paper is transparent, so they sit on any card without a seam.

    python3 tools/art/build_art.py            # build everything in the manifest
    python3 tools/art/build_art.py --check    # list manifest names missing from the catalog
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "tools/art/art-manifest.json"
CATALOG = ROOT / "iOS/App/Assets.xcassets/Art"
BACKGROUND = (0xFF, 0xF8, 0xEF)  # Palette.bg (light)


def is_background(pixel, tolerance):
    return all(abs(int(c) - b) <= tolerance for c, b in zip(pixel[:3], BACKGROUND))


def trim(image, tolerance=18, margin=0.04):
    """Crop to the painted area (everything that is not cream), then add a cream margin."""
    rgb = image.convert("RGB")
    diff = Image.new("RGB", rgb.size, BACKGROUND)
    from PIL import ImageChops
    delta = ImageChops.difference(rgb, diff).convert("L").point(lambda v: 255 if v > tolerance else 0)
    box = delta.getbbox()
    if box is None:
        return rgb
    left, top, right, bottom = box
    pad = int(max(right - left, bottom - top) * margin)
    left, top = max(0, left - pad), max(0, top - pad)
    right, bottom = min(rgb.width, right + pad), min(rgb.height, bottom + pad)
    return rgb.crop((left, top, right, bottom))


def content_runs(ratios, count, min_share=0.08):
    """Longest `count` runs of non-gutter lines, in order (ratios: gutter share per line)."""
    runs, start = [], None
    for i, r in enumerate(ratios + [1.0]):
        if r < 0.9 and start is None:
            start = i
        elif r >= 0.9 and start is not None:
            runs.append((start, i))
            start = None
    runs = [r for r in runs if r[1] - r[0] >= min_share * len(ratios)]
    return sorted(sorted(runs, key=lambda r: r[0] - r[1])[:count])


def strip_edges(image, tolerance=14, limit=0.05):
    """Drop leftover cream gutter lines along each edge (at most `limit` of the side)."""
    px, w, h = image.load(), image.width, image.height

    def share(points):
        points = list(points)
        return sum(is_background(px[x, y], tolerance) for x, y in points) / len(points)

    left, top, right, bottom = 0, 0, w - 1, h - 1
    while left < w * limit and share((left, y) for y in range(0, h, 3)) > 0.4: left += 1
    while right > w * (1 - limit) and share((right, y) for y in range(0, h, 3)) > 0.4: right -= 1
    while top < h * limit and share((x, top) for x in range(0, w, 3)) > 0.4: top += 1
    while bottom > h * (1 - limit) and share((x, bottom) for x in range(0, w, 3)) > 0.4: bottom -= 1
    inset = 2  # the painter's soft edge next to the gutter
    return image.crop((left + inset, top + inset, right - inset + 1, bottom - inset + 1))


def split_scenes(image, cols, rows, tolerance=14):
    """Scenes are separated by cream gutters that are not always centred: find them."""
    rgb = image.convert("RGB")
    small = rgb.resize((rgb.width // 2, rgb.height // 2))
    px, w, h = small.load(), small.width, small.height
    col_ratio = [sum(is_background(px[x, y], tolerance) for y in range(0, h, 3)) / len(range(0, h, 3)) for x in range(w)]
    cells = []
    xs = content_runs(col_ratio, cols)
    if len(xs) != cols:  # gutter too thin to see: fall back to an even split
        xs = [(round(c * w / cols), round((c + 1) * w / cols)) for c in range(cols)]
    bands = []
    for x0, x1 in xs:
        row_ratio = [sum(is_background(px[x, y], tolerance) for x in range(x0, x1, 3)) / len(range(x0, x1, 3)) for y in range(h)]
        runs = content_runs(row_ratio, rows)
        if len(runs) != rows:
            runs = [(round(r * h / rows), round((r + 1) * h / rows)) for r in range(rows)]
        bands.append(runs)
    for r in range(rows):
        for c, (x0, x1) in enumerate(xs):
            y0, y1 = bands[c][r]
            cells.append(strip_edges(rgb.crop((2 * x0, 2 * y0, 2 * x1, 2 * y1))))
    return cells


def paper_to_alpha(image, floor=0.06):
    """Make the paper transparent ("colour to alpha"): the paper colour is read from the border,
    each pixel keeps only how far it is from it, so soft shadows stay soft."""
    rgb = np.asarray(image.convert("RGB")).astype(np.float64)
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    paper = np.median(border, axis=0)
    darker = np.where(rgb < paper, (paper - rgb) / np.maximum(paper, 1), 0)
    lighter = np.where(rgb > paper, (rgb - paper) / np.maximum(255 - paper, 1), 0)
    alpha = np.maximum(darker, lighter).max(axis=2)
    alpha = np.clip((alpha - floor) / (1 - floor), 0, 1)  # paper grain stays fully clear
    safe = np.where(alpha > 0, alpha, 1)[..., None]
    colour = np.clip((rgb - paper) / safe + paper, 0, 255)
    out = np.dstack([colour, alpha * 255]).astype(np.uint8)
    return Image.fromarray(out)


def write_imageset(name, image, max_side, transparent=False):
    image.thumbnail((max_side, max_side), Image.LANCZOS)
    folder = CATALOG / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob(f"{name}.*"):
        old.unlink()  # a figure may switch from JPEG to PNG
    if transparent:
        filename = f"{name}.png"
        paper_to_alpha(image).save(folder / filename, "PNG", optimize=True)
    else:
        filename = f"{name}.jpg"
        image.save(folder / filename, "JPEG", quality=84, optimize=True, progressive=True)
    contents = {"images": [{"filename": filename, "idiom": "universal"}],
                "info": {"author": "xcode", "version": 1}}
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")
    return image.size


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    manifest = json.loads(MANIFEST.read_text())

    names = [n for sheet in manifest["sheets"] for n in sheet["cells"] if n]
    if args.check:
        missing = [n for n in names if not (CATALOG / f"{n}.imageset").exists()]
        print("missing:", ", ".join(missing) or "none")
        return 1 if missing else 0

    CATALOG.mkdir(parents=True, exist_ok=True)
    (CATALOG / "Contents.json").write_text(json.dumps(
        {"info": {"author": "xcode", "version": 1}, "properties": {"provides-namespace": False}}, indent=2) + "\n")
    for sheet in manifest["sheets"]:
        source = ROOT / sheet["source"]
        if not source.exists():
            print(f"skip {sheet['source']} (not downloaded yet)")
            continue
        image = Image.open(source).convert("RGB")
        cols, rows = sheet["grid"]
        cw, ch = image.width / cols, image.height / rows
        scenes = split_scenes(image, cols, rows) if sheet["mode"] == "scene" and "modes" not in sheet else None
        for index, name in enumerate(sheet["cells"]):
            if not name:
                continue
            c, r = index % cols, index // cols
            if scenes is not None:
                size = write_imageset(name, scenes[index], sheet.get("maxSide", 1200))
                print(f"{name}: {size[0]}x{size[1]}")
                continue
            # Figures may poke a little past their cell sideways (a chair leg); take a small bleed.
            # Never vertically: the row below starts with raised arms.
            bleed = sheet.get("bleeds", [sheet.get("bleed", 0.0)] * len(sheet["cells"]))[index]
            bx, by = cw * bleed, 0
            cell = image.crop((max(0, round(c * cw - bx)), max(0, round(r * ch - by)),
                               min(image.width, round((c + 1) * cw + bx)), min(image.height, round((r + 1) * ch + by))))
            # A sheet may mix a figure and a full scene ("modes" per cell).
            mode = sheet.get("modes", [sheet["mode"]] * len(sheet["cells"]))[index]
            # Some cells need a trim before cutting (a neighbour's chair reaching in): [l, t, r, b] of the cell.
            if name in sheet.get("insets", {}):
                l, t, r_, b = sheet["insets"][name]
                cell = cell.crop((round(cell.width * l), round(cell.height * t),
                                  round(cell.width * (1 - r_)), round(cell.height * (1 - b))))
            # "trim": false keeps the whole cell, so a series (the tree stages) keeps one scale and ground line.
            if mode != "figure":
                cut = strip_edges(cell)
            else:
                cut = trim(cell) if sheet.get("trim", True) else cell
            size = write_imageset(name, cut, sheet.get("maxSide", 1200), transparent=mode == "figure")
            print(f"{name}: {size[0]}x{size[1]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

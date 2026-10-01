#!/usr/bin/env python3
"""Move the coach sideways in a start frame without a new generation (0 credit).

Nano Banana ignores "move her to one third of the width", so a frame whose coach sits
right of the crop-safe centre band (see crop_subject_check.py --center) is fixed here:

1. erase the frame's own sparkle mark (bottom-right) by copying the best-matching patch
   from the same image, so the shift cannot carry it into the fixed crop window;
2. shift the whole picture left by --shift px (at the frame's own size);
3. fill the empty right strip with a mirror of the columns next to it (that strip is
   almost entirely outside the 1688x950 crop, which keeps x < 88% of the width).

Usage: recenter_frame.py IN.jpg OUT.jpg --shift 190 [--mark X,Y] [--preview P.png]
Run crop_subject_check.py on the result; it must PASS including the centre band.
"""
import argparse

import numpy as np
from PIL import Image, ImageFilter


def find_mark(a, box):
    """Mask of the bright, low-saturation sparkle inside box (x0, y0, x1, y1)."""
    x0, y0, x1, y1 = box
    sub = a[y0:y1, x0:x1].astype(float)
    lum = sub.mean(2)
    sat = sub.max(2) - sub.min(2)
    bg = np.median(lum)
    core = (lum > bg + 8) & (sat < 30)
    mask = np.zeros(a.shape[:2], bool)
    if core.sum() < 6:
        return mask
    ys, xs = np.where(core)
    cy, cx = int(np.median(ys)), int(np.median(xs))
    # keep the connected blob around the median point, then pad it
    keep = np.zeros_like(core)
    stack = [(cy, cx)] if core[cy, cx] else list(zip(ys, xs))[:1]
    while stack:
        y, x = stack.pop()
        if 0 <= y < core.shape[0] and 0 <= x < core.shape[1] and core[y, x] and not keep[y, x]:
            keep[y, x] = True
            stack += [(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)]
    m = Image.fromarray((keep * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9))
    mask[y0:y1, x0:x1] = np.asarray(m) > 0
    return mask


def heal(a, mask, search=220):
    """Copy the patch whose surrounding ring best matches the ring around the mask."""
    ys, xs = np.where(mask)
    y0, y1, x0, x1 = ys.min() - 12, ys.max() + 13, xs.min() - 12, xs.max() + 13
    m = mask[y0:y1, x0:x1]
    ring = ~m
    tgt = a[y0:y1, x0:x1].astype(float)
    best, off = None, (0, -60)
    for dy in range(-24, 25, 2):
        for dx in range(-search, -(x1 - x0) // 2, 3):
            if y0 + dy < 0 or y1 + dy > a.shape[0] or x0 + dx < 0:
                continue
            src = a[y0 + dy:y1 + dy, x0 + dx:x1 + dx].astype(float)
            err = ((src - tgt) ** 2).sum(2)[ring].mean()
            if best is None or err < best:
                best, off = err, (dy, dx)
    dy, dx = off
    src = a[y0 + dy:y1 + dy, x0 + dx:x1 + dx].astype(float)
    feather = np.asarray(Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(3))) / 255.0
    feather = np.clip(feather * 1.6, 0, 1)[..., None]
    out = a.copy()
    out[y0:y1, x0:x1] = (src * feather + tgt * (1 - feather)).round().astype(np.uint8)
    return out, off, best


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--shift", type=int, required=True, help="px to move the picture left")
    ap.add_argument("--mark", help="X,Y of the sparkle centre; default: search the bottom-right corner")
    ap.add_argument("--preview", help="save a before/after strip here")
    args = ap.parse_args()
    a = np.asarray(Image.open(args.src).convert("RGB"))
    h, w = a.shape[:2]
    if args.mark:
        mx, my = map(int, args.mark.split(","))
        box = (mx - 45, my - 45, mx + 45, my + 45)
    else:
        box = (int(w * 0.85), int(h * 0.78), w, h)
    mask = find_mark(a, box)
    healed = a
    if mask.any():
        healed, off, err = heal(a, mask)
        print(f"mark: {mask.sum()} px healed from offset {off} (ring err {err:.1f})")
    else:
        print("mark: none found")
    s = args.shift
    out = np.empty_like(healed)
    out[:, : w - s] = healed[:, s:]
    out[:, w - s:] = out[:, w - s - 1: w - 2 * s - 1: -1]  # mirror of the columns just left of the seam
    Image.fromarray(out).save(args.dst, quality=95)
    print(f"{args.dst}: shifted {s} px left ({s / w:.1%} of the width)")
    if args.preview:
        both = np.concatenate([a, out], 0)
        Image.fromarray(both).resize((w // 2, h)).save(args.preview)


if __name__ == "__main__":
    main()

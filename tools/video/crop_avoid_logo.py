#!/usr/bin/env python3
"""Crop a clip to a target aspect ratio with the LARGEST area that never touches a
corner watermark (the Gemini/Veo sparkle), so the logo is cut out instead of scaled.

The watermark is found by sampling frames and keeping pixels that are locally
brighter AND locally less saturated than their surroundings (the sparkle is a faint
white overlay). Those pixels are grouped into blobs, and only compact blobs inside the
chosen corner are kept, so a bright horizontal baseboard / wall edge is ignored.

Usage:
  python3 crop_avoid_logo.py IN.mp4 [-o OUT.mp4] [--ratio 16:9]
      [--corner br] [--margin 12] [--slack center] [--samples 8]
      [--logo X1,Y1,X2,Y2] [--crf 18] [--preset slow] [--no-audio] [--detect-only]

  --corner   which corner to look in: br (default) | bl | tr | tl | all
  --margin   safety gap in px between the crop and the logo box (default 12)
  --slack    where to put the free axis when the crop has room: center (default) | edge
  --headroom min px of wall above the head (default 24). A side crop slides down so the
             feet/chair keep their margin, and only stops to leave this much headroom.
             Fixes a low subject (e.g. seated) whose feet would otherwise touch the edge.
  --logo     skip detection and use this box (1-based pixels, x1,y1,x2,y2)
  --detect-only  print the detected logo box and the crop, then stop (no ffmpeg)

Prints the logo box, the chosen crop, and the % of the frame kept. Requires ffmpeg,
python3 with numpy + Pillow (use /usr/bin/python3 on macOS).
"""
import argparse, subprocess, sys
import numpy as np
from PIL import Image, ImageFilter
from collections import deque

GBLUR = 18          # background blur radius for the local-contrast test
HI_TH = 3.0         # min local brightness boost (grey levels)
LOSAT_TH = 5.0      # min local desaturation (grey levels)
SAT_MAX = 25.0      # ... or already this flat (the sparkle over a grey wall is not more grey)
LUM_MIN = 110.0     # ignore dark pixels, so the flat test can't pick up shadows


def probe(path):
    out = subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "v:0",
                                   "-show_entries", "stream=width,height", "-of", "csv=p=0", path]).decode()
    w, h = map(int, out.strip().split(",")[:2])
    dur = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries",
                                         "format=duration", "-of", "csv=p=0", path]).decode().strip())
    astreams = subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "a",
                                        "-show_entries", "stream=index", "-of", "csv=p=0", path]).decode().strip()
    return w, h, dur, bool(astreams)


def read_frame(path, t, w, h):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-ss", str(t), "-i", path, "-frames:v", "1",
                          "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True).stdout
    if len(raw) < w * h * 3:
        return None
    return np.frombuffer(raw, np.uint8)[:w * h * 3].reshape(h, w, 3).astype(np.float32)


def watermark_mask(a):
    lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
    sat = a.max(2) - a.min(2)
    lum8 = np.clip(lum, 0, 255).astype("uint8")
    sat8 = np.clip(sat, 0, 255).astype("uint8")
    bg = np.asarray(Image.fromarray(lum8).filter(ImageFilter.GaussianBlur(GBLUR)), np.float32)
    sbg = np.asarray(Image.fromarray(sat8).filter(ImageFilter.GaussianBlur(GBLUR)), np.float32)
    brighter = lum - bg > HI_TH
    # over warm wood the sparkle is greyer than its surroundings; over a grey wall it is
    # merely brighter (already flat) — accept either, and ignore dark pixels.
    flat_or_grey = (sbg - sat > LOSAT_TH) | (sat < SAT_MAX)
    return brighter & flat_or_grey & (lum > LUM_MIN)


def components(mask):
    h, w = mask.shape
    seen = np.zeros_like(mask, bool)
    blobs = []
    for sy, sx in np.argwhere(mask):
        if seen[sy, sx]:
            continue
        q = deque([(sy, sx)]); seen[sy, sx] = True
        minx = maxx = sx; miny = maxy = sy; area = 0
        while q:
            y, x = q.popleft(); area += 1
            minx = min(minx, x); maxx = max(maxx, x); miny = min(miny, y); maxy = max(maxy, y)
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                ny, nx = y + dy, x + dx
                if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                    seen[ny, nx] = True; q.append((ny, nx))
        blobs.append((area, minx, miny, maxx, maxy))
    return blobs


def remove_lines(mask, frac=0.5):
    """Drop rows/cols that are mostly lit across the region: those are baseboards or
    wall edges, not the compact sparkle. A sparkle crossing such a line is left as two
    compact halves, whose union box is still correct."""
    m = mask.copy()
    h, w = m.shape
    if w:
        m[m.sum(1) > frac * w, :] = False
    if h:
        m[:, m.sum(0) > frac * h] = False
    return m


def corner_region(w, h, corner):
    f = 0.32
    rx0, ry0, rx1, ry1 = 0, 0, w, h
    if corner in ("br", "tr"):
        rx0 = int(w * (1 - f))
    if corner in ("bl", "tl"):
        rx1 = int(w * f)
    if corner in ("br", "bl"):
        ry0 = int(h * (1 - f))
    if corner in ("tr", "tl"):
        ry1 = int(h * f)
    return rx0, ry0, rx1, ry1


def detect_logo(path, w, h, dur, corner, samples, tol=25, vote_frac=0.5):
    regions = [corner_region(w, h, c) for c in (("br", "bl", "tr", "tl") if corner == "all" else [corner])]
    per_frame = []
    for i in range(samples):
        t = dur * (i + 0.5) / samples
        a = read_frame(path, t, w, h)
        if a is None:
            continue
        mask = watermark_mask(a)
        boxes = []
        for rx0, ry0, rx1, ry1 in regions:
            rw = max(1, rx1 - rx0)
            sub = remove_lines(mask[ry0:ry1, rx0:rx1])
            for area, bx1, by1, bx2, by2 in components(sub):
                bw, bh = bx2 - bx1 + 1, by2 - by1 + 1
                if area < 60 or min(bw, bh) < 10:            # speckle
                    continue
                if bw > 0.5 * rw or bw > 6 * bh or bh > 6 * bw:   # a line, not a sparkle
                    continue
                boxes.append((bx1 + rx0, by1 + ry0, bx2 + rx0, by2 + ry0))
        per_frame.append(boxes)
    if not per_frame:
        return None
    need = 1 if len(per_frame) == 1 else max(2, int(round(vote_frac * len(per_frame))))
    keep = []                                                 # the watermark is in every frame; strays are not
    for boxes in per_frame:
        for b in boxes:
            cx, cy = (b[0] + b[2]) // 2, (b[1] + b[3]) // 2
            votes = sum(1 for other in per_frame
                        if any(abs((o[0] + o[2]) // 2 - cx) <= tol and abs((o[1] + o[3]) // 2 - cy) <= tol for o in other))
            if votes >= need:
                keep.append(b)
    if not keep:
        return None
    return (min(b[0] for b in keep), min(b[1] for b in keep), max(b[2] for b in keep), max(b[3] for b in keep))


def largest_crop(w, h, ratio, box, margin, slack):
    """Largest axis-aligned rect with the given ratio that does not overlap `box`
    (grown by `margin`). Returns (x, y, cw, ch, side)."""
    aw, ah = ratio
    ar = aw / ah
    x1, y1, x2, y2 = box
    x1, y1 = max(0, x1 - margin), max(0, y1 - margin)
    x2, y2 = min(w, x2 + margin), min(h, y2 + margin)
    def fit(limit_w, limit_h):                                    # largest ratio rect within a limit
        cw = min(limit_w, ar * limit_h)
        return cw, cw / ar
    cands = [
        ("left", fit(x1, h)),                                     # right edge <= box left
        ("right", fit(w - x2, h)),                                # left edge >= box right
        ("above", fit(w, y1)),                                    # bottom edge <= box top
        ("below", fit(w, h - y2)),                                # top edge >= box bottom
    ]
    side, (cw, ch) = max(cands, key=lambda c: c[1][0] * c[1][1])
    ch = int(ch) // 2 * 2                                         # even pixels, keep the ratio
    cw = int(round(ch * ar)) // 2 * 2
    if side == "left":
        x, y = 0, (0 if slack == "edge" else (h - ch) // 2)
    elif side == "right":
        x, y = w - cw, (0 if slack == "edge" else (h - ch) // 2)
    elif side == "above":
        x, y = 0, 0
    else:
        x, y = 0, h - ch
    return x, y, cw, ch, side


def subject_top(path, w, h, dur, x0, x1, samples):
    """Top row of the person, over the columns the crop keeps. The wall/floor are the
    row median, so a row that is not background somewhere is where the person starts
    (this catches hair, which a plain edge test does not). -1 if nothing is found."""
    tops = []
    for i in range(samples):
        t = dur * (i + 0.5) / samples
        a = read_frame(path, t, w, h)
        if a is None:
            continue
        lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
        sat = a.max(2) - a.min(2)
        sl, ss = lum[:, x0:x1], sat[:, x0:x1]
        if sl.shape[1] < 8:
            continue
        rowbg = np.median(sl, axis=1, keepdims=True)
        fg = (np.abs(sl - rowbg) > 30) | (ss > 55)
        rows = np.where(fg.mean(1) > 0.04)[0]
        if len(rows):
            tops.append(int(rows.min()))
    return int(np.median(tops)) if tops else -1


def overlaps(x, y, cw, ch, box, margin):
    x1, y1, x2, y2 = box
    x1, y1 = max(0, x1 - margin), max(0, y1 - margin)
    x2, y2 = min(1 << 30, x2 + margin), min(1 << 30, y2 + margin)
    return not (x + cw <= x1 or x >= x2 or y + ch <= y1 or y >= y2)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("-o", "--out")
    ap.add_argument("--ratio", default="16:9")
    ap.add_argument("--corner", default="br", choices=["br", "bl", "tr", "tl", "all"])
    ap.add_argument("--margin", type=int, default=12)
    ap.add_argument("--slack", default="center", choices=["center", "edge"])
    ap.add_argument("--headroom", type=int, default=24,
                    help="min px of wall kept above the head when a side crop can slide vertically")
    ap.add_argument("--samples", type=int, default=8)
    ap.add_argument("--logo", help="manual box X1,Y1,X2,Y2 (1-based, inclusive)")
    ap.add_argument("--crf", default="18")
    ap.add_argument("--preset", default="slow")
    ap.add_argument("--no-audio", action="store_true")
    ap.add_argument("--detect-only", action="store_true")
    a = ap.parse_args()

    rw, rh = map(int, a.ratio.split(":"))
    w, h, dur, has_audio = probe(a.input)
    print(f"input  {w}x{h}  {dur:.2f}s  audio={has_audio}  ratio={rw}:{rh}")

    if a.logo:
        box = tuple(int(v) - 1 for v in a.logo.split(","))
        print(f"logo   {box} (manual)")
    else:
        box = detect_logo(a.input, w, h, dur, a.corner, a.samples)
        if box is None:
            sys.exit("logo not found in corner '%s' — pass --logo X1,Y1,X2,Y2" % a.corner)
        print(f"logo   {box} (detected, corner={a.corner})")

    x, y, cw, ch, side = largest_crop(w, h, (rw, rh), box, a.margin, a.slack)
    if side in ("left", "right"):                 # slide vertically: keep the ground, never cut the head
        top = subject_top(a.input, w, h, dur, x, x + cw, min(a.samples, 8))
        if top >= 0:
            y = min(h - ch, max(0, top - a.headroom))
            print(f"head   top row {top}, vertical anchor -> y={y}")
    keep = 100.0 * cw * ch / (w * h)
    print(f"crop   {cw}x{ch} at ({x},{y})  side={side}  keeps {keep:.1f}% of the frame")
    if overlaps(x, y, cw, ch, box, 0):
        sys.exit("crop overlaps the logo — increase --margin")
    print(f"ffmpeg crop={cw}:{ch}:{x}:{y}")

    if a.detect_only:
        return
    out = a.out or (a.input.rsplit(".", 1)[0] + f"_{rw}x{rh}_nologo.mp4")
    cmd = ["ffmpeg", "-v", "error", "-y", "-i", a.input, "-vf", f"crop={cw}:{ch}:{x}:{y}",
           "-map", "0:v:0", "-map", "0:a?", "-c:v", "libx264", "-crf", a.crf, "-preset", a.preset,
           "-profile:v", "high", "-pix_fmt", "yuv420p", "-movflags", "+faststart"]
    cmd += ["-an"] if a.no_audio else ["-c:a", "copy"]
    cmd += [out]
    subprocess.run(cmd, check=True)
    print("wrote  " + out)


if __name__ == "__main__":
    main()

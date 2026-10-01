#!/usr/bin/env python3
"""Guard for crop_avoid_logo.py: FAIL if the crop box would cut into the coach.

Fixed formula (measured 30/09/2026 on 8/8 Omni 1.1 Flash clips, 1080p Upscaled): the
sparkle starts at x >= 1701, y >= 862, so the largest 16:9 crop that avoids it is
1688x950 at x=0, and crop_avoid_logo.py slides y (0..130) to keep the head with 24 px
headroom and the feet on the ground. Inverse rule for generation (CROP-SAFE, see
docs/scripts/P-production-prompts.md §1): the coach + chair must fit inside a
1688 x 950 window, i.e. right edge <= 1656 px (86% of width) and bbox height <= 890 px
(82% of height, 24 px headroom + 32 px foot margin). Head top 10-14% below the top edge
and feet 10-12% above the bottom edge always satisfy it.

Input is a clip (mp4) or a single frame image (png/jpg) — check the Nano Banana frame
BEFORE spending video credits. --crop is the line crop_avoid_logo.py prints
("crop WxH at (X,Y)" -> W,H,X,Y); without it the fixed window 1688,950,0,65 is used,
which is only a pre-check (the tool's y may differ). The coach's bounding box is measured:
  --plate EMPTY.png   diff against an empty-room plate of the same camera setup (exact)
  (no plate)          find the coach's column band by her sage top / charcoal leggings,
                      then compare each row of the band with the plain wall/floor right
                      next to it (catches hair, shoes, arms and the chair)

Usage:
  python3 crop_subject_check.py SRC.mp4 [--crop W,H,X,Y] [--plate EMPTY.png]
      [--margin-pct 3] [--samples 8] [--json]

Exit 0 = PASS (coach inside the crop with margin on every sampled frame),
exit 2 = FAIL (prints the offending side and by how many px), exit 1 = error.
The check never changes the crop: a FAIL means the frame image must be regenerated
with the coach inside the CROP-SAFE box (docs/scripts/P-production-prompts.md §1).
"""
import argparse, json, subprocess, sys
import numpy as np
from PIL import Image

DEFAULT_CROP = (1688, 950, 0, 65)   # fixed 30/09/2026: Omni sparkle starts at x>=1701, y>=862 on 1080p (8/8 clips); crop = logo_x1 - 12 - 1 wide, 16:9, vertically centered
SHOE_ALLOW_PCT = 0.0                 # row-background mask already includes the shoes


def probe(path):
    out = subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "v:0",
                                   "-show_entries", "stream=width,height", "-of", "csv=p=0", path]).decode()
    w, h = map(int, out.strip().split(",")[:2])
    dur = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                                         "-of", "csv=p=0", path]).decode().strip())
    return w, h, dur


def read_frame(path, t, w, h):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-ss", str(t), "-i", path, "-frames:v", "1",
                          "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True).stdout
    if len(raw) < w * h * 3:
        return None
    return np.frombuffer(raw, np.uint8)[:w * h * 3].reshape(h, w, 3).astype(np.float32)


def big_blobs(mask, scale=4, min_frac=0.003):
    """Keep every connected blob larger than min_frac of the frame (the coach, her chair,
    a detached sleeve or head); floor grain, baseboard and wall shading fall away.
    Works on a downscaled copy for speed."""
    small = mask[::scale, ::scale]
    h, w = small.shape
    seen = np.zeros_like(small, bool)
    out = np.zeros_like(small, bool)
    min_size = int(min_frac * h * w)
    for sy in range(h):
        for sx in range(w):
            if not small[sy, sx] or seen[sy, sx]:
                continue
            stack, comp = [(sy, sx)], []
            seen[sy, sx] = True
            while stack:
                y, x = stack.pop()
                comp.append((y, x))
                for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                    if 0 <= ny < h and 0 <= nx < w and small[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
            if len(comp) >= min_size:
                ys, xs = zip(*comp)
                out[list(ys), list(xs)] = True
    return out, scale


def subject_mask_plate(frame, plate):
    diff = np.abs(frame - plate).max(2)
    return big_blobs(diff > 28)


def subject_box_heuristic(frame, logo_x=1650):
    """Bounding box of the coach (and her chair) without a plate.
    1. Core band: columns holding the sage top or the charcoal leggings (unmistakable colours).
    2. Widen the band, then compare every row of it with the empty wall/floor of the SAME
       row just to the right of the band (the room is plain there by the framing rule).
       Rows/columns that differ enough are the coach, her hair, shoes, arms or the chair.
    Returns (x1, y1, x2, y2) in pixels, or None."""
    h, w, _ = frame.shape
    r, g, b = frame[..., 0], frame[..., 1], frame[..., 2]
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    sat = frame.max(2) - frame.min(2)
    core = ((g > r + 6) & (g > b + 10) & (sat > 18)) | ((lum < 100) & (sat < 25))   # sage top | charcoal leggings (not brown chair wood)
    cols = np.where(core.sum(0) > 0.04 * h)[0]
    if len(cols) == 0:
        return None
    cx1, cx2 = int(cols.min()), int(cols.max())
    pad = int(0.6 * (cx2 - cx1)) + 40
    bx1, bx2 = max(0, cx1 - pad), min(logo_x, cx2 + pad)
    # Background of each row = straight line between the plain strips left and right of the
    # band (the window light makes the wall and floor brighten across the frame).
    lx1, lx2 = max(0, bx1 - 260), max(8, bx1 - 20)
    rx1, rx2 = min(logo_x - 8, bx2 + 20), min(logo_x, bx2 + 260)
    if lx2 - lx1 < 8 and rx2 - rx1 < 8:
        return None
    if lx2 - lx1 < 8:
        lx1, lx2 = rx1, rx2
    if rx2 - rx1 < 8:
        rx1, rx2 = lx1, lx2
    left = np.median(frame[:, lx1:lx2, :], axis=1)                         # (h, 3)
    right = np.median(frame[:, rx1:rx2, :], axis=1)
    xl, xr = (lx1 + lx2) / 2.0, (rx1 + rx2) / 2.0
    t = ((np.arange(bx1, bx2) - xl) / max(1.0, xr - xl))[None, :, None]    # (1, band, 1)
    ref = left[:, None, :] * (1 - t) + right[:, None, :] * t
    d = np.abs(frame[:, bx1:bx2, :] - ref).max(2)
    soft = (d > 32).mean(1)            # catches grey hair on the wall
    # Below the body: a row belongs to her (legs, shoes, chair legs) if it holds an unbroken run of
    # >= 14 px that clearly differs from the floor; floor grain is scattered, never a solid run.
    hard = d > 45
    padded = np.pad(hard, ((0, 0), (1, 1)))
    edges = np.diff(padded.astype(np.int8), axis=1)
    run = np.zeros(h)
    for yy in range(h):
        st, en = np.where(edges[yy] == 1)[0], np.where(edges[yy] == -1)[0]
        if len(st):
            run[yy] = (en - st).max()
    firm = (run >= 14).astype(float)
    core_rows = np.where(core[:, cx1:cx2 + 1].mean(1) > 0.2)[0]
    if len(core_rows) == 0:
        return None
    mid = int(np.median(core_rows))
    # walk up from the body while rows stay foreground (gaps of a few rows allowed)
    def walk(start, step, frac, thr, gap=8):
        y, last, miss = start, start, 0
        while 0 <= y < h:
            if frac[y] > thr:
                last, miss = y, 0
            else:
                miss += 1
                if miss > gap:
                    break
            y += step
        return last
    y1 = walk(mid, -1, soft, 0.03)
    y2 = walk(mid, +1, firm, 0.5)
    # Feet check straight below the body (the strips can be spoiled by a chair beside her):
    # a row still belongs to her while, under her body columns, it holds a solid run of
    # shadowed leggings (darker than the oak floor) or of white shoe (colourless, unlike oak).
    fx1, fx2 = max(0, cx1 - 80), min(w, cx2 + 80)
    leg = (lum[:, fx1:fx2] < 140) | ((lum[:, fx1:fx2] > 150) & (sat[:, fx1:fx2] < 14))   # leggings | off-white shoes (oak floor is saturated)
    lp = np.pad(leg, ((0, 0), (1, 1))).astype(np.int8)
    le = np.diff(lp, axis=1)
    feet = np.zeros(h)
    for yy in range(h):
        st, en = np.where(le[yy] == 1)[0], np.where(le[yy] == -1)[0]
        if len(st):
            feet[yy] = (en - st).max()
    y2 = max(y2, walk(int(core_rows.max()), +1, (feet >= 10).astype(float), 0.5, gap=16))
    colmask = (d[y1:y2 + 1] > 32).mean(0) > 0.03
    xs = np.where(colmask)[0]
    if len(xs) == 0:
        return None
    x1, x2 = bx1 + int(xs.min()), bx1 + int(xs.max())
    return x1, y1, x2, y2


def bbox(mask_scale):
    mask, scale = mask_scale
    ys, xs = np.where(mask)
    if len(ys) == 0:
        return None
    return int(xs.min() * scale), int(ys.min() * scale), int((xs.max() + 1) * scale - 1), int((ys.max() + 1) * scale - 1)


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("--crop", help="W,H,X,Y as printed by crop_avoid_logo.py")
    ap.add_argument("--plate", help="empty-room frame (png/jpg) of the same camera setup")
    ap.add_argument("--margin-px", type=int, default=24, help="required gap on a CUT edge, px (tool headroom is 24)")
    ap.add_argument("--samples", type=int, default=8)
    ap.add_argument("--tool-headroom", type=int, help="the --headroom the crop tool ran with; on a FAIL the guard "
                    "then suggests the --headroom that centres the coach in the window")
    ap.add_argument("--center", default="28,48",
                    help="allowed range of the coach's horizontal centre inside the crop, %% of crop width "
                         "(framing rule: ~38%%, the right third stays empty); 'off' to skip")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args(argv)

    is_image = a.src.lower().endswith((".png", ".jpg", ".jpeg"))
    if is_image:
        im = Image.open(a.src).convert("RGB")
        w, h, dur = im.size[0], im.size[1], 0.0
        frames = [np.asarray(im, np.float32)]
    else:
        w, h, dur = probe(a.src)
        frames = None
    cw, ch, cx, cy = map(int, a.crop.split(",")) if a.crop else DEFAULT_CROP
    auto_y = not a.crop                     # emulate crop_avoid_logo.py: y = head top - 24, clamped
    if not a.crop and (w, h) != (1920, 1080):
        print("no --crop given and source is not 1920x1080: pass the crop from crop_avoid_logo.py", file=sys.stderr)
        return 1
    plate = None
    if a.plate:
        plate = np.asarray(Image.open(a.plate).convert("RGB").resize((w, h)), np.float32)
    margin = a.margin_px

    boxes = []
    for i in range(1 if is_image else a.samples):
        t = 0.0 if is_image else dur * (i + 0.5) / a.samples
        fr = frames[0] if is_image else read_frame(a.src, t, w, h)
        if fr is None:
            continue
        b = bbox(subject_mask_plate(fr, plate)) if plate is not None else subject_box_heuristic(fr)
        if b is None:
            continue
        x1, y1, x2, y2 = b
        if plate is None:
            y2 = min(h - 1, int(y2 + SHOE_ALLOW_PCT / 100.0 * h))
        boxes.append((round(t, 2), x1, y1, x2, y2))

    if not boxes:
        print("could not find the coach in any frame", file=sys.stderr)
        return 1
    if auto_y:
        tops = sorted(b[2] for b in boxes)
        cy = min(h - ch, max(0, tops[len(tops) // 2] - 24))   # the tool uses the median head top
    left, top, right, bottom = cx, cy, cx + cw - 1, cy + ch - 1
    worst = {"left": 1e9, "top": 1e9, "right": 1e9, "bottom": 1e9}
    for _, x1, y1, x2, y2 in boxes:
        worst["left"] = min(worst["left"], x1 - left)
        worst["top"] = min(worst["top"], y1 - top)
        worst["right"] = min(worst["right"], right - x2)
        worst["bottom"] = min(worst["bottom"], bottom - y2)
    # An edge of the crop that lies on the frame edge cuts nothing: no gap needed there.
    on_frame_edge = {"left": left == 0, "top": top == 0, "right": right == w - 1, "bottom": bottom == h - 1}
    fails = {k: v for k, v in worst.items() if v < margin and not (on_frame_edge[k] and v >= 0)}
    # Horizontal placement: mean centre of the coach box, as % of the crop width.
    centre_pct = 100.0 * (np.mean([(b[1] + b[3]) / 2 for b in boxes]) - left) / cw
    centre_fail = None
    if a.center != "off":
        lo_c, hi_c = map(float, a.center.split(","))
        if not lo_c <= centre_pct <= hi_c:
            centre_fail = f"coach centre at {centre_pct:.0f}% of the crop width (allowed {lo_c:.0f}-{hi_c:.0f}%)"
    # Where could the window sit so that every sampled box keeps the gap? (vertical only;
    # x is fixed at 0 by the logo formula)
    ys1, ys2 = min(b[2] for b in boxes), max(b[4] for b in boxes)
    lo, hi = max(0, ys2 + margin - (ch - 1)), min(h - ch, ys1 - margin)
    fit = None
    if lo <= hi:
        best = (lo + hi) // 2
        fit = {"y_range": [lo, hi], "best_y": best}
        if a.tool_headroom is not None and a.crop:
            fit["suggest_headroom"] = cy + a.tool_headroom - best     # tool: y = detected_top - headroom
    result = {"src": a.src, "crop": [cw, ch, cx, cy], "auto_y": auto_y, "mode": "plate" if plate is not None else "heuristic",
              "margin_px": margin, "gap_px": {k: int(v) for k, v in worst.items()},
              "boxes": boxes, "fit": fit, "centre_pct": round(centre_pct, 1),
              "pass": not fails and not centre_fail}
    if a.json:
        print(json.dumps(result, indent=1))
    else:
        print(f"crop {cw}x{ch} at ({cx},{cy}){' (y as the tool would pick)' if auto_y else ''}  mode={result['mode']}  required gap {margin} px")
        xs1, ys1 = min(b[1] for b in boxes), min(b[2] for b in boxes)
        xs2, ys2 = max(b[3] for b in boxes), max(b[4] for b in boxes)
        print(f"coach box x {xs1}-{xs2}  y {ys1}-{ys2}  (height {100 * (ys2 - ys1) / h:.0f}% of frame)")
        print("gap to crop edge (px): " + "  ".join(f"{k}={int(v)}" for k, v in worst.items())
              + f"  |  coach centre {centre_pct:.0f}% of crop width")
        msgs = []
        if fails:
            msgs.append("crop cuts into the coach on " + ", ".join(f"{k} (gap {int(v)} px)" for k, v in fails.items())
                        + (f" -> the coach fits at y {fit['y_range'][0]}-{fit['y_range'][1]}"
                           + (f": re-run crop_avoid_logo.py with --headroom {fit['suggest_headroom']}" if "suggest_headroom" in fit else "")
                           if fit else " -> the coach is taller than the window: regenerate the frame image inside the CROP-SAFE box"))
        if centre_fail:
            msgs.append(centre_fail + " -> regenerate the frame image with her further left/right")
        print("PASS: coach inside the crop, centred as the framing rule asks" if not msgs else "FAIL: " + "; ".join(msgs))
    return 0 if not fails and not centre_fail else 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

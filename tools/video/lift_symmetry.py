#!/usr/bin/env python3
"""Symmetry check for alternating-leg moves (seated knee lift, heel raise...).

Tracks the two white sneakers (brightest pixels) in a crop around the feet, splits them by x,
and reports each lift: start, end, duration (foot-off to foot-down) and peak height in pixels,
plus the rest gaps between lifts (including the loop seam).
Usage: python3 lift_symmetry.py clip.mp4 --crop 560:380:320:340 [--split 98] [--thresh 2.5]
Pass (V2-1): lifts alternate R/L; durations within ~10%; heights within ~25%; gaps similar.
Note: in a 3/4 view the far leg looks smaller, so compare heights per side, not across sides blindly.
"""
import argparse, subprocess
import numpy as np
ap = argparse.ArgumentParser(); ap.add_argument("clip"); ap.add_argument("--crop", default="560:380:320:340")
ap.add_argument("--split", type=int, default=None); ap.add_argument("--thresh", type=float, default=2.5)
ap.add_argument("--white", type=int, default=234); a = ap.parse_args()
W, H = 280, 190
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", a.clip, "-vf", f"crop={a.crop},scale={W}:{H}", "-f", "rawvideo",
                      "-pix_fmt", "rgb24", "-"], capture_output=True, check=True).stdout
d = np.frombuffer(raw, dtype=np.uint8).reshape(-1, H, W, 3).astype(int); n = len(d)
w = d.min(axis=3) > a.white
if a.split is None:
    _, xs = np.where(w[0]); a.split = int((xs.min() + xs.max()) / 2)
def sole(m):
    ys, _ = np.where(m); return np.percentile(ys, 90) if len(ys) > 15 else np.nan
events = []
for side, sl in (("near", slice(0, a.split)), ("far", slice(a.split, None))):
    y = np.array([sole(w[i][:, sl]) for i in range(n)]); lift = np.nanmedian(y) - y; up = lift > a.thresh
    s = None
    for i, u in enumerate(list(up) + [False]):
        if u and s is None: s = i
        if (not u) and s is not None:
            if i - s >= 6: events.append((s, i, side, float(np.nanmax(lift[s:i]))))
            s = None
events.sort()
for s, e, side, h in events: print(f"{side:4s} {s/24:5.2f}-{e/24:5.2f}s dur={(e-s)/24:.2f}s height={h:.0f}px")
gaps = [(events[i + 1][0] - events[i][1]) / 24 for i in range(len(events) - 1)]
if events: gaps.append((events[0][0] + n - events[-1][1]) / 24)
print("order:", " ".join(e[2] for e in events), "| rest gaps (last = across loop seam):", [round(g, 2) for g in gaps])
for side in ("near", "far"):
    ds = [(e - s) / 24 for s, e, sd, _ in events if sd == side]
    if ds: print(f"{side}: mean dur {np.mean(ds):.2f}s")

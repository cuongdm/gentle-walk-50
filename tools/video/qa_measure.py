#!/usr/bin/env python3
"""QA for an AI exercise clip: head-top margin per step, camera drift, loop seam.

Usage: python3 qa_measure.py clip.mp4 [--step 0.25] [--band 0.40-0.60] [--wall 0.69-0.97x0.05-0.39]
- band: horizontal slice (fraction of width) where the person stands, used to find the head top.
- wall: region of static background (x-range x y-range, fractions) used to measure camera drift.
Pass criteria (V1-1): head-top row >= 5% of height in every frame, wall drift < 2, first-vs-last < 1.5.
"""
import subprocess, sys, argparse
import numpy as np

def frames(path, w=160, h=90):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-vf", f"scale={w}:{h},format=gray",
                          "-f", "rawvideo", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.uint8).reshape(-1, h, w).astype(float)

def rng(s):
    a, b = s.split("-"); return float(a), float(b)

ap = argparse.ArgumentParser()
ap.add_argument("clip"); ap.add_argument("--step", type=float, default=0.25)
ap.add_argument("--fps", type=float, default=24); ap.add_argument("--band", default="0.40-0.60")
ap.add_argument("--wall", default="0.69-0.97x0.05-0.39"); ap.add_argument("--dark", type=int, default=110)
a = ap.parse_args()
d = frames(a.clip); n, H, W = d.shape
bx = [int(v * W) for v in rng(a.band)]
wx, wy = a.wall.split("x"); wx = [int(v * W) for v in rng(wx)]; wy = [int(v * H) for v in rng(wy)]
wall = d[:, wy[0]:wy[1], wx[0]:wx[1]]
motion = np.abs(np.diff(d, axis=0)).mean(axis=(1, 2))
print(f"frames={n} duration={n / a.fps:.2f}s")
print(f"camera drift (wall, max mean-abs vs frame0) = {np.abs(wall - wall[0]).mean(axis=(1, 2)).max():.2f}")
print(f"loop seam (first vs last) = {np.abs(d[0] - d[-1]).mean():.2f} | median frame-to-frame = {np.median(motion):.2f} | max = {motion.max():.2f} at frame {int(motion.argmax())}")
worst = H
for i in range(0, n, max(1, int(a.step * a.fps))):
    band = d[i, :, bx[0]:bx[1]]
    rows = np.where((band < a.dark).sum(axis=1) > 2)[0]
    top = int(rows.min()) if len(rows) else None
    worst = min(worst, top if top is not None else H)
    print(f"t={i / a.fps:5.2f}s head_top={top} ({(top or 0) / H:.0%}) motion={motion[min(i, n - 2)]:.2f}")
print("HEAD CUT RISK" if worst < 0.05 * H else f"head OK (min top {worst / H:.0%})")

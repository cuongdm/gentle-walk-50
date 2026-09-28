#!/usr/bin/env python3
"""Per-side leg displacement vs the rest frame (frame 0) — robust alternative to lift_symmetry.py
when shoes are small or sit near a white baseboard.
Usage: python3 leg_displacement.py clip.mp4 --crop W:H:X:Y [--split X_in_crop] [--thresh 6]
Prints each movement burst per side (image-left / image-right): start-end, duration, peak displacement,
then the order, gaps and mean duration/peak per side. Signal = mean |frame - frame0| in each half."""
import argparse, subprocess, numpy as np
ap = argparse.ArgumentParser(); ap.add_argument("clip"); ap.add_argument("--crop", required=True)
ap.add_argument("--split", type=int, default=None); ap.add_argument("--thresh", type=float, default=3.0)
ap.add_argument("--ref", type=float, default=0.0, help="time (s) of the rest frame")
a = ap.parse_args(); W, H, X, Y = map(int, a.crop.split(":"))
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", a.clip, "-vf", f"crop={W}:{H}:{X}:{Y},format=gray",
                      "-f", "rawvideo", "-"], capture_output=True).stdout
f = np.frombuffer(raw, np.uint8).reshape(-1, H, W).astype(np.float32); n = len(f); fps = 24.0
ref = f[int(a.ref * fps)]; sp = a.split or W // 2
sig = {"img-left": np.abs(f[:, :, :sp] - ref[:, :sp]).mean((1, 2)), "img-right": np.abs(f[:, :, sp:] - ref[:, sp:]).mean((1, 2))}
# remove slow drift (body sway, AI re-rendering): subtract a rolling low percentile over ~3 s
win = int(3 * fps)
for k, s in sig.items():
    base = np.array([np.percentile(s[max(0, i - win // 2):i + win // 2 + 1], 20) for i in range(n)])
    sig[k] = s - base
ev = []
for side, s in sig.items():
    up = s > a.thresh; i = 0
    while i < n:
        if up[i]:
            j = i
            while j < n and up[j]: j += 1
            if j - i >= 3: ev.append((i / fps, j / fps, side, float(s[i:j].max())))
            i = j
        else: i += 1
ev.sort()
for t0, t1, side, pk in ev: print(f"{side:9s} {t0:5.2f}-{t1:5.2f}s dur={t1-t0:.2f}s peak={pk:.1f}")
print("order:", " ".join(e[2] for e in ev))
print("gaps:", [round(ev[k+1][0] - ev[k][1], 2) for k in range(len(ev) - 1)])
for side in sig:
    d = [e[1] - e[0] for e in ev if e[2] == side]; p = [e[3] for e in ev if e[2] == side]
    if d: print(f"{side}: n={len(d)} mean dur {np.mean(d):.2f}s mean peak {np.mean(p):.1f}")

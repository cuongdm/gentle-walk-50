#!/usr/bin/env python3
"""Toe-tap loop from two 'rest -> tap' clips: near out, near back (reversed), far out, far back.
Usage: rev_loop.py NEAR.mp4 SPEC FAR.mp4 SPEC OUT.mp4 [speed]
SPEC: frame ranges, e.g. "26-58,60-84:2" (every 2nd frame of the slow settle into the tap)."""
import os, subprocess, sys, tempfile, glob
near, nr, far, fr, out = sys.argv[1:6]; speed = float(sys.argv[6]) if len(sys.argv) > 6 else 1.0
tmp = tempfile.mkdtemp()
def frames(src, tag):
    d = os.path.join(tmp, tag); os.makedirs(d)
    subprocess.run(["ffmpeg", "-v", "error", "-i", src, os.path.join(d, "%04d.png")], check=True)
    return sorted(glob.glob(os.path.join(d, "*.png")))
N, F = frames(near, "n"), frames(far, "f")
def pick(fr, spec):
    out = []
    for part in spec.split(","):
        rng, _, step = part.partition(":")
        a, b = map(int, rng.split("-")); out += fr[a:b + 1:int(step or 1)]
    return out
n, f = pick(N, nr), pick(F, fr)
seq = n + n[1:-1][::-1] + f + f[1:-1][::-1]
lst = os.path.join(tmp, "list.txt")
with open(lst, "w") as fh:
    for p in seq: fh.write(f"file '{p}'\nduration {1 / 24 / speed:.6f}\n")
subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-vf", "fps=24,format=yuv420p",
                "-c:v", "libx264", "-crf", "14", "-metadata", "comment=gw-loop:hardcut", out], check=True)
print(out, len(seq), "frames in,", f"{len(seq) / 24 / speed:.2f}s")

#!/usr/bin/env python3
"""Heel-to-toe check (usage: tandem_gap.py CLIP.mp4 ..., needs CLIP.mp4.pose.npz): gap between the feet in frames where BOTH feet are planted (ankles still).
A true tandem walk keeps that gap about one foot length (~0.3 leg); a normal stride is ~0.5-0.7."""
import sys, numpy as np
for f in sys.argv[1:]:
    d = np.load(f + ".pose.npz"); xy = d["xy"]
    leg = np.nanmedian(np.linalg.norm(xy[:, 27] - xy[:, 23], axis=1))
    v = lambda a: np.r_[0, np.linalg.norm(np.diff(xy[:, a], axis=0), axis=1)] / leg
    still = (v(27) < 0.01) & (v(28) < 0.01)
    g = np.abs(xy[:, 27, 0] - xy[:, 28, 0]) / leg
    gs = g[still]
    print(f"{f:28s} planted frames {still.sum():3d}  gap median {np.median(gs):.2f}  p90 {np.percentile(gs, 90):.2f}  "
          f"side-by-side {np.mean(gs < 0.12) * 100:.0f}%  wide(>0.45) {np.mean(gs > 0.45) * 100:.0f}%")

"""SUPERSEDED by V4-3c_smooth.py (eased tempo + seam). V4-3 from ONE Gemini take (V4-3c, 06/10/2026): rest -> heel raise -> rest -> toe raise.

Source: V4-3c_360p_try1.mp4 (Gemini Omni 1.1, start = V4-alt rest frame, end = toes-up pose image),
upscaled to 1080p (V4-3c_360p_try1_up1080.mp4), heels pinned in the toe raise with
`V4-3_feet_pin.py <up1080> <frames> 124 110:122` (the model slid the shoes ~18 px forward there).
Loop = frames A..143 (rest, heel raise 2, rest, toes up), then 142..B reversed (toes back down to rest),
hard cut back to A. A and B are the pair of flat-foot rest frames that look most alike.

Usage: python V4-3c_build.py pinned_frames_dir out.mp4
"""
import glob, os, subprocess, sys, tempfile
import cv2, numpy as np

src, out = sys.argv[1:3]
paths = sorted(glob.glob(f"{src}/*.png"))
small = [cv2.resize(cv2.imread(p), (480, 270)).astype(np.float32) for p in paths]
last = len(paths) - 1
A_RANGE = range(34, 54)        # flat feet after heel raise 1, at least 0.25 s before heel raise 2 starts (~f60)
B_RANGE = range(98, 116)       # flat feet after heel raise 2, before the toes lift (~f126)
best = min(((np.abs(small[a] - small[b]).mean(), a, b) for a in A_RANGE for b in B_RANGE))
diff, A, B = best
seq = list(range(A, last + 1)) + list(range(last - 1, B - 1, -1))
print(f"A={A} B={B} cut diff {diff:.2f}/255; {len(seq)} frames = {len(seq) / 24:.2f} s")
with tempfile.TemporaryDirectory() as tmp:
    for k, i in enumerate(seq):
        os.symlink(os.path.abspath(paths[i]), f"{tmp}/{k:04d}.png")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", "24", "-i", f"{tmp}/%04d.png",
                    "-c:v", "libx265", "-crf", "24", "-preset", "medium", "-tag:v", "hvc1", "-pix_fmt", "yuv420p",
                    "-x265-params", "log-level=error", "-movflags", "+faststart", out], check=True)

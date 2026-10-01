#!/usr/bin/env python3
"""Clip health for AI exercise clips: sharpness, blur dips, frozen frames, jumps, rhythm, camera drift.

Usage: python3 clip_health.py CLIP.mp4 [...] [--json]
Import: from clip_health import measure  -> dict per clip.

Metrics (coach band = 12-72% of width, where every coach stands):
- sharp    median Laplacian variance of the coach band (compare clips of the same scene only;
           plain wall scenes read low without being blurry)
- dip      lowest 3-frame sharpness / median; < 0.70 = ghosting at a crossfade join or motion blur
- blur_pct share of frames under 70% of the median sharpness
- stutter  near-duplicate frames between moving neighbours (a ping-pong hold turn gives 1)
- jump     largest frame-to-frame change / median change
- rhythm   CV of intervals between movement bursts; > 0.65 = uneven speed (noisy on holds)
- drift    largest shift of the coach-free floor corner vs the first frame, in px
"""
import json, subprocess, sys
import numpy as np
from scipy.signal import find_peaks


def probe(path):
    s = json.loads(subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=width,height,r_frame_rate", "-of", "json", path]))["streams"][0]
    a, b = s["r_frame_rate"].split("/")
    return s["width"], s["height"], float(a) / float(b)


def gray_frames(path, w, h):
    proc = subprocess.Popen(["ffmpeg", "-v", "error", "-i", path, "-f", "rawvideo", "-pix_fmt", "gray", "-"],
                            stdout=subprocess.PIPE)
    size = w * h
    while True:
        buf = proc.stdout.read(size)
        if len(buf) < size:
            break
        yield np.frombuffer(buf, np.uint8).reshape(h, w).astype(np.float32)


def laplacian_var(a):
    return float((4 * a[1:-1, 1:-1] - a[:-2, 1:-1] - a[2:, 1:-1] - a[1:-1, :-2] - a[1:-1, 2:]).var())


def phase_shift(ref, cur):
    f = np.fft.fft2(ref - ref.mean()) * np.conj(np.fft.fft2(cur - cur.mean()))
    r = np.abs(np.fft.ifft2(f / (np.abs(f) + 1e-6)))
    y, x = np.unravel_index(r.argmax(), r.shape)
    y -= r.shape[0] if y > r.shape[0] // 2 else 0
    x -= r.shape[1] if x > r.shape[1] // 2 else 0
    return float(np.hypot(x, y))


def measure(path):
    w, h, fps = probe(path)
    x0, x1 = int(.12 * w), int(.72 * w)
    fx0, fy0 = int(.78 * w), int(.84 * h)
    sharp, motion, drift = [], [], [0.0]
    prev = ref = None
    for f in gray_frames(path, w, h):
        band = f[:, x0:x1]
        sharp.append(laplacian_var(band))
        small = band[::4, ::4]
        if prev is not None:
            motion.append(float(np.abs(small - prev).mean()))
        prev = small
        floor = f[fy0:, fx0:]
        if ref is None:
            ref = floor
        else:
            drift.append(phase_shift(ref, floor))
    sharp, motion = np.array(sharp), np.array(motion)
    med = float(np.median(sharp))
    rolled = np.convolve(sharp, np.ones(3) / 3, "valid")
    mm = float(np.median(motion)) + 1e-6
    stutter = sum(1 for i in range(1, len(motion) - 1)
                  if motion[i] < .2 * mm and motion[i - 1] > mm and motion[i + 1] > mm)
    smooth = np.convolve(motion, np.ones(5) / 5, "same")
    peaks, _ = find_peaks(smooth, distance=max(3, int(.25 * fps)), prominence=.25 * smooth.std() + 1e-6)
    iv = np.diff(peaks) / fps
    return {
        "width": w, "height": h, "fps": round(fps, 2), "duration": round(len(sharp) / fps, 2),
        "sharp": round(med, 1), "dip": round(float(rolled.min()) / med, 2),
        "blur_pct": round(100 * float((sharp < .7 * med).mean()), 1),
        "stutter": int(stutter), "jump": round(float(motion.max()) / mm, 1),
        "rhythm": round(float(iv.std() / iv.mean()), 2) if len(iv) >= 3 else None,
        "drift": round(max(drift), 1),
    }


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--json"]
    out = {p: measure(p) for p in args}
    if "--json" in sys.argv:
        print(json.dumps(out, indent=1))
    else:
        for p, m in out.items():
            print(p.split("/")[-1], m)

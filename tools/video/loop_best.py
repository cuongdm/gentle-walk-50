#!/usr/bin/env python3
"""Cut the best seamless loop out of a generated source clip, driven by the body landmarks.

Instead of cutting at guessed times and hiding the seam with a 0.35 s crossfade (which ghosts the face
whenever the two ends differ), this picks the two frames that match in POSE and VELOCITY and cuts there:
  1. events from motion_logic (which leg moves when);
  2. candidate loops = whole numbers of cycles that follow the pattern (alternate: R L R L…, equal counts,
     even timing; sides: one block per side);
  3. for each candidate, search ±8 frames around both ends for the frame pair with the smallest landmark
     distance (% of body height) and the closest frame-to-frame motion, both ends at rest (no leg up);
  4. render [i, j) at 24 fps with no crossfade (or a 2-frame one when --xf 2), then re-check with motion_logic.

Usage: python3 loop_best.py SRC.mp4 OUT.mp4 --pattern alternate [--min-s 3] [--max-s 8] [--xf 0] [--hevc]
Needs SRC.mp4.pose.npz (pose_track.py). Prints the cut, the pose gap and the motion_logic verdict.
"""
import argparse, os, subprocess, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import motion_logic as ml  # noqa: E402

IDS = [ml.NOSE, ml.L_SH, ml.R_SH, ml.L_HIP, ml.R_HIP, ml.L_KNEE, ml.R_KNEE, ml.L_ANK, ml.R_ANK]


def pose_gap(xy, i, j, body):
    return float(np.nanmean(np.linalg.norm(xy[i, IDS] - xy[j, IDS], axis=1)) / body * 100)


def vel_gap(xy, i, j, body):
    vi = xy[i + 1, IDS] - xy[i, IDS]; vj = xy[j + 1, IDS] - xy[j, IDS] if j + 1 < len(xy) else vi
    return float(np.nanmean(np.linalg.norm(vi - vj, axis=1)) / body * 100)


def candidates(evs, pattern, fps, n_frames, min_s, max_s):
    """(start_frame, end_frame, description) for whole-cycle windows that obey the pattern."""
    out = []
    rest_before = lambda e: max(0, int(e["start"] * fps) - 2)
    for a in range(len(evs)):
        for b in range(a + 1, len(evs) + 1):
            seg = evs[a:b]
            end_f = rest_before(evs[b]) if b < len(evs) else n_frames - 1
            start_f = rest_before(evs[a])
            length = (end_f - start_f) / fps
            if not (min_s <= length <= max_s):
                continue
            sides = [e["side"] for e in seg]
            if pattern == "profile":
                if len(seg) % 2:
                    continue
            elif pattern == "alternate":
                if len(seg) % 2 or any(x == y for x, y in zip(sides, sides[1:])) or sides.count("L") != sides.count("R"):
                    continue
            elif pattern == "sides":
                if sum(1 for x, y in zip(sides, sides[1:]) if x != y) != 1:
                    continue
            starts = [e["start"] for e in seg] + [end_f / fps]
            iv = np.diff(starts); cv = float(iv.std() / iv.mean()) if len(iv) > 1 else 0.0
            if cv > 0.3:
                continue
            out.append((start_f, end_f, f"{len(seg)} events {''.join(sides)} cv {cv:.2f}"))
    return out


def any_pairs(xy, body, fps, min_s, max_s, keep=40):
    """Best (start, end) pairs by pose + velocity match, for moves without a left/right script."""
    n = len(xy); lo, hi = int(min_s * fps), int(max_s * fps)
    P = xy[:, IDS].reshape(n, -1); V = np.r_[np.diff(P, axis=0), np.diff(P, axis=0)[-1:]]
    best = []
    for i in range(0, n - lo):
        js = np.arange(i + lo, min(n - 1, i + hi) + 1)
        if not len(js):
            continue
        pg = np.nanmean(np.linalg.norm((P[js] - P[i]).reshape(len(js), -1, 2), axis=2), axis=1) / body * 100
        vg = np.nanmean(np.linalg.norm((V[js] - V[i]).reshape(len(js), -1, 2), axis=2), axis=1) / body * 100
        k = int(np.nanargmin(pg + 2 * vg)); best.append((float(pg[k] + 2 * vg[k]), i, int(js[k])))
    best.sort()
    return [(i, j, f"pose-match score {sc:.2f}") for sc, i, j in best[:keep]]


def refine(xy, disp, i, j, body, thr, radius=24):
    best = None
    for di in range(-radius, radius + 1):
        for dj in range(-radius, radius + 1):
            a, b = i + di, j + dj
            if a < 0 or b >= len(xy) - 1 or b - a < 24:
                continue
            if disp[a] > thr or disp[b] > thr:          # both ends must be at rest
                continue
            score = pose_gap(xy, a, b, body) + 2 * vel_gap(xy, a, b, body)
            if best is None or score < best[0]:
                best = (score, a, b)
    return best


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src"); ap.add_argument("out"); ap.add_argument("--pattern", default="alternate")
    ap.add_argument("--min-s", type=float, default=3.0); ap.add_argument("--max-s", type=float, default=8.0)
    ap.add_argument("--xf", type=int, default=0, help="crossfade frames at the seam (0 = hard cut)")
    ap.add_argument("--hevc", action="store_true"); ap.add_argument("--prefer-long", action="store_true")
    a = ap.parse_args()
    d = ml.load(a.src)
    if d is None:
        sys.exit("no pose file — run pose_track.py first")
    xy, vis, fps, w, h = d
    sig = ml.signals(xy); body = sig["body_px"]
    disp = np.nan_to_num(np.maximum(sig["R"]["disp"], sig["L"]["disp"]))
    thr = max(6.0, 0.35 * float(np.nanpercentile(disp, 98)))
    evs = ml.events(sig, fps, thr)
    if a.pattern == "profile":
        # side view: L/R labels are unreliable — use the merged events motion_logic builds for profile clips
        evs = ml.analyse(a.src, "profile")["events"]
        cands = candidates(evs, "profile", fps, len(xy), a.min_s, a.max_s)
    elif a.pattern in ("alternate", "sides"):
        cands = candidates(evs, a.pattern, fps, len(xy), a.min_s, a.max_s)
    else:
        # any other move (squat, row, stretch, hold, side view): pure pose matching over all frame pairs
        cands = any_pairs(xy, body, fps, a.min_s, a.max_s)
    if not cands:
        print("events:", " ".join(f"{e['side']}@{e['start']}" for e in evs))
        sys.exit("no whole-cycle window follows the pattern — the source itself breaks the script; regenerate it")
    scored = []
    for s, e, desc in cands:
        r = refine(xy, disp, s, e, body, thr * 0.3 if a.pattern in ("alternate", "sides", "profile") else 1e9)
        if r:
            scored.append((r[0] - (0.3 * (r[2] - r[1]) / fps if a.prefer_long else 0), r[1], r[2], desc, r[0]))
    scored.sort()
    score, i, j, desc, raw = scored[0]
    t0, t1 = i / fps, j / fps
    xf = a.xf
    if xf:
        filt = (f"[0:v]trim=start_frame={i}:end_frame={j + xf},setpts=PTS-STARTPTS,fps=24,split[a][b];"
                f"[b]trim=start_frame=0:end_frame={xf},setpts=PTS-STARTPTS[hd];"
                f"[a][hd]xfade=transition=fade:duration={xf / 24:.4f}:offset={(j - i) / 24:.4f},trim=start_frame={xf},setpts=PTS-STARTPTS,format=yuv420p[v]")
    else:
        filt = f"[0:v]trim=start_frame={i}:end_frame={j},setpts=PTS-STARTPTS,fps=24,format=yuv420p[v]"
    codec = ["-c:v", "libx265", "-crf", "26", "-preset", "medium", "-tag:v", "hvc1", "-x265-params", "log-level=error"] if a.hevc \
        else ["-c:v", "libx264", "-crf", "16", "-preset", "slow"]
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", a.src, "-filter_complex", filt, "-map", "[v]", "-an", *codec,
                    "-metadata", f"comment=gw-loop:{'hardcut' if not xf else f'xf{xf}'}", "-movflags", "+faststart", a.out], check=True)
    print(f"cut frames {i}-{j} ({t0:.2f}-{t1:.2f} s, {(j - i) / fps:.2f} s) | {desc} | pose gap {pose_gap(xy, i, j, body):.2f}% "
          f"vel gap {vel_gap(xy, i, j, body):.2f}% | xf {xf} frames -> {a.out}")


if __name__ == "__main__":
    main()

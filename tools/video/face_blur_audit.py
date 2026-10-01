#!/usr/bin/env python3
"""Face/head ghost audit: catches the double-image a loop or join crossfade leaves on the face,
which whole-body sharpness (clip_health.py) averages away.

For each clip: find the coach's head box (crop_subject_check.py, median of sampled boxes, top 17% of the
body box), measure Laplacian sharpness of that box on every frame, and report the worst 3-frame run vs the
clip's median, where it happens, and whether it sits in the loop seam (last 0.5 s / first 0.2 s).
Saves a strip of the worst head frame next to a sharp one for eyeballing (--sheet DIR).

Usage: python3 face_blur_audit.py CLIP.mp4 [...] [--sheet DIR] [--json]
Verdict: dip < 0.70 = GHOST (redo the seam/join), 0.70-0.80 = check by eye, >= 0.80 = clean.
"""
import json, os, subprocess, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from clip_health import probe, gray_frames, laplacian_var  # noqa: E402


def head_box(path, w, h):
    out = subprocess.run([sys.executable, os.path.join(HERE, "crop_subject_check.py"), path,
                          "--crop", f"{w},{h},0,0", "--samples", "8", "--json"], capture_output=True, text=True).stdout
    try:
        boxes = json.loads(out)["boxes"]
    except Exception:
        return None
    x0 = int(np.median([b[1] for b in boxes])); y0 = int(np.min([b[2] for b in boxes]))
    x1 = int(np.median([b[3] for b in boxes])); y1 = int(np.median([b[4] for b in boxes]))
    hb = max(40, int((y1 - y0) * 0.17))
    cx = (x0 + x1) // 2; half = max(hb, (x1 - x0) // 3)
    return max(0, cx - half), max(0, y0 - 8), min(w, cx + half), min(h, y0 + hb + 8)


def audit(path, sheet=None):
    w, h, fps = probe(path)
    box = head_box(path, w, h)
    if not box:
        return {"clip": path, "error": "no coach box"}
    x0, y0, x1, y1 = box
    s = np.array([laplacian_var(f[y0:y1, x0:x1]) for f in gray_frames(path, w, h)])
    med = float(np.median(s)) + 1e-6
    run = np.convolve(s, np.ones(3) / 3, "same")
    i = int(run.argmin()); dur = len(s) / fps; t = i / fps
    where = "loop seam" if (t > dur - 0.6 or t < 0.25) else "mid-clip (join?)"
    dip = float(run[i] / med)
    verdict = "GHOST" if dip < 0.70 else ("check" if dip < 0.80 else "clean")
    res = {"clip": os.path.basename(path), "dip": round(dip, 2), "t": round(t, 2), "dur": round(dur, 2),
           "where": where, "verdict": verdict, "box": box}
    if sheet:
        os.makedirs(sheet, exist_ok=True)
        j = int(np.argmax(run))
        out = os.path.join(sheet, os.path.basename(path).replace(".mp4", "_head.png"))
        crop = f"crop={x1 - x0}:{y1 - y0}:{x0}:{y0},scale=-2:200"
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", f"{j / fps:.3f}", "-i", path, "-ss", f"{t:.3f}", "-i", path,
                        "-filter_complex", f"[0:v]trim=end_frame=1,{crop}[a];[1:v]trim=end_frame=1,{crop}[b];[a][b]hstack",
                        "-frames:v", "1", out], check=False)
        res["sheet"] = out
    return res


if __name__ == "__main__":
    args = sys.argv[1:]
    sheet = None
    if "--sheet" in args:
        k = args.index("--sheet"); sheet = args[k + 1]; del args[k:k + 2]
    as_json = "--json" in args
    clips = [a for a in args if a != "--json"]
    rows = [audit(c, sheet) for c in clips]
    if as_json:
        print(json.dumps(rows, indent=1))
    else:
        for r in rows:
            print(r.get("error") and f"{r['clip']}: {r['error']}" or
                  f"{r['clip']:<20} head dip {r['dip']:.2f} at {r['t']:5.2f}/{r['dur']:5.2f}s  {r['where']:<16} {r['verdict']}")

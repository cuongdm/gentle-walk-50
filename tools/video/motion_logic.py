#!/usr/bin/env python3
"""Script-level check of an exercise clip from body landmarks: which leg moves, in what order, how evenly,
how high; torso lean; the loop wrap; and the exact frames that are ghosted (double image) by a crossfade.

Input: CLIP.mp4 + CLIP.mp4.pose.npz from pose_track.py (MediaPipe Pose, 33 landmarks; even ids = the
coach's RIGHT side, odd = her LEFT, anatomical). Run with any python3 that has numpy (no mediapipe needed).

Signals (all in % of the coach's standing/seated leg length = hip→ankle at rest):
  lift[side]  = how far the ankle rose above its rest row
  reach[side] = how far the ankle moved sideways/forward from its rest column
  disp[side]  = 2-D ankle displacement from rest (used for event detection)
  lean        = torso angle from vertical (shoulder-mid → hip-mid), degrees
Events = runs where disp > threshold; each: side, start, end, peak %, kind (up / out).

Expected patterns (per clip, from the production script):
  alternate : R L R L … with even timing, equal counts, and the loop wrap (last→first) also alternating
  sides     : all of one side then all of the other (two-sided move joined in one clip)
  symmetric : both legs together or no leg work (squat, sit-to-stand, arm moves): only rhythm + wrap
  hold      : only the wrap and ghost check

Ghost frames: sharpness (Laplacian variance) of the head box (from nose/eye landmarks) per frame divided by
its rolling median; frames below 0.70 are ghosted (crossfade of two different poses). Reported as time ranges.
Loop wrap: landmark distance between the last frame and the first, in % of body height; > 2% jumps.

Usage: python3 motion_logic.py CLIP.mp4 [...] [--pattern alternate|sides|symmetric|hold] [--json]
Exit 0 = OK, 2 = fault found, 1 = no pose file.
"""
import argparse, json, os, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from clip_health import probe, gray_frames, laplacian_var  # noqa: E402

NOSE, L_EYE, R_EYE = 0, 2, 5
L_SH, R_SH, L_HIP, R_HIP, L_KNEE, R_KNEE, L_ANK, R_ANK = 11, 12, 23, 24, 25, 26, 27, 28
MIN_EVENT, MERGE_GAP = 4, 3
# Known crossfade joins (seconds) in two-part clips; filled by build tools via catalog when available.
JOINS = {}


def load(path):
    f = path + ".pose.npz"
    if not os.path.exists(f):
        return None
    d = np.load(f)
    return d["xy"].astype(float), d["vis"], float(d["fps"]), int(d["width"]), int(d["height"])


def smooth(a, k=3):
    if len(a) < k:
        return a
    pad = np.pad(a, (k // 2, k // 2), mode="edge")
    return np.convolve(pad, np.ones(k) / k, "valid")


def signals(xy):
    hip = (xy[:, L_HIP] + xy[:, R_HIP]) / 2; sh = (xy[:, L_SH] + xy[:, R_SH]) / 2
    leg = np.nanmedian(np.linalg.norm(xy[:, L_ANK] - xy[:, L_HIP], axis=1)) + 1e-6
    body = np.nanmedian(np.linalg.norm(sh - hip, axis=1)) + leg
    out = {"leg_px": leg, "body_px": body}
    for side, ank in (("R", R_ANK), ("L", L_ANK)):
        ax, ay = smooth(xy[:, ank, 0]), smooth(xy[:, ank, 1])
        rest_y = np.nanpercentile(ay, 90); rest_x = np.nanmedian(ax)
        out[side] = {"lift": (rest_y - ay) / leg * 100, "reach": np.abs(ax - rest_x) / leg * 100}
        out[side]["disp"] = np.hypot(rest_y - ay, ax - rest_x) / leg * 100
    v = sh - hip
    out["lean"] = np.degrees(np.arctan2(np.abs(v[:, 0]), -v[:, 1]))
    return out


def upper_signal(xy, kind):
    """Signed upper-body signal for two-sided stretches (front view); sign = side of the image the move goes to."""
    sh = (xy[:, L_SH] + xy[:, R_SH]) / 2; hip = (xy[:, L_HIP] + xy[:, R_HIP]) / 2
    shw = np.nanmedian(np.abs(xy[:, L_SH, 0] - xy[:, R_SH, 0])) + 1e-6
    if kind == "head_turn":      # nose left/right of the midpoint between the ears (0 when facing the camera)
        v = (xy[:, NOSE, 0] - (xy[:, 7, 0] + xy[:, 8, 0]) / 2) / shw
    elif kind == "head_tilt":    # eye line angle
        d = xy[:, L_EYE] - xy[:, R_EYE]; v = np.degrees(np.arctan2(d[:, 1], d[:, 0])) / 30
    elif kind == "twist":        # shoulder line rotation seen as shoulder-depth change of the nose vs hips
        v = (xy[:, NOSE, 0] - hip[:, 0]) / shw
    else:                        # side_bend: shoulder centre left/right of hip centre
        v = (sh[:, 0] - hip[:, 0]) / shw
    if kind == "twist":          # no absolute zero: take the calmest third of the clip as neutral
        v = v - np.nanmedian(np.sort(v)[len(v) // 3: 2 * len(v) // 3])
    v = smooth(np.nan_to_num(v), 5)
    return v


def upper_events(v, fps, thr):
    evs = []
    for sign, side in ((1, "imgR"), (-1, "imgL")):
        up = sign * v > thr; i = 0; n = len(v)
        while i < n:
            if up[i]:
                j = i
                while j < n and up[j]:
                    j += 1
                if j - i >= 6:
                    evs.append({"side": side, "kind": "upper", "start": round(i / fps, 2), "end": round(j / fps, 2),
                                "peak": round(float(np.max(sign * v[i:j]) * 100), 0), "peak_t": round((i + int(np.argmax(sign * v[i:j]))) / fps, 2)})
                i = j
            else:
                i += 1
    evs = sorted(evs, key=lambda e: e["start"])
    merged = []                          # one hold that dips briefly (e.g. at a join) is still one event
    for e in evs:
        if merged and merged[-1]["side"] == e["side"] and e["start"] - merged[-1]["end"] < 1.5:
            merged[-1]["end"] = e["end"]; merged[-1]["peak"] = max(merged[-1]["peak"], e["peak"])
        else:
            merged.append(dict(e))
    return merged


def events(sig, fps, thresh):
    evs = []
    for side in ("R", "L"):
        d = np.nan_to_num(sig[side]["disp"]); up = d > thresh
        i, n = 0, len(d)
        while i < n:
            if up[i]:
                j = i
                while j < n and (up[j] or up[j:j + MERGE_GAP].any()):
                    j += 1
                if j - i >= MIN_EVENT:
                    k = i + int(np.argmax(d[i:j]))
                    kind = "up" if sig[side]["lift"][k] >= sig[side]["reach"][k] else "out"
                    evs.append({"side": side, "kind": kind, "start": round(i / fps, 2), "end": round(j / fps, 2),
                                "peak": round(float(d[k]), 0), "peak_t": round(k / fps, 2)})
                i = j
            else:
                i += 1
    return sorted(evs, key=lambda e: e["start"])


def check(evs, pattern, dur):
    f = []; sides = [e["side"] for e in evs]
    if pattern == "alternate":
        if len(evs) < 2:
            return [f"chỉ dò được {len(evs)} lần nhấc"]
        for a, b in zip(evs, evs[1:]):
            if a["side"] == b["side"]:
                f.append(f"lặp bên {a['side']} 2 lần liên tiếp ({a['start']}s và {b['start']}s)")
        if evs[-1]["side"] == evs[0]["side"]:
            f.append(f"vòng lặp nối cùng bên ({evs[-1]['side']} {evs[-1]['start']}s → {evs[0]['side']} {evs[0]['start']}s)")
        if sides.count("L") != sides.count("R"):
            f.append(f"số lần R/L = {sides.count('R')}/{sides.count('L')}")
    if pattern == "sides":
        ch = sum(1 for a, b in zip(sides, sides[1:]) if a != b)
        if len(set(sides)) == 1 and sides:
            f.append(f"chỉ thấy bên {sides[0]} chuyển động rõ — bên kia làm rất nhỏ hoặc thiếu")
        elif len(evs) < 2 or ch != 1:
            f.append(f"thứ tự bên không phải A…A B…B (chuỗi {''.join(sides)})")
    if pattern in ("alternate", "sides") and len(evs) >= 3:
        iv = np.diff([e["start"] for e in evs] + [evs[0]["start"] + dur])
        cv = float(iv.std() / iv.mean())
        if cv > 0.3:
            f.append(f"nhịp không đều (CV {cv:.2f}: {', '.join(f'{v:.2f}' for v in iv)} s)")
        for s in ("R", "L"):
            p = [e["peak"] for e in evs if e["side"] == s]
            if len(p) >= 2 and (max(p) - min(p)) / max(p) > 0.5:
                f.append(f"bên {s} nhấc không đều ({min(p):.0f}–{max(p):.0f}% chân)")
        pr = [e["peak"] for e in evs if e["side"] == "R"]; pl = [e["peak"] for e in evs if e["side"] == "L"]
        if pr and pl and abs(np.mean(pr) - np.mean(pl)) / max(np.mean(pr), np.mean(pl)) > 0.5:
            f.append(f"hai bên lệch nhau (R {np.mean(pr):.0f}% / L {np.mean(pl):.0f}%)")
    return f


def ghost_ranges(path, xy, fps):
    """Double image on the face from a crossfade of two different poses.
    The face box follows the nose landmark frame by frame (smoothed), so bending, sitting down or turning does
    not move the face out of the box. Per-frame sharpness (Laplacian variance) is divided by the median of its
    neighbours (±12 frames, excluding ±2). Ghost = run of >= 3 frames below 0.72 with a minimum below 0.62
    (checked on W1-6 2.29–2.54 s and W2-3 5.46–5.62 s). Frames where the face is not found are skipped."""
    w, h, _ = probe(path)
    import subprocess as _sp
    tag = _sp.run(["ffprobe", "-v", "error", "-show_entries", "format_tags=comment", "-of", "csv=p=0", path],
                  capture_output=True, text=True).stdout
    hardcut = "gw-loop:hardcut" in tag        # loop_best.py hard cut: the seam cannot hold a crossfade ghost
    eye = np.nanmedian(np.linalg.norm(xy[:, L_EYE] - xy[:, R_EYE], axis=1))
    hip = (xy[:, L_HIP] + xy[:, R_HIP]) / 2; sh = (xy[:, L_SH] + xy[:, R_SH]) / 2
    torso = np.nanmedian(np.linalg.norm(sh - hip, axis=1))
    # front views: size from the eye distance; profile views (eyes overlap) from the torso length
    r = max(30, int(eye * 2.2) if eye > torso * 0.12 else int(torso * 0.38))
    nx = smooth(np.nan_to_num(xy[:, NOSE, 0], nan=np.nanmedian(xy[:, NOSE, 0])), 5)
    ny = smooth(np.nan_to_num(xy[:, NOSE, 1], nan=np.nanmedian(xy[:, NOSE, 1])), 5)
    s = []
    for t, f in enumerate(gray_frames(path, w, h)):
        if t >= len(nx):
            break
        x0, x1 = max(0, int(nx[t] - r)), min(w, int(nx[t] + r)); y0, y1 = max(0, int(ny[t] - r * 1.2)), min(h, int(ny[t] + r))
        s.append(laplacian_var(f[y0:y1, x0:x1]) if (x1 - x0 > 10 and y1 - y0 > 10) else np.nan)
    s = np.array(s) + 1e-6
    n = len(s)
    # clips loop, so neighbours wrap around the seam (the last frames are compared with the first ones too)
    idx = lambda a, b: [k % n for k in range(a, b)]
    loc = np.array([s[t] / np.nanmedian(s[idx(t - 12, t - 2) + idx(t + 3, t + 13)]) for t in range(n)])
    low = np.nan_to_num(loc, nan=1.0) < 0.72
    rng = []; i = 0
    while i < n:
        if low[i]:
            j = i
            while j < n and low[j]:
                j += 1
            if j - i >= 3 and np.nanmin(loc[i:j]) < 0.62:
                mn = float(np.nanmin(loc[i:j]))
                seam = (j >= n - int(0.5 * fps) or i <= int(0.2 * fps)) and not hardcut
                near_join = any(abs(i / fps - t) < 0.4 or abs(j / fps - t) < 0.4 for t in JOINS.get(os.path.basename(path)[:-4], []))
                kind = "seam" if seam else ("join" if near_join else ("severe" if mn < 0.30 else "motion"))
                rng.append({"start": round(i / fps, 2), "end": round(j / fps, 2), "frames": j - i, "min": round(mn, 2), "kind": kind})
            i = j
        else:
            i += 1
    return rng, (int(np.median(nx) - r), int(np.median(ny) - r), int(np.median(nx) + r), int(np.median(ny) + r))


def loop_wrap(xy, body):
    """Landmark jump from the last frame to the first, as a multiple of the clip's typical frame-to-frame motion
    (a seamless loop moves as much across the seam as between any two frames: ratio ~1)."""
    ids = [NOSE, L_SH, R_SH, L_HIP, R_HIP, L_KNEE, R_KNEE, L_ANK, R_ANK]
    P = xy[:, ids]
    step = np.nanmean(np.linalg.norm(np.diff(P, axis=0), axis=2), axis=1)
    seam = float(np.nanmedian(np.linalg.norm(P[0] - P[-1], axis=1)))   # median: one jittery landmark must not decide
    ratio = seam / (float(np.nanpercentile(step, 75)) + 0.002 * body)
        # a jump must also be visible in absolute terms (> 1.5% of body height; the ghosted V8 join was 2.8%)
    return round(ratio, 1) if seam / body * 100 > 1.5 else min(round(ratio, 1), 3.0)


def analyse(path, pattern, thresh=None):
    d = load(path)
    if d is None:
        return {"clip": os.path.basename(path), "error": "no pose file — run pose_track.py first"}
    xy, vis, fps, w, h = d
    sig = signals(xy); dur = len(xy) / fps
    upper = pattern.startswith("sides:") and pattern.split(":")[1] in ("head_turn", "head_tilt", "twist", "side_bend")
    if upper:
        v = upper_signal(xy, pattern.split(":")[1])
        thr = thresh or max(0.08, 0.4 * float(np.nanpercentile(np.abs(v), 98)))
        evs = upper_events(v, fps, thr)
        faults = check(evs, "sides", dur)
    else:
        base = pattern.split(":")[0]
        if base == "profile":
            # side view: the hidden ankle's landmark wobbles, lifting its "rest" level — remove each leg's floor
            for side in ("R", "L"):
                dsp = np.nan_to_num(sig[side]["disp"]); sig[side]["disp"] = np.clip(dsp - np.percentile(dsp, 30), 0, None)
        thr = thresh or max(6.0, (0.25 if base == "sides" else 0.35) * float(np.nanpercentile(np.concatenate([sig["R"]["disp"], sig["L"]["disp"]]), 98)))
        evs = events(sig, fps, thr)
        if base == "profile":
            # side view: the far leg hides behind the near one, so left/right labels are unreliable — merge
            # events by time and check count/rhythm/height only
            merged = []
            for e in evs:
                if merged and e["start"] <= merged[-1]["end"]:
                    if e["peak"] > merged[-1]["peak"]:
                        merged[-1] = {**e, "side": "?"}
                else:
                    merged.append({**e, "side": "?"})
            evs = merged
            faults = []
            if len(evs) >= 3:
                iv = np.diff([e["start"] for e in evs] + [evs[0]["start"] + dur]); cv = float(iv.std() / iv.mean())
                if cv > 0.3:
                    faults.append(f"nhịp không đều (CV {cv:.2f}: {', '.join(f'{x:.2f}' for x in iv)} s)")
                pk = [e["peak"] for e in evs]
                if (max(pk) - min(pk)) / max(pk) > 0.5:
                    faults.append(f"biên độ các lần không đều ({min(pk):.0f}–{max(pk):.0f}% chân)")
            if len(evs) % 2:
                faults.append(f"số lần lẻ ({len(evs)}) — vòng lặp không chia đều hai chân")
        else:
            faults = [] if base == "hold" else check(evs, base, dur)
    # an event that runs through the loop seam (starts at 0 and ends at the last frame) is one event
    if len(evs) >= 2 and evs[0]["start"] <= 0.05 and evs[-1]["end"] >= dur - 0.05 and evs[0]["side"] == evs[-1]["side"]:
        evs[-1]["end"] = evs[0]["end"]; evs[-1]["peak"] = max(evs[-1]["peak"], evs[0]["peak"]); evs = evs[1:]
        faults = [f for f in faults if not f.startswith(("số lần lẻ", "nhịp không đều"))]
        if pattern.startswith("profile") and len(evs) % 2:
            faults.append(f"số lần lẻ ({len(evs)}) — vòng lặp không chia đều hai chân")
    ghosts, hbox = ghost_ranges(path, xy, fps)
    real = [g for g in ghosts if g["kind"] != "motion"]
    if real:
        label = {"seam": "nối vòng lặp", "join": "chỗ ghép", "severe": "giữa clip"}
        faults.append("in đôi tại " + ", ".join(f"{g['start']}–{g['end']}s ({label[g['kind']]}, {g['frames']} khung, nét còn {int(g['min'] * 100)}%)" for g in real))
    wrap = loop_wrap(xy, sig["body_px"])
    if wrap > 3.0:
        faults.append(f"nối vòng lặp nhảy tư thế (bước nhảy ×{wrap} so với chuyển động thường giữa 2 khung)")
    lean = float(np.nanpercentile(sig["lean"], 95))
    return {"clip": os.path.basename(path), "pattern": pattern, "duration": round(dur, 2), "threshold": round(thr, 1),
            "events": evs, "sequence": "".join(e["side"] for e in evs), "lean_p95": round(lean, 1),
            "ghosts": ghosts, "loop_wrap_pct": wrap, "faults": faults}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("clips", nargs="+"); ap.add_argument("--pattern", default="alternate")
    ap.add_argument("--thresh", type=float, default=None); ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    bad = False
    for c in a.clips:
        r = analyse(c, a.pattern, a.thresh)
        if "error" in r:
            print(f"{r['clip']}: {r['error']}"); bad = True; continue
        bad |= bool(r["faults"])
        if a.json:
            print(json.dumps(r, ensure_ascii=False))
        else:
            ev = " ".join(f"{e['side']}{e['kind']}@{e['start']}({e['peak']:.0f}%)" for e in r["events"])
            print(f"{r['clip']:<18} {r['duration']:5.2f}s seq {r['sequence']:<10} lean {r['lean_p95']:4.1f}° wrap {r['loop_wrap_pct']:4.1f}%  "
                  f"{'OK' if not r['faults'] else ' | '.join(r['faults'])}")
            print(f"    {ev}")
    sys.exit(2 if bad else 0)

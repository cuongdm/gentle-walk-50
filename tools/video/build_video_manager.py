#!/usr/bin/env python3
"""Build assets/video/video-manager.html: a local page to play, compare and triage every app clip.

Input : assets/video/video-catalog.json (hand-edited: priority, AI source, crop, issues, candidates)
Adds  : app files + easy/quick/hold variants, raw generator tries (with ✦, before crop) found under
        assets/video/{A,M3,_old}, clip_health metrics (cached by path + mtime), list thumbnails.
Output: assets/video/video-manager.html (open it straight from Finder; paths are relative).

Usage: python3 tools/video/build_video_manager.py [--no-health]
"""
import json, os, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
VIDEO = ROOT / "assets/video"
APP = ROOT / "iOS/App/Resources/Media/Video"
OUT_DIR = VIDEO / "manager"
TEMPLATE = Path(__file__).with_name("video-manager-template.html")
sys.path.insert(0, str(Path(__file__).parent))
from clip_health import measure  # noqa: E402


def rel(p: Path) -> str:
    """Path as the HTML page (in assets/video/) references it."""
    return os.path.relpath(p, VIDEO)


def base_id(clip_id: str) -> str:
    """V9-1 -> V9; W1-3 / S2 / V1-alt stay as they are (folder names under assets/video/A)."""
    return re.sub(r"^(V\d+)-1$", r"\1", clip_id)


def raw_tries(clip_id: str):
    """Generator outputs before crop: *_try*_720p.mp4 / flow-source files in the clip's folders."""
    b = re.escape(base_id(clip_id))
    folder = re.compile(rf"^({b}|{re.escape(clip_id)})(-?[LR]|-left|-right)?$")
    found = []
    for parent in (VIDEO / "A", VIDEO / "M3", VIDEO):
        if not parent.is_dir():
            continue
        for d in sorted(parent.iterdir()):
            if d.is_dir() and folder.match(d.name):
                for f in sorted(d.rglob("*.mp4")):
                    n = f.name
                    if "nologo" in n or "loop" in n or "preview" in n:
                        continue
                    if "_try" in n or "flow-source" in n:
                        found.append(f)
    return found


def thumb(src: Path, name: str) -> str:
    out = OUT_DIR / "thumbs" / f"{name}.jpg"
    if not out.exists() or out.stat().st_mtime < src.stat().st_mtime:
        out.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", "0.4", "-i", str(src), "-frames:v", "1",
                        "-vf", "scale=320:-2", "-q:v", "4", str(out)], check=True)
    return rel(out)


class HealthCache:
    def __init__(self, enabled: bool):
        self.enabled, self.path = enabled, OUT_DIR / "health-cache.json"
        self.data = json.loads(self.path.read_text()) if self.path.exists() else {}

    def get(self, f: Path):
        key, stamp = rel(f), f.stat().st_mtime
        hit = self.data.get(key)
        if hit and hit["mtime"] == stamp:
            return hit["m"]
        if not self.enabled:
            return None
        print("  measuring", key)
        m = measure(str(f))
        self.data[key] = {"mtime": stamp, "m": m}
        return m

    def save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(self.data, indent=1))


def logic(c, path):
    """motion_logic verdict for the app clip (needs <clip>.pose.npz from pose_track.py); None when no pose."""
    try:
        import motion_logic
    except Exception:
        return None
    r = motion_logic.analyse(str(path), c.get("pattern", "symmetric"))
    return None if "error" in r else r


def grade(c, m, lg=None):
    """Quality of the clip the app plays now: good / fair / poor / none, with the reasons shown on the page.
    poor = wrong move or clear picture fault; fair = small deviation or light picture fault; good = clean."""
    if c.get("missing") or not m:
        return "none", ["Chưa có clip"]
    poor, fair, notes = [], [], []
    if c.get("form") == "wrong":
        poor.append("Sai động tác / lỗi an toàn")
    elif c.get("form") == "minor":
        fair.append(f"Lệch nhỏ: {c.get('form_note', 'động tác')}")
    if m["dip"] < 0.6 or m["blur_pct"] > 3:
        poor.append(f"Nhoè rõ (độ nét còn {round(m['dip'] * 100)}%, {m['blur_pct']}% khung mờ)")
    elif m["dip"] < 0.75 or m["blur_pct"] >= 1:
        fair.append(f"Nhoè nhẹ (độ nét thấp nhất {round(m['dip'] * 100)}%, {m['blur_pct']}% khung mờ)")
    if m["stutter"] >= 3:
        poor.append(f"{m['stutter']} khung lặp (khựng)")
    # rhythm: motion_logic checks it against the move's script; the raw motion-burst CV is only a fallback
    if not lg and c.get("cat") in ("walk", "chair") and m["rhythm"] is not None and m["rhythm"] > 0.7:
        fair.append("Nhịp không đều")
    if m["drift"] > 4:
        fair.append(f"Máy trôi {m['drift']} px")
    if lg:
        logic_faults = [f for f in lg["faults"] if not f.startswith("in đôi")]
        # catalog "logic_waive": {fault prefix: reason} — a detector limit checked by eye (e.g. the far leg hidden
        # in a seated side view); the fault is shown as a note, not counted in the grade
        waive = c.get("logic_waive", {})
        waived = [f for f in logic_faults if any(f.startswith(k) for k in waive)]
        logic_faults = [f for f in logic_faults if f not in waived]
        notes = [f"Đã duyệt bằng mắt: {f} — {next(v for k, v in waive.items() if f.startswith(k))}" for f in waived]
        ghost = [g for g in lg["ghosts"] if g.get("kind") != "motion"]
        if logic_faults:
            poor += ["Logic: " + f for f in logic_faults]
        if ghost:
            where = {"seam": "nối vòng lặp", "join": "chỗ ghép", "severe": "giữa clip"}
            (poor if any(g["frames"] >= 5 or g["min"] < 0.50 for g in ghost) else fair).append(
                "In đôi " + ", ".join(f"{where.get(g.get('kind'), '')} {g['start']}–{g['end']}s ({g['frames']} khung)" for g in ghost))
    if poor:
        return "poor", poor + fair + notes
    if fair:
        return "fair", fair + notes
    return "good", notes


def build(health_on: bool):
    cat = json.loads((VIDEO / "video-catalog.json").read_text())
    cache = HealthCache(health_on)
    for c in cat["clips"]:
        versions = []
        main = APP / f"{c['id']}.mp4"
        if main.exists():
            versions.append({"kind": "app", "label": "App · bản chính", "file": rel(main), "src": c.get("src"),
                             "crop": "flow" if (c.get("src") or "").startswith("flow") else "hf-frame",
                             "m": cache.get(main)})
            c["thumb"] = thumb(main, c["id"])
            for suffix, label in (("easy", "App · chậm (easy)"), ("quick", "App · nhanh (quick)"), ("hold", "App · giữ (hold)")):
                v = APP / f"{c['id']}-{suffix}.mp4"
                if v.exists():
                    versions.append({"kind": "app", "label": label, "file": rel(v), "src": c.get("src"),
                                     "crop": "flow" if (c.get("src") or "").startswith("flow") else "hf-frame", "m": cache.get(v)})
        for cand in c.get("candidates", []):
            f = VIDEO / cand["file"]
            if f.exists():
                versions.append({**cand, "kind": "old" if cand.get("old") else "candidate", "file": rel(f), "m": cache.get(f)})
                c.setdefault("thumb_hf", thumb(f, c["id"] + "-hf"))
        for f in raw_tries(c["id"]):
            versions.append({"kind": "raw", "label": f"Nguồn gốc (trước crop) · {f.parent.name}/{f.name}",
                             "file": rel(f), "src": c.get("src"), "crop": "raw"})
        c["versions"] = versions
        c.pop("candidates", None)
        app_m = versions[0]["m"] if versions and versions[0]["kind"] == "app" else None
        lg = logic(c, main) if main.exists() else None
        c["logic"] = lg and {"sequence": lg["sequence"], "events": lg["events"], "ghosts": lg["ghosts"],
                             "wrap": lg["loop_wrap_pct"], "lean": lg["lean_p95"], "faults": lg["faults"]}
        c["quality"], c["quality_reasons"] = grade(c, app_m, lg)
        c["res"] = ("1080p" if app_m["height"] >= 1000 else "720p") if app_m else None
    cache.save()
    html = TEMPLATE.read_text().replace("__DATA__", json.dumps(cat, ensure_ascii=False))
    out = VIDEO / "video-manager.html"
    out.write_text(html)
    n = len(cat["clips"])
    print(f"wrote {rel(out)} · {n} clips · {sum(len(c['versions']) for c in cat['clips'])} versions")


if __name__ == "__main__":
    build("--no-health" not in sys.argv)

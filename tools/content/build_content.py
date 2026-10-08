#!/usr/bin/env python3
"""Build the app's bundled content JSON from the script documents in docs/scripts/.

The Markdown scripts are the single source of truth for every spoken line and every exercise;
this tool turns them into the files the app loads (plan task 1.5, content plan 30/09/2026 §5 step 7):

    iOS/App/Resources/Content/voice-lines.json   every coach line (A1, A2, A3, A4, A5-A12)
    iOS/App/Resources/Content/exercises.json     8 walk moves, 12 chair moves, 12 stretches, 3 balance (exercises.py)
    iOS/App/Resources/Content/journeys.json      5 journeys x 6 postcards
    iOS/App/Resources/Content/sessions.json      First Walk, walks (sessions_walk.py), chair moves and Balance
                                                 (sessions_chair.py), stretches, cool-downs, Morning (sessions_stretch.py)

Usage:  python3 tools/content/build_content.py [--check] [--report]
        --check   build in memory and compare with the files on disk; exit 1 if they differ.
        --report  print every session's length.

Python 3.9, standard library only (the Mac's system python).
"""
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import exercises  # noqa: E402
import sessions_chair  # noqa: E402
import sessions_stretch  # noqa: E402
import sessions_walk  # noqa: E402
import timing  # noqa: E402
import voice_lines  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / "docs" / "scripts"
PLAN = ROOT / "docs" / "plans" / "2026-09-30-content-4-groups.md"
OUT = ROOT / "iOS" / "App" / "Resources" / "Content"
SCHEMA_VERSION = 1  # keep equal to CoreInfo.contentSchemaVersion


def cells(row_rest):
    return [c.strip() for c in row_rest.split("|")]


def table_rows(path, first_cell_prefix):
    rows = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        if raw.startswith("| " + first_cell_prefix):
            rows.append(cells(raw.strip().strip("|")))
    return rows


# ---------------------------------------------------------------- journeys
JOURNEYS = [
    ("jr.ny", "New York City", True, 5.0,
     [("pc.ny.zoo", "Central Park Zoo", 0.0), ("pc.ny.bethesda", "Bethesda Fountain", 1.0),
      ("pc.ny.times", "Times Square", 2.2), ("pc.ny.bryant", "Bryant Park", 2.8),
      ("pc.ny.union", "Union Square", 3.9), ("pc.ny.bridge", "Brooklyn Bridge", 5.0)]),
    ("jr.smoky", "Smoky Mountains and the Blue Ridge Parkway", False, 12.0,
     ["Cades Cove", "Laurel Falls", "Clingmans Dome", "Mingus Mill", "Mabry Mill", "Linn Cove Viaduct"]),
    ("jr.camino", "The Camino de Santiago", False, 12.0,
     ["Sarria", "Portomarín", "Palas de Rei", "Melide", "O Pedrouzo", "Obradoiro Square"]),
    ("jr.ne", "New England lighthouses", False, 12.0,
     ["Portland Head Light", "Nubble Light", "Portsmouth Harbor", "Rockport", "Plymouth", "Nauset Light"]),
    ("jr.pch", "Pacific Coast Highway", False, 12.0,
     ["Carmel-by-the-Sea", "Point Lobos", "Bixby Bridge", "Pfeiffer Beach", "McWay Falls", "Hearst Castle"]),
]


def journeys(d_texts):
    """Stops and miles from JOURNEYS; subtitle and summary from D6; postcard backs from D7."""
    d6 = {c[0]: c for c in table_rows(d_texts, "jr.")}
    d7 = {c[0]: c for c in table_rows(d_texts, "pc.")}
    out = []
    for jid, title, free, length, stops in JOURNEYS:
        if isinstance(stops[0], tuple):
            items = [{"id": s, "name": n, "mile": m} for s, n, m in stops]
        else:  # paid routes: evenly spaced until real mileage is written (plan 1.5 "chỉnh sau")
            key = jid.split(".")[1]
            items = [{"id": "pc.%s.%d" % (key, i + 1), "name": n, "mile": round(length * i / 5, 2)}
                     for i, n in enumerate(stops)]
        for item in items:
            if item["id"] in d7:
                item["back"] = d7[item["id"]][1]
                item["coachLine"] = d7[item["id"]][2]
        entry = {"id": jid, "title": title, "isFree": free, "stops": items}
        if jid in d6:
            name = d6[jid][1]
            if "·" in name:
                entry["subtitle"] = name.split("·", 1)[1].strip()
            entry["summary"] = d6[jid][2]
        out.append(entry)
    return out


NOTIFICATION_KIND = [("nt.remind.", "reminder"), ("nt.day2.", "dayTwo"), ("nt.week.", "weeklyRecap"),
                     ("nt.back.", "comeback"), ("nt.check.", "selfCheck"), ("nt.trial", "trialEnd"),
                     ("nt.newjourney", "newJourney"),
                     ("card.fewer", "card")]
PLACEHOLDERS = [("[stop name]", "{stop}"), ("[n]", "{n}"), ("[date]", "{date}"), ("[price]", "{price}"),
                ("[journey name]", "{journey}")]


def notifications(d_texts):
    """D8 phrase bank. Lock-screen text: no health words, no "streak" (checked by copy_lint and tests)."""
    out = []
    for raw in d_texts.read_text(encoding="utf-8").splitlines():
        if not raw.startswith("|"):
            continue
        c = cells(raw.strip().strip("|"))
        if len(c) < 3 or not (c[1].startswith("nt.") or c[1].startswith("card.")):
            continue
        pid, text = c[1], c[2]
        if pid.startswith("nt.near"):  # template row: one line per stop name
            out.append({"id": "nt.near.1", "kind": "landmark", "text": "You're one walk away from {stop}."})
            continue
        kind = next(k for prefix, k in NOTIFICATION_KIND if pid.startswith(prefix))
        for a, b in PLACEHOLDERS:
            text = text.replace(a, b)
        out.append({"id": pid, "kind": kind, "text": text})
    return out


def everyday_wins(d_texts):
    """D9: one line per win; "Played on the floor" is hidden for "I can't get down on the floor"."""
    lines = [l for l in d_texts.read_text(encoding="utf-8").splitlines()]
    start = next(i for i, l in enumerate(lines) if l.startswith("## D9"))
    items = [t.strip() for t in lines[start + 1].split("·")]
    return [{"id": "win.%d" % (i + 1), "text": t, "hiddenFor": ["noFloor"] if "floor" in t.lower() else []}
            for i, t in enumerate(items)]


# ---------------------------------------------------------------- sessions
def seg(kind, seconds, cues, exercise=None):
    s = {"kind": kind, "seconds": seconds, "cues": [{"at": a, "line": l} for a, l in cues]}
    if exercise:
        s["exerciseID"] = exercise
    return s


def first_walk(a1_rows):
    """A1: intro 0:00-0:27, then one segment per bell (0:27, 2:00, 2:30, 3:00, 3:30, 4:00), end 5:00."""
    bounds = [0] + [r["time"] for r in a1_rows if r["bell"]] + [300]
    kinds = ["intro", "warmup", "brisk", "easy", "brisk", "easy", "cooldown"]
    segments = []
    for k, (start, end) in enumerate(zip(bounds, bounds[1:])):
        cues = [(r["time"] - start, r["id"]) for r in a1_rows if start <= r["time"] < end]
        segments.append(seg(kinds[k], end - start, cues))
    return {"id": "ses.firstWalk", "kind": "firstWalk", "segments": segments}


# ---------------------------------------------------------------- main
MEDIA_FIELDS = ("file", "duration", "words")


def keep_media(voice):
    """Carry file/duration/words (added by tools/voice/build_manifest.py) over from the current
    voice-lines.json when the line's text is unchanged; a rewritten line loses its old audio."""
    current = OUT / "voice-lines.json"
    if not current.exists():
        return voice
    old = {l["id"]: l for l in json.loads(current.read_text(encoding="utf-8"))["voiceLines"]}
    for line in voice:
        prev = old.get(line["id"])
        if prev and prev["text"] == line["text"]:
            line.update({k: prev[k] for k in MEDIA_FIELDS if k in prev})
    return voice


def build():
    a1, voice = voice_lines.all_lines(SCRIPTS)
    voice = keep_media(voice)
    book = timing.Voice(voice)
    timing.WARNINGS.clear()
    sessions = [first_walk(a1)]
    sessions += sessions_walk.templates(book)
    sessions += sessions_chair.templates(book)
    sessions += sessions_stretch.templates(book)
    ids = [s["id"] for s in sessions]
    if len(ids) != len(set(ids)):
        raise SystemExit("duplicate session id")
    d_texts = SCRIPTS / "D-min-texts.md"
    return {
        "voice-lines.json": {"schemaVersion": SCHEMA_VERSION, "voiceLines": voice},
        "exercises.json": {"schemaVersion": SCHEMA_VERSION,
                           "exercises": exercises.build(d_texts, SCRIPTS / "A10-stretch.md", PLAN)},
        "journeys.json": {"schemaVersion": SCHEMA_VERSION, "journeys": journeys(d_texts)},
        "notifications.json": {"schemaVersion": SCHEMA_VERSION, "phrases": notifications(d_texts)},
        "wins.json": {"schemaVersion": SCHEMA_VERSION, "wins": everyday_wins(d_texts)},
        "sessions.json": {"schemaVersion": SCHEMA_VERSION, "sessions": sessions},
    }


def report(files):
    """Length without any body limit (segments only for a limit are left out)."""
    for t in files["sessions.json"]["sessions"]:
        total = sum(seg["seconds"] for seg in t["segments"] if not seg.get("onlyFor"))
        print("%-34s %2d:%02d  %d segments" % (t["id"], total // 60, total % 60, len(t["segments"])))


def main(argv):
    files = build()
    for warning in timing.WARNINGS:
        print("timing:", warning)
    if "--report" in argv:
        report(files)
    rendered = {n: json.dumps(d, ensure_ascii=False, indent=2) + "\n" for n, d in files.items()}
    if "--check" in argv:
        stale = [n for n, text in rendered.items()
                 if not (OUT / n).exists() or (OUT / n).read_text(encoding="utf-8") != text]
        print("stale: %s" % (", ".join(stale) or "none"))
        return 1 if stale else 0
    OUT.mkdir(parents=True, exist_ok=True)
    for n, text in rendered.items():
        (OUT / n).write_text(text, encoding="utf-8")
    counts = {n: len(next(v for k, v in d.items() if k != "schemaVersion")) for n, d in files.items()}
    print("wrote %s" % ", ".join("%s (%d)" % kv for kv in counts.items()))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

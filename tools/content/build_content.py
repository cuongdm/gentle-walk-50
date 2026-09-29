#!/usr/bin/env python3
"""Build the app's bundled content JSON from the script documents in docs/scripts/.

The Markdown scripts are the single source of truth for every spoken line and every exercise;
this tool turns them into the four files the app loads (plan task 1.5):

    App/Resources/Content/voice-lines.json   every coach line (A1, A2, A3, A4, A5-A10)
    App/Resources/Content/exercises.json     6 chair moves (D5) + 8 stretch poses (A10 §2)
    App/Resources/Content/journeys.json      5 journeys x 6 postcards
    App/Resources/Content/sessions.json      First Walk, 9 walk templates, chair day, move library, 6 stretch days, cool-down

Usage:  python3 tools/content/build_content.py [--check]
        --check  build in memory and compare with the files on disk; exit 1 if they differ.

Python 3.9, standard library only (the Mac's system python).
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / "docs" / "scripts"
OUT = ROOT / "App" / "Resources" / "Content"
SCHEMA_VERSION = 1  # keep equal to CoreInfo.contentSchemaVersion

ID_ROW = re.compile(r"^\|\s*(a\d+(?:\.[\w\-]+)+)\s*\|(.*)\|\s*$")


def cells(row_rest):
    return [c.strip() for c in row_rest.split("|")]


# ---------------------------------------------------------------- voice lines
def lines_from_id_tables(path):
    """Rows whose first cell is a voice line id (a2.open.1, a10.thigh.move ...); text is the last cell."""
    out = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        if raw.startswith("| a5.n.1 "):  # "| a5.n.1 … a5.n.12 | One. · Two. · … |" -> a5.n.1 … a5.n.12
            words = [w.strip() for w in cells(raw.strip().strip("|"))[-1].split("·")]
            out.extend({"id": "a5.n.%d" % (i + 1), "text": w} for i, w in enumerate(words))
            continue
        m = ID_ROW.match(raw)
        if not m:
            continue
        out.append({"id": m.group(1), "text": cells(m.group(2))[-1]})
    return out


def lines_from_a1(path):
    """A1 table: | 01 | 0:00 | phase | text | bell | reuse |"""
    rows = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\|\s*(\d\d)\s*\|\s*(\d+:\d\d)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|", raw)
        if m:
            mm, ss = m.group(2).split(":")
            rows.append({
                "id": "a1." + m.group(1),
                "text": m.group(4).strip(),
                "time": int(mm) * 60 + int(ss),
                "bell": "đổi pha" in m.group(5),
            })
    return rows


A4_CLIPS = {"V1": "mv.sit-to-stand", "V2": "mv.knee-lift", "V3": "mv.leg-ext",
            "V4": "mv.heel-toe", "V5": "mv.wall-push", "V6": "mv.single-leg"}


def lines_from_a4(path):
    """Numbered quotes under '- **Lời giọng A4:**' inside each '### Vn ·' section -> a4.vn.k"""
    out, clip, in_list = [], None, False
    for raw in path.read_text(encoding="utf-8").splitlines():
        h = re.match(r"^### (V\d) ·", raw)
        if h:
            clip, in_list = h.group(1), False
            continue
        if raw.startswith("- **Lời giọng A4:**"):
            in_list = True
            continue
        if in_list:
            q = re.match(r'^\s+(\d+)\.\s+"(.*)"\s*$', raw)
            if q and clip:
                out.append({"id": "a4.%s.%s" % (clip.lower(), q.group(1)), "text": q.group(2)})
            elif raw.strip() and not raw.startswith("  "):
                in_list = False
    return out


# ---------------------------------------------------------------- exercises
def table_rows(path, first_cell_prefix):
    rows = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        if raw.startswith("| " + first_cell_prefix):
            rows.append(cells(raw.strip().strip("|")))
    return rows


BODY_LIMIT = {
    "knees": "knees", "hips": "hips", "lower back": "lowerBack", "shoulders": "shoulders",
    "i can't get down on the floor": "noFloor", "standing for long is hard": "standingIsHard",
    "i get dizzy easily": "dizzy", "joint replacement": "jointReplacement", "no jumping": "noJumping",
}


def limits(text):
    text = text.strip()
    if text in ("", "—", "-"):
        return []
    return [BODY_LIMIT[t.strip().lower()] for t in text.split(",")]


def moves(d_texts):
    """D5 table: | mv.id | Name · purpose | 3 tips (·) | Easier | Harder |"""
    video = {"mv.sit-to-stand": "V1-1.mp4", "mv.knee-lift": "V2-1.mp4", "mv.leg-ext": "V3-1.mp4",
             "mv.heel-toe": "V4-1.mp4", "mv.wall-push": "V5-1.mp4", "mv.single-leg": "V6-1.mp4"}
    rules = {  # counting, standing, hiddenFor, easierFor (plan 2.6: standing without a chair to hold is hidden)
        "mv.sit-to-stand": ("reps", True, [], ["knees"]),
        "mv.knee-lift": ("timed", False, [], ["hips"]),
        "mv.leg-ext": ("timed", False, [], ["knees"]),
        "mv.heel-toe": ("timed", False, [], []),
        "mv.wall-push": ("timed", True, ["standingIsHard"], ["shoulders"]),
        "mv.single-leg": ("timed", True, [], ["dizzy"]),
    }
    out = []
    for c in table_rows(d_texts, "mv."):
        mid, name_purpose, tips, easier, harder = c[:5]
        name, purpose = [p.strip() for p in name_purpose.split("·", 1)]
        counting, standing, hidden, easy_for = rules[mid]
        out.append({
            "id": mid, "kind": "move", "name": name, "purpose": purpose,
            "tips": [t.strip() for t in tips.split("·")], "easier": easier, "harder": harder,
            "videoFile": video[mid], "counting": counting, "standing": standing,
            "hiddenFor": hidden, "easierFor": easy_for,
        })
    return out


STRETCH_PURPOSE = {  # everyday purpose line; A10 intro lines carry the same idea
    "st.neck-turn": "For looking over your shoulder",
    "st.neck-tilt": "For a looser neck",
    "st.chest": "For sitting tall",
    "st.twist": "For turning to reach for things",
    "st.side": "For reaching up and across",
    "st.thigh": "For easier bending and walking",
    "st.ankle": "For steadier steps",
    "st.calf": "For comfortable walking",
}


def stretches(a10):
    """A10 §2: | Mã | Tên | Tư thế | Hai bên | Nguồn | Ẩn với | Bản dễ khi | Gợi ý (·) | Bản dễ |"""
    out = []
    for c in table_rows(a10, "st."):
        sid, name, pose, _both, source, hidden, easy_for, tips, easier = c[:9]
        out.append({
            "id": sid, "kind": "stretch", "name": name, "purpose": STRETCH_PURPOSE[sid],
            "tips": [t.strip() for t in tips.split("·")], "easier": easier,
            "counting": "hold", "standing": pose.startswith("đứng"),
            "hiddenFor": limits(hidden), "easierFor": limits(easy_for),
            "source": source.split(",")[0].strip(),
        })
    return out


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


def journeys():
    out = []
    for jid, title, free, length, stops in JOURNEYS:
        if isinstance(stops[0], tuple):
            items = [{"id": s, "name": n, "mile": m} for s, n, m in stops]
        else:  # paid routes: evenly spaced until real mileage is written (plan 1.5 "chỉnh sau")
            key = jid.split(".")[1]
            items = [{"id": "pc.%s.%d" % (key, i + 1), "name": n, "mile": round(length * i / 5, 2)}
                     for i, n in enumerate(stops)]
        out.append({"id": jid, "title": title, "isFree": free, "stops": items})
    return out


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


INTENSITY = {  # A2 §2: warm-up, rounds x (brisk, easy), cool-down
    "gentle": (120, 2, 30, 30, 60),
    "steady": (120, 2, 60, 60, 120),
    "strong": (120, 3, 60, 60, 120),
}


def walk(level, intensity):
    warm, rounds, brisk, easy, cool = INTENSITY[intensity]
    lvl = {"seated": "seated", "inplace": "inplace", "pad": "pad"}[level]
    warm_cues = [(0, "a2.open.1"), (8, "a2.setup.%s.1" % lvl), (20, "a1.04"), (31, "a1.05"), (42, "a1.06"),
                 (53, "a1.07"), (64, "a1.08" if level == "seated" else "a2.warm.1"), (75, "a1.09"),
                 (86, "a1.10"), (97, "a1.11"), (warm - 8, "a1.12")]
    segments = [seg("warmup", warm, warm_cues)]
    for r in range(rounds):
        last = r == rounds - 1
        if r == 0:
            start = "a2.brisk.%s.1" % lvl
        else:
            start = "a2.brisk.last" if last else "a1.19"
        bc = [(0, start), (10, "a1.14" if r == 0 else "a1.20")]
        if brisk >= 60:
            bc.append((30, "a2.brisk.mid.1"))
        bc.append((brisk - 10, "a1.15" if brisk < 60 else "a5.10s"))
        segments.append(seg("brisk", brisk, bc))
        ec = [(0, "a1.16" if r == 0 else "a1.22"), (10, "a1.17" if r == 0 else "a1.23")]
        if easy >= 60:
            ec.append((30, "a2.easy.mid.1"))
        if not last:
            ec.append((easy - 8, "a1.18" if easy < 60 else "a2.round.1"))
        segments.append(seg("easy", easy, ec))
    cc = [(0, "a2.cool.%s.1" % lvl), (10, "a1.26"), (22, "a1.27"), (34, "a1.28")]
    if cool >= 120:
        cc.append((60, "a2.cool.mid.1"))
    if level == "pad":
        cc.append((cool - 20, "a2.cool.pad.2"))
    cc.append((cool - 8, "a2.close.1"))
    segments.append(seg("cooldown", cool, cc))
    return {"id": "ses.walk.%s.%s" % (level, intensity), "kind": "walk", "segments": segments}


BILATERAL = {"st.neck-turn", "st.neck-tilt", "st.twist", "st.side", "st.thigh", "st.ankle", "st.calf"}


def pose(sid, hold, with_setup=True):
    """One pose, one hold per side (A10 §3). Returns (segment, seconds)."""
    key = sid.split(".", 1)[1]
    cues, t = [(0, "a10.%s.intro" % key)], 5
    if with_setup:
        cues.append((t, "a10.%s.setup" % key))
        t += 7
    if sid in BILATERAL:
        cues += [(t, "a10.left"), (t + 2, "a10.%s.move" % key)]
        t += 8
        cues.append((t + hold // 2, "a10.hold.1"))
        t += hold
        cues.append((t, "a10.switch.1"))
        t += 4
        cues.append((t + hold // 2, "a10.hold.3"))
        t += hold
    else:
        cues.append((t, "a10.%s.move" % key))
        t += 6
        cues.append((t + hold // 2, "a10.hold.2"))
        t += hold
    cues.append((t, "a10.release.1"))
    t += 4
    return seg("stretch", t, cues, sid)


STRETCH_HOLD = {"gentle": 10, "steady": 20, "strong": 30}  # seconds per side, once per side (A10 §3)


def stretch_day(standing, intensity):
    order = ["st.neck-turn", "st.neck-tilt", "st.chest", "st.twist",
             "st.thigh", "st.ankle", "st.calf"] if standing else \
            ["st.neck-turn", "st.neck-tilt", "st.chest", "st.twist", "st.side", "st.thigh", "st.ankle"]
    segments = [seg("intro", 12, [(0, "a10.open.1"), (6, "a10.open.2")])]
    for sid in order:
        if sid == "st.calf":
            segments.append(seg("rest", 8, [(0, "a7.stand")]))
        segments.append(pose(sid, STRETCH_HOLD[intensity]))
    segments.append(seg("outro", 10, [(0, "a10.close.1")]))
    return {"id": "ses.stretch.%s.%s" % ("standing" if standing else "seated", intensity),
            "kind": "stretch", "segments": segments}


def cooldown():
    segments = [seg("intro", 6, [(0, "a10.cool.open")])]
    for sid in ["st.neck-turn", "st.thigh", "st.chest"]:
        segments.append(pose(sid, 15, with_setup=False))
    segments.append(seg("outro", 8, [(0, "a10.cool.close")]))
    return {"id": "ses.cooldown", "kind": "cooldown", "segments": segments}


# Chair move -> A4 clip script and seconds (V-exercise-clips.md: V1..V6).
MOVE_CLIPS = [("mv.sit-to-stand", "v1", 90), ("mv.knee-lift", "v2", 60), ("mv.leg-ext", "v3", 60),
              ("mv.heel-toe", "v4", 60), ("mv.wall-push", "v5", 60), ("mv.single-leg", "v6", 60)]


def move_segment(a4_lines, mid, clip, secs):
    """One chair move with its A4 lines spread evenly over the move."""
    ids = [l["id"] for l in a4_lines if l["id"].startswith("a4.%s." % clip)]
    step = max(1, (secs - 8) // max(1, len(ids)))
    return seg("move", secs, [(i * step, lid) for i, lid in enumerate(ids)], mid)


def chair_day(a4_lines):
    """Default chair day: 4 moves, 20 s rest between, cue each move's A4 lines evenly (SessionBuilder 2.8 varies it)."""
    default = ["mv.sit-to-stand", "mv.knee-lift", "mv.heel-toe", "mv.leg-ext"]
    by_id = {m[0]: m for m in MOVE_CLIPS}
    segments = [seg("intro", 8, [(0, "a9.chair.open")])]
    for n, mid in enumerate(default):
        segments.append(move_segment(a4_lines, *by_id[mid]))
        if n < len(default) - 1:
            segments.append(seg("rest", 20, [(0, "a5.rest20")]))
    segments.append(seg("outro", 8, [(0, "a9.chair.close")]))
    return {"id": "ses.chair.default", "kind": "chair", "segments": segments}


def move_library(a4_lines):
    """Every chair move as a ready segment; SessionBuilder (2.8) picks and rotates from here."""
    return {"id": "ses.moves", "kind": "chair",
            "segments": [move_segment(a4_lines, *m) for m in MOVE_CLIPS]}


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
    a1 = lines_from_a1(SCRIPTS / "A1-first-walk.md")
    a4 = lines_from_a4(SCRIPTS / "V-exercise-clips.md")
    voice = [{"id": r["id"], "text": r["text"]} for r in a1] + a4
    for name in ["A2-walk-min.md", "A-min-support.md", "A10-stretch.md"]:
        voice += lines_from_id_tables(SCRIPTS / name)
    voice = keep_media(voice)
    sessions = [first_walk(a1)]
    sessions += [walk(l, i) for l in ("seated", "inplace", "pad") for i in ("gentle", "steady", "strong")]
    sessions += [chair_day(a4), move_library(a4)]
    sessions += [stretch_day(standing, i) for standing in (False, True) for i in ("gentle", "steady", "strong")]
    sessions += [cooldown()]
    return {
        "voice-lines.json": {"schemaVersion": SCHEMA_VERSION, "voiceLines": voice},
        "exercises.json": {"schemaVersion": SCHEMA_VERSION,
                           "exercises": moves(SCRIPTS / "D-min-texts.md") + stretches(SCRIPTS / "A10-stretch.md")},
        "journeys.json": {"schemaVersion": SCHEMA_VERSION, "journeys": journeys()},
        "sessions.json": {"schemaVersion": SCHEMA_VERSION, "sessions": sessions},
    }


def main(argv):
    files = build()
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

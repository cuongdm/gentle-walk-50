"""exercises.json: 8 walking moves, 12 chair moves, 12 stretch poses and 3 balance exercises.

Copy (name, purpose, tips, easier, harder, chip notes) comes from D-min-texts.md §D5 (old table and
"D5 — bài mới 30/09/2026") and A10-stretch.md §2; sources from the content plan tables (§2.1–§2.3).
How each one is played (counting, standing, hidden and easier-by-default limits, clip names) is set
below from the plan (§2, §3) and A4 §0.1 / A10 §2, §8.1. Clip names follow PROMPTS §0.1 and are
listed even before the file exists; `videoLater` marks the ones of batch B.
Python 3.9, standard library only.
"""
import re

import md_tables

CHIP = {  # S06 chip labels (D5 chip table, A10 §2) -> BodyLimit raw values
    "knees": "knees", "hips": "hips", "lower back": "lowerBack", "shoulders": "shoulders",
    "i can't get down on the floor": "noFloor", "standing for long is hard": "standingIsHard",
    "i get dizzy easily": "dizzy", "joint replacement": "jointReplacement", "no jumping": "noJumping",
}

# id: (counting, standing, hiddenFor, easierFor, clips) -- clips: file keys of Exercise
WALK = {
    "wk.march": ({"videoSeated": "W1-1.mp4", "videoFile": "W2-1.mp4"}, []),
    "wk.heel-dig": ({"videoSeated": "W1-2.mp4", "videoFile": "W2-4.mp4"}, []),
    "wk.side-step": ({"videoSeated": "W1-3.mp4", "videoFile": "W2-2.mp4"}, []),
    "wk.knee-lift": ({"videoSeated": "W1-4.mp4", "videoFile": "W2-3.mp4"}, []),
    "wk.toe-tap": ({"videoSeated": "W1-5.mp4", "videoFile": "W2-5.mp4"}, ["W2-5.mp4"]),
    # Seated heel to back has no clip (A2 question 4): the seated walk shows its picture.
    "wk.heel-back": ({"videoFile": "W2-6.mp4"}, ["W2-6.mp4"]),
    "wk.shift": ({"videoSeated": "W1-6.mp4", "videoFile": "W2-7.mp4"}, ["W2-7.mp4"]),
    # Arms are layered on the march (plan §2.1): no clip of their own.
    "wk.arms": ({}, []),
}

CHAIR = {
    # Sit-to-stand starts seated: no "Stand behind your chair" screen before it.
    "mv.sit-to-stand": ("reps", False, [], ["knees", "jointReplacement"], {"videoFile": "V1-1.mp4", "videoEasy": "V1-alt.mp4"}),
    "mv.knee-lift": ("timed", False, [], ["hips", "jointReplacement"], {"videoFile": "V2-1.mp4"}),
    "mv.leg-ext": ("timed", False, [], ["knees"], {"videoFile": "V3-1.mp4"}),
    # V4-alt: standing behind the chair (the harder version, and Balance's heel and toe raises).
    "mv.heel-toe": ("timed", False, [], [], {"videoFile": "V4-1.mp4", "videoAlt": "V4-alt.mp4"}),
    "mv.wall-push": ("reps", True, ["standingIsHard"], ["shoulders"], {"videoFile": "V5-1.mp4"}),
    "mv.single-leg": ("timed", True, ["standingIsHard"], ["dizzy"], {"videoFile": "V6-1.mp4"}),
    "mv.side-leg": ("reps", True, ["standingIsHard"], ["jointReplacement"], {"videoFile": "V8-1.mp4", "videoEasy": "V8-1-easy.mp4"}),
    "mv.back-leg": ("reps", True, ["standingIsHard"], ["lowerBack"], {"videoFile": "V9-1.mp4"}),
    "mv.knee-curl": ("reps", True, ["standingIsHard"], ["jointReplacement", "knees"], {"videoFile": "V10-1.mp4"}),
    "mv.mini-squat": ("reps", True, ["standingIsHard"], ["knees", "jointReplacement"], {"videoFile": "V11-1.mp4"}),
    "mv.arm-raise": ("reps", False, [], ["shoulders"], {"videoFile": "V12-1.mp4"}),
    "mv.row": ("reps", False, [], [], {"videoFile": "V13-1.mp4"}),
}

STRETCH = {  # counting, standing, clip number (plan §2.3, PROMPTS §0.1); hold clip S<n>-hold where made
    "st.neck-turn": ("reps", False, 1), "st.neck-tilt": ("hold", False, 2), "st.chin-tuck": ("reps", False, 3),
    "st.shoulder-roll": ("reps", False, 4), "st.chest": ("hold", False, 5), "st.upper-back": ("hold", False, 6),
    "st.twist": ("hold", False, 7), "st.side": ("hold", False, 8), "st.thigh": ("hold", False, 9),
    "st.ankle": ("timed", False, 10), "st.calf": ("hold", True, 11),
    # At the wall (or seated when standing is hard): the "to the wall" line leads her there.
    "st.overhead": ("hold", False, 12),
}
NEW_STRETCH_EASIER_FOR = {  # A10 §8.1 "Bản dễ khi"
    "st.chin-tuck": [], "st.shoulder-roll": ["shoulders"], "st.upper-back": ["lowerBack", "shoulders"],
    "st.overhead": ["shoulders", "standingIsHard"],
}
STRETCH_PURPOSE = {  # everyday purpose line of the 8 poses of 29/09 (A10 intro lines carry the same idea)
    "st.neck-turn": "For looking over your shoulder", "st.neck-tilt": "For a looser neck",
    "st.chest": "For sitting tall", "st.twist": "For turning to reach for things",
    "st.side": "For reaching up and across", "st.thigh": "For easier bending and walking",
    "st.ankle": "For steadier steps", "st.calf": "For comfortable walking",
}

BALANCE = {
    "bl.tandem": ({"videoFile": "B1.mp4", "videoHold": "B1-hold.mp4"}, [], ["dizzy"], "S16 p.18"),
    # No sideways-walking clip (owner 30/09/2026 (a)): the side step clip illustrates it.
    "bl.side-walk": ({"videoFile": "W2-2.mp4"}, [], ["dizzy"], "S16 p.21, S13"),
    "bl.heel-toe-walk": ({"videoFile": "B3.mp4"}, ["B3.mp4"], [], "S13, S9 p.66, S16 p.23"),
}


def limits(text):
    text = text.strip()
    if text in ("", "—", "-"):
        return []
    return [CHIP[t.strip().lower()] for t in text.split(",")]


def sources(plan_path):
    """Plan §2.1–§2.3 rows: first cell the id, last cell '[S11][S15][S16]' -> 'S11, S15, S16'."""
    out = {}
    for table in md_tables.tables(plan_path):
        col = table.column("Nguồn")
        if col is None:
            continue
        for row in table.rows:
            sid = md_tables.strip_marks(row[0])
            if re.match(r"^(wk|mv|st|bl)\.", sid):
                codes = re.findall(r"\[([^\]]+)\]", row[col])
                out[sid] = ", ".join(codes) if codes else row[col]
    return out


def d5_rows(d_texts):
    """{id: row} from every D5 table with 'Tên · mục đích' (old D5 and D5 — bài mới)."""
    rows = {}
    for table in md_tables.tables(d_texts):
        if table.column("Tên · mục đích") is None:
            continue
        for row in table.rows:
            rows[md_tables.strip_marks(row[0])] = row
    return rows


def chip_notes(d_texts):
    """D5 'Biến thể theo chip S06': {id: [{limit, text}]}."""
    notes = {}
    for table in md_tables.tables(d_texts):
        if table.header[:3] != ["Mã", "Chip", "Text"]:
            continue
        for sid, chip, text in (r[:3] for r in table.rows):
            notes.setdefault(sid, []).append({"limit": CHIP[chip.lower()], "text": text})
    return notes


def from_d5(row):
    sid, name_purpose, tips, easier, harder = row[:5]
    name, purpose = [p.strip() for p in name_purpose.split("·", 1)]
    entry = {"id": sid, "name": name, "purpose": purpose,
             "tips": [t.strip() for t in tips.split("·")], "easier": easier}
    if harder not in ("—", "-", ""):
        entry["harder"] = harder
    return entry


def build(d_texts, a10, plan):
    d5, notes, src = d5_rows(d_texts), chip_notes(d_texts), sources(plan)
    out = []

    def finish(entry, **fields):
        entry.update({k: v for k, v in fields.items() if v not in (None, [], {})})
        entry.setdefault("hiddenFor", [])
        entry.setdefault("easierFor", [])
        if entry["id"] in notes:
            entry["limitNotes"] = notes[entry["id"]]
        if entry["id"] in src:
            entry["source"] = src[entry["id"]]
        out.append(entry)

    for sid, (clips, later) in WALK.items():
        e = from_d5(d5[sid])
        e.update({"kind": "walk", "counting": "timed", "standing": False})
        e.update(clips)
        finish(e, videoLater=later, easierFor=[n["limit"] for n in notes.get(sid, [])])

    for sid, (counting, standing, hidden, easy_for, clips) in CHAIR.items():
        e = from_d5(d5[sid])
        e.update({"kind": "move", "counting": counting, "standing": standing})
        e.update(clips)
        finish(e, hiddenFor=hidden, easierFor=easy_for)

    a10_rows = {}
    for table in md_tables.tables(a10):
        if table.column("Tên hiển thị (D5)") is not None:
            a10_rows.update({r[0]: r for r in table.rows})
    for sid, (counting, standing, number) in STRETCH.items():
        if sid in a10_rows:  # the 8 poses of 29/09: A10 §2
            _, name, _pose, _both, _src, hidden, easy_for, tips, easier = a10_rows[sid][:9]
            e = {"id": sid, "name": name, "purpose": STRETCH_PURPOSE[sid],
                 "tips": [t.strip() for t in tips.split("·")], "easier": easier}
            hidden, easy_for = limits(hidden), limits(easy_for)
        else:  # the 4 new poses: D5 — bài mới
            e = from_d5(d5[sid])
            hidden, easy_for = [], NEW_STRETCH_EASIER_FOR[sid]
        e.update({"kind": "stretch", "counting": counting, "standing": standing,
                  "videoFile": "S%d.mp4" % number})
        # A two-sided pose's hold clip shows the first side (the app plays it for that side only).
        e["videoHold"] = "S%d-hold.mp4" % number
        finish(e, hiddenFor=hidden, easierFor=easy_for)

    for sid, (clips, later, easy_for, source) in BALANCE.items():
        e = from_d5(d5[sid])
        e.update({"kind": "balance", "counting": "timed", "standing": True})
        e.update(clips)
        src.setdefault(sid, source)
        finish(e, videoLater=later, hiddenFor=["standingIsHard"], easierFor=easy_for)
    return out

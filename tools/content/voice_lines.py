"""Every coach line from the scripts, with the level and body-limit restrictions written in their notes.

Sources (docs/scripts): A1 (numbered table), A2-walk.md, A4-chair-moves.md, A10-stretch.md, A11-extras.md, A12,
A-min-support.md (A3, A5–A9). A line is a table row whose first cell is its id (a2.move.march.intro)
in a table with a "Câu thoại" column; the "Ghi chú" column may restrict it:
  "chỉ Seated", "chỉ In place / Pad", "chỉ đứng" ... -> "levels"
  "không Joint replacement"                          -> "hiddenFor"
Python 3.9, standard library only.
"""
import re

import md_tables

LINE_ID = re.compile(r"^a\d+(?:\.[\w\-]+)+$")
SCRIPT_FILES = ["A2-walk.md", "A-min-support.md", "A4-chair-moves.md", "A10-stretch.md", "A11-extras.md",
                "A12-steady-program.md"]
LEVEL_WORDS = {"seated": "seated", "in place": "inplace", "pad": "pad", "walking pad": "pad", "đứng": None}


def a1_lines(path):
    """A1 table: | 01 | 0:00 | phase | text | bell | reuse |"""
    rows = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\|\s*(\d\d)\s*\|\s*(\d+:\d\d)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|", raw)
        if m:
            mm, ss = m.group(2).split(":")
            rows.append({"id": "a1." + m.group(1), "text": m.group(4).strip(),
                         "time": int(mm) * 60 + int(ss), "bell": "đổi pha" in m.group(5)})
    return rows


def restrictions(note):
    """'mới; chỉ In place / Pad' -> (['inplace', 'pad'], []); 'không Joint replacement' -> (None, ['jointReplacement'])."""
    levels = None
    low = note.lower().replace("**", "")
    m = re.search(r"chỉ (seated|in place|walking pad|pad|đứng)((?:\s*/\s*(?:in place|walking pad|pad))*)", low)
    if m:
        first = m.group(1)
        if first == "đứng":
            levels = ["inplace", "pad"]
        else:
            levels = [LEVEL_WORDS[first]]
            for extra in re.findall(r"in place|walking pad|pad", m.group(2)):
                if LEVEL_WORDS[extra] not in levels:
                    levels.append(LEVEL_WORDS[extra])
    hidden = ["jointReplacement"] if "không joint replacement" in low else []
    return levels, hidden


def script_lines(path):
    out = []
    for table in md_tables.tables(path):
        text_col = table.column("Câu thoại")
        if text_col is None or not table.header or table.header[0] != "ID":
            continue
        note_col = table.column("Ghi chú")
        for row in table.rows:
            first = row[0]
            if first.startswith("a5.n.1 "):  # "a5.n.1 … a5.n.12 | One. · Two. · …"
                words = [w.strip() for w in row[text_col].split("·")]
                out += [{"id": "a5.n.%d" % (i + 1), "text": w} for i, w in enumerate(words)]
                continue
            if not LINE_ID.match(first):
                continue
            line = {"id": first, "text": row[text_col]}
            if note_col is not None and note_col < len(row):
                levels, hidden = restrictions(row[note_col])
                if levels:
                    line["levels"] = levels
                if hidden:
                    line["hiddenFor"] = hidden
            out.append(line)
    return out


def all_lines(scripts_dir):
    """(a1 rows, voice lines in file order). Raises on an id written twice with different text."""
    a1 = a1_lines(scripts_dir / "A1-first-walk.md")
    voice = [{"id": r["id"], "text": r["text"]} for r in a1]
    seen = {l["id"]: l for l in voice}
    for name in SCRIPT_FILES:
        for line in script_lines(scripts_dir / name):
            prev = seen.get(line["id"])
            if prev:
                if prev["text"] != line["text"]:
                    raise SystemExit("line %s written twice with different text (%s)" % (line["id"], name))
                continue
            seen[line["id"]] = line
            voice.append(line)
    for line in voice:
        if not line["text"]:
            raise SystemExit("line %s has no text" % line["id"])
    return a1, voice

#!/usr/bin/env python3
"""Quality check for recorded coach lines in one language (cache of tools/voice/render_lines*.py).

For every line of the language (docs/i18n/<lang>/voice-*.json) with a render in the cache:
  1. Said right: the words speech to text heard ("heard" in the cache file, Vibi renders) against the
     line's words. Number words may come back as digits ("mười" → "10"): a digit token matches the
     number words around it. Below 85 % of words matched → flagged.
  2. Length: against the English line's duration (lines play at fixed seconds in a session):
     longer than 1.6× or shorter than 0.45× → flagged; and a line over 1.3× that is also over 4 s.
  3. Silence: more than 0.6 s before the voice or 1.0 s after it, or a gap over 1.2 s inside it.
  4. Level: peaks at 0 dBFS (clipping) or a whisper (mean below -38 dBFS).
  5. Fit: in every session template, does the line still end before the next cue of the same
     segment would start (as in English)? A line that pushes the next one by more than 1.5 s more than
     in English, or past the end of its segment, is flagged.
Writes docs/i18n/<lang>/qc-report.md and prints the ids to render again (--ids-only for just those).
Usage: python3 tools/voice/qc_lines.py vi [--ids-only]
"""
import difflib
import glob
import json
import re
import subprocess
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "voice"))
import build_manifest as bm  # noqa: E402
import render_lines as rl  # noqa: E402

CONTENT = ROOT / "iOS" / "App" / "Resources" / "Content"
NUMBER_WORDS = {"không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín", "mười", "mươi", "mốt", "lăm",
                "tư", "trăm", "nghìn", "linh", "lẻ"}


def norm(word):
    return re.sub(r"[^\w]", "", unicodedata.normalize("NFC", word.lower()))


def said_right(text, heard):
    """Share of the line's words found, in order, in what was heard."""
    want = [norm(w) for w in text.split() if norm(w)]
    got = [norm(w) for w in (heard or "").split() if norm(w)]
    if not want:
        return 1.0
    matcher = difflib.SequenceMatcher(a=want, b=got, autojunk=False)
    matched = sum(b.size for b in matcher.get_matching_blocks())
    # Number words heard as digits: count them as matched when a digit stands where they are missing.
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "replace" and all(w in NUMBER_WORDS for w in want[i1:i2]) and all(g.isdigit() for g in got[j1:j2]):
            matched += i2 - i1
    return matched / len(want)


def probe(mp3):
    """duration, leading silence, trailing silence, longest inner gap, max dB, mean dB."""
    duration = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
                                     str(mp3)], capture_output=True, text=True, check=True).stdout.strip())
    log = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(mp3), "-af",
                          "silencedetect=noise=-40dB:d=0.25,volumedetect", "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    starts = [float(x) for x in re.findall(r"silence_start: (-?[\d.]+)", log)]
    ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", log)]
    lead = ends[0] if starts and starts[0] <= 0.05 and ends else 0.0
    trail = duration - starts[-1] if starts and (len(starts) > len(ends) or starts[-1] > ends[-1]) else 0.0
    inner = [e - s for s, e in zip(starts, ends) if s > 0.05 and e < duration - 0.05]
    max_db = float(re.search(r"max_volume: (-?[\d.]+)", log).group(1))
    mean_db = float(re.search(r"mean_volume: (-?[\d.]+)", log).group(1))
    return duration, lead, trail, max(inner, default=0.0), max_db, mean_db


def fits(durations_en, durations_lang):
    """Per line id: worst extra push (s) of the next cue, and whether it now overruns its segment."""
    sessions = json.load(open(CONTENT / "sessions.json", encoding="utf-8"))["sessions"]
    worst = {}

    def pushes(segment, durations):
        cues = sorted(segment.get("cues", []), key=lambda c: c["at"])
        out, t_end = {}, 0.0
        for k, cue in enumerate(cues):
            start = max(float(cue["at"]), t_end)
            t_end = start + durations.get(cue["line"], 2.0)
            nxt = float(cues[k + 1]["at"]) if k + 1 < len(cues) else float(segment.get("seconds", 0) or 0)
            out[cue["line"]] = (max(0.0, t_end - nxt), k + 1 == len(cues) and nxt > 0 and t_end > nxt)
        return out

    for session in sessions:
        for segment in session.get("segments", []):
            en, lang = pushes(segment, durations_en), pushes(segment, durations_lang)
            for line, (push, over) in lang.items():
                extra = push - en.get(line, (0.0, False))[0]
                overrun = over and not en.get(line, (0.0, False))[1]
                old = worst.get(line, (0.0, False))
                worst[line] = (max(old[0], extra), old[1] or overrun)
    return worst


def main(argv):
    lang = argv[1]
    ids_only = "--ids-only" in argv
    rl.VOICE = next(v for v in rl.VOICES.values() if v.get("language") == lang)
    rl.CACHE = rl.VOICE["cache"]
    texts = rl.load_lines()
    english = {v["id"]: v for v in json.load(open(CONTENT / "voice-lines.json", encoding="utf-8"))["voiceLines"]}
    rows, flagged, durations = [], {}, {}
    for line_id, text in texts.items():
        mp3 = rl.CACHE / f"{rl.cache_key(text)}.mp3"
        meta = mp3.with_suffix(".json")
        if not mp3.exists():
            flagged[line_id] = ["not recorded"]
            continue
        info = json.load(open(meta, encoding="utf-8"))
        duration, lead, trail, gap, max_db, mean_db = probe(mp3)
        durations[line_id] = duration
        problems = []
        heard = info.get("heard")
        if heard is not None:
            score = said_right(text, heard)
            if score < 0.85:
                problems.append(f"said {score:.0%} right — heard: “{heard}”")
        en = english.get(line_id, {}).get("duration") or 0
        if en:
            ratio = duration / en
            if ratio > 1.6 or ratio < 0.45 or (ratio > 1.3 and duration > 4):
                problems.append(f"length {duration:.1f}s vs English {en:.1f}s ({ratio:.2f}×)")
        if lead > 0.6 or trail > 1.0 or gap > 1.2:
            problems.append(f"silence: {lead:.1f}s before, {trail:.1f}s after, gap {gap:.1f}s")
        if max_db >= -0.1 or mean_db < -38:
            problems.append(f"level: peak {max_db:.1f} dB, mean {mean_db:.1f} dB")
        if problems:
            flagged[line_id] = problems
        rows.append((line_id, duration, en))
    en_durations = {k: v.get("duration") or 2.0 for k, v in english.items()}
    for line_id, (extra, overrun) in fits(en_durations, {**en_durations, **durations}).items():
        if line_id in durations and (extra > 1.5 or overrun):
            flagged.setdefault(line_id, []).append(
                f"fit: pushes the next line {extra:.1f}s more than English" + ("; runs past its part" if overrun else ""))
    redo = [i for i, p in flagged.items()
            if any(not x.startswith(("fit:", "length", "not recorded")) for x in p)]
    missing = [i for i, p in flagged.items() if p == ["not recorded"]]
    if ids_only:
        print(" ".join(redo))
        return 0
    total_vi = sum(durations.values())
    total_en = sum(english[i].get("duration") or 0 for i in durations if i in english)
    lines = [f"# QC giọng {lang} — {len(durations)}/{len(texts)} câu đã thu", "",
             f"Tổng thời lượng: {total_vi / 60:.1f} phút (tiếng Anh cùng các câu: {total_en / 60:.1f} phút).",
             f"Chưa thu: {len(missing)}. Cờ khác: {len(flagged) - len(missing)} câu; cần thu lại (phát âm / im lặng / mức âm): {len(redo)}.", ""]
    for line_id, problems in sorted(flagged.items()):
        if problems == ["not recorded"]:
            continue
        lines.append(f"- `{line_id}` — {texts.get(line_id, '')}")
        lines += [f"  - {p}" for p in problems]
    out = ROOT / "docs" / "i18n" / lang / "qc-report.md"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines[:4]))
    print("report:", out.relative_to(ROOT))
    print("render again:", " ".join(redo) or "none")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

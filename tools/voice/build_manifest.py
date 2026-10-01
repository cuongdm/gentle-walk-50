#!/usr/bin/env python3
"""Attach recorded voice files to iOS/App/Resources/Content/voice-lines.json (plan task 1.6).

For every voice line whose text matches a cached ElevenLabs render (assets/voice/cache/<hash>.mp3 +
<hash>.json with character alignment), this tool:
  - converts the mp3 to AAC  iOS/App/Resources/Media/Voice/<line id>.m4a at -16 LUFS integrated
    (one gain per line, peaks limited near -1.5 dBFS; content plan §4.3)
  - writes  file, duration (seconds) and words [{word, start, end}]  into the voice line entry.

Lines without a match keep no `file` field; the app then uses the DEBUG speech fallback (task 3.3)
and the release content check (task 9.2) reports them.

Usage:  python3 tools/voice/build_manifest.py [--cache DIR] [--lines FILE] [--media DIR]
Python 3.9, standard library + ffmpeg/ffprobe on PATH.
"""
import argparse
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CACHE = ROOT / "assets" / "voice" / "cache"
DEFAULT_LINES = ROOT / "iOS" / "App" / "Resources" / "Content" / "voice-lines.json"
DEFAULT_MEDIA = ROOT / "iOS" / "App" / "Resources" / "Media" / "Voice"


def words_from_alignment(alignment):
    """Group ElevenLabs per-character times into words (split on whitespace)."""
    words, current, start, end = [], "", None, None
    for ch, a, b in zip(alignment["characters"],
                        alignment["character_start_times_seconds"],
                        alignment["character_end_times_seconds"]):
        if ch.isspace():
            if current:
                words.append({"word": current, "start": round(start, 3), "end": round(end, 3)})
                current = ""
            continue
        if not current:
            start = a
        current += ch
        end = b
    if current:
        words.append({"word": current, "start": round(start, 3), "end": round(end, 3)})
    return words


def normalize(text):
    """Compare texts regardless of curly quotes, ellipsis style and spacing."""
    text = text.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')
    text = text.replace("…", "...")
    return re.sub(r"\s+", " ", text).strip()


def audio_duration(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True, check=True).stdout
    return round(float(out.strip()), 3)


TARGET_LUFS = -16.0
PEAK_LIMIT = 0.79  # -2 dBFS before AAC, so the encoded peak stays near -1.5 dBFS


def measure_loudness(src):
    """Integrated loudness of a clip in LUFS (EBU R128, ffmpeg loudnorm first pass)."""
    out = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(src), "-af",
                          "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json", "-f", "null", "-"],
                         capture_output=True, text=True, check=True).stderr
    return float(json.loads(out[out.rindex("{"):out.rindex("}") + 1])["input_i"])


def convert_to_m4a(src, dst):
    """AAC mono at -16 LUFS: one gain for the whole line (no pumping), then a peak limiter
    (about -1.5 dBFS after encoding)."""
    dst.parent.mkdir(parents=True, exist_ok=True)
    gain = TARGET_LUFS - measure_loudness(src)
    chain = "volume=%.2fdB,alimiter=limit=%.2f:attack=5:release=50:level=disabled" % (gain, PEAK_LIMIT)
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(src), "-af", chain, "-ar", "44100",
                    "-c:a", "aac", "-b:a", "96k", "-ac", "1", str(dst)], check=True)


def load_cache(cache_dir):
    """normalized text -> (mp3 path, alignment)"""
    index = {}
    for meta in sorted(Path(cache_dir).glob("*.json")):
        mp3 = meta.with_suffix(".mp3")
        if not mp3.exists():
            continue
        data = json.loads(meta.read_text(encoding="utf-8"))
        index[normalize(data["text"])] = (mp3, data["alignment"])
    return index


def update(voice_lines_path, cache_dir, media_dir):
    """Returns (matched, missing) counts and rewrites voice_lines_path in place."""
    voice_lines_path, media_dir = Path(voice_lines_path), Path(media_dir)
    doc = json.loads(voice_lines_path.read_text(encoding="utf-8"))
    cache = load_cache(cache_dir)
    matched = missing = 0
    for line in doc["voiceLines"]:
        hit = cache.get(normalize(line["text"]))
        if hit is None:
            missing += 1
            continue
        mp3, alignment = hit
        name = line["id"] + ".m4a"
        convert_to_m4a(mp3, media_dir / name)
        line["file"] = name
        line["duration"] = audio_duration(media_dir / name)
        line["words"] = words_from_alignment(alignment)
        matched += 1
    voice_lines_path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return matched, missing


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--cache", default=str(DEFAULT_CACHE))
    ap.add_argument("--lines", default=str(DEFAULT_LINES))
    ap.add_argument("--media", default=str(DEFAULT_MEDIA))
    args = ap.parse_args()
    matched, missing = update(args.lines, args.cache, args.media)
    print("matched: %d, missing: %d" % (matched, missing))


if __name__ == "__main__":
    main()

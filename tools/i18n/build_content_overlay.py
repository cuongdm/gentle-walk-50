#!/usr/bin/env python3
"""Build iOS/App/Resources/Content/content.<lang>.json from the translations in docs/i18n/<lang>/.

Inputs: content.json (exercises, journeys, notifications, wins) and voice-*.json (coach lines).
With --cache, coach lines whose translated text has a render in that cache (same layout as
tools/voice/render_lines.py) get their recording: <line id>.<lang>.m4a in Media/Voice at -16 LUFS,
plus duration and word times for the captions. Lines without a render keep no file: the app speaks
them with the system voice in development, and the release check reports them.

Usage: python3 tools/i18n/build_content_overlay.py vi [--cache assets/voice/cache-vi-bella-v4]
Python 3.9, standard library + ffmpeg/ffprobe for recordings.
"""
import argparse
import glob
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "voice"))
import build_manifest  # noqa: E402  (shared conversion, alignment and text matching)

CONTENT = ROOT / "iOS" / "App" / "Resources" / "Content"
MEDIA = ROOT / "iOS" / "App" / "Resources" / "Media" / "Voice"


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("lang")
    ap.add_argument("--cache")
    args = ap.parse_args()
    src = ROOT / "docs" / "i18n" / args.lang
    content = json.load(open(src / "content.json", encoding="utf-8"))
    lines = {}
    for f in sorted(glob.glob(str(src / "voice-*.json"))):
        lines.update(json.load(open(f, encoding="utf-8")))
    english_ids = [v["id"] for v in json.load(open(CONTENT / "voice-lines.json", encoding="utf-8"))["voiceLines"]]
    cache = build_manifest.load_cache(args.cache) if args.cache else {}
    voice, recorded = {}, 0
    for line_id in english_ids:
        text = lines.get(line_id)
        if text is None:
            continue
        entry = {"text": text}
        hit = cache.get(build_manifest.normalize(text))
        if hit:
            mp3, alignment = hit
            name = f"{line_id}.{args.lang}.m4a"
            build_manifest.convert_to_m4a(mp3, MEDIA / name)
            entry.update(file=name, duration=build_manifest.audio_duration(MEDIA / name),
                         words=build_manifest.words_from_alignment(alignment))
            recorded += 1
        voice[line_id] = entry
    overlay = {
        "schemaVersion": 1,
        "language": args.lang,
        "exercises": content["exercises"],
        "journeys": content["journeys"],
        "voiceLines": voice,
        "notifications": content["notifications"],
        "wins": content["wins"],
    }
    out = CONTENT / f"content.{args.lang}.json"
    out.write_text(json.dumps(overlay, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    missing = [i for i in english_ids if i not in lines]
    print(f"{out.name}: {len(content['exercises'])} exercises, {len(content['journeys'])} journeys, "
          f"{len(voice)}/{len(english_ids)} coach lines ({recorded} recorded), "
          f"{len(content['notifications'])} notifications, {len(content['wins'])} wins")
    if missing:
        print("untranslated coach lines:", ", ".join(missing[:20]), "…" if len(missing) > 20 else "")


if __name__ == "__main__":
    main()

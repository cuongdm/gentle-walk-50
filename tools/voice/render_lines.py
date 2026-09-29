#!/usr/bin/env python3
"""Render voice lines with ElevenLabs into the shared cache, by line id.

Same voice, settings and cache key as tools/video/build_preview.py, so a line rendered once is never
paid for again. Then run tools/voice/build_manifest.py to attach the files to the app.

Usage:  python3 tools/voice/render_lines.py a2.open.1 a1.04 ...     (ids from voice-lines.json)
        python3 tools/voice/render_lines.py --dry-run a2.open.1 ...  (count characters, no calls)
The API key is read from ~/.config/elevenlabs/api_key and never printed. Python 3.9, stdlib only.
"""
import base64
import hashlib
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LINES = ROOT / "iOS" / "App" / "Resources" / "Content" / "voice-lines.json"
CACHE = ROOT / "assets" / "voice" / "cache"
# Bella (premade): the voice of every line already in the app (docs/video-skill-notes.md §4).
VOICE = {"voice_id": "hpp4J3VqNfWAUOO0d1Us", "model": "eleven_multilingual_v2",
         "settings": {"stability": 0.6, "similarity_boost": 0.75, "style": 0.15, "speed": 0.92}}


def body_for(text):
    return {"text": text, "model_id": VOICE["model"], "voice_settings": VOICE["settings"]}


def cache_key(text):
    """Identical to build_preview.py: sha1 of [voice_id, body], first 16 hex digits."""
    return hashlib.sha1(json.dumps([VOICE["voice_id"], body_for(text)], sort_keys=True).encode()).hexdigest()[:16]


def load_lines():
    data = json.load(open(LINES, encoding="utf-8"))
    items = data["voiceLines"]
    return {line["id"]: line["text"] for line in items}


def render(text, key):
    mp3, js = CACHE / f"{cache_key(text)}.mp3", CACHE / f"{cache_key(text)}.json"
    if mp3.exists() and js.exists():
        return False
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE['voice_id']}/with-timestamps?output_format=mp3_44100_128",
        data=json.dumps(body_for(text)).encode(), headers={"xi-api-key": key, "Content-Type": "application/json"})
    res = json.load(urllib.request.urlopen(req))
    mp3.write_bytes(base64.b64decode(res["audio_base64"]))
    json.dump({"text": text, "alignment": res["alignment"]}, open(js, "w"))
    return True


def main(argv):
    dry = "--dry-run" in argv
    ids = [a for a in argv[1:] if a != "--dry-run"]
    texts = load_lines()
    missing = [i for i in ids if i not in texts]
    if missing:
        print("unknown ids:", ", ".join(missing))
        return 2
    todo = [i for i in dict.fromkeys(ids) if not (CACHE / f"{cache_key(texts[i])}.mp3").exists()]
    print("lines: %d, to render: %d, characters: %d" % (len(set(ids)), len(todo), sum(len(texts[i]) for i in todo)))
    if dry or not todo:
        return 0
    CACHE.mkdir(parents=True, exist_ok=True)
    key = (Path.home() / ".config" / "elevenlabs" / "api_key").read_text().strip()
    for i in todo:
        render(texts[i], key)
        print("rendered", i)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

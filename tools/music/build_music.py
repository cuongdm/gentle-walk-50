#!/usr/bin/env python3
"""Bundle workout music (task 3.12): convert source tracks to AAC and write music.json.

Source files are named  <anything>-<kind>.mp3  where kind is walk, seated (chair moves) or stretch,
e.g. assets/music/test/lyria-3.5_1-walk.mp3. Each is loudness-normalised to -20 LUFS (background
level; the coach's voice ducks it further) and written to App/Resources/Media/Music/music-<kind>.m4a.

Usage:  python3 tools/music/build_music.py [--source DIR] [--style ID] [--note TEXT]
Python 3.9, standard library + ffmpeg on PATH.
"""
import argparse
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
KINDS = {"walk": "walk", "seated": "chair", "chair": "chair", "stretch": "stretch"}


def kind_of(path):
    match = re.search(r"-(walk|seated|chair|stretch)$", path.stem)
    return KINDS[match.group(1)] if match else None


def convert(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(src), "-af", "loudnorm=I=-20:TP=-2:LRA=11",
                    "-ar", "44100", "-c:a", "aac", "-b:a", "128k", str(dst)], check=True)


def build(source, style, note):
    out = ROOT / "App" / "Resources" / "Media" / "Music"
    tracks = []
    for src in sorted(Path(source).glob("*.mp3")):
        kind = kind_of(src)
        if not kind or any(t["kind"] == kind for t in tracks):
            continue
        name = "music-%s.m4a" % kind
        convert(src, out / name)
        tracks.append({"id": "music.%s" % kind, "style": style, "kind": kind, "file": name, "source": src.name})
    doc = {"schemaVersion": 1, "note": note, "tracks": tracks}
    (ROOT / "App" / "Resources" / "Content" / "music.json").write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    return tracks


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--source", default=str(ROOT / "assets" / "music" / "test"))
    ap.add_argument("--style", default="feelGood")
    ap.add_argument("--note", default="Test tracks (Lyria 3.5) for the prototype; replace with licensed music before release.")
    args = ap.parse_args()
    for t in build(args.source, args.style, args.note):
        print("%s ← %s" % (t["file"], t["source"]))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Extract every English text a translator needs into docs/i18n/source/*.json.

UI strings come from the compiler's .stringsdata (build with SWIFT_EMIT_LOC_STRINGS=YES) plus
Localizable.xcstrings and InfoPlist.xcstrings; content texts come from iOS/App/Resources/Content.
Usage: python3 tools/i18n/extract_sources.py <derived-data-dir>
"""
import glob
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "iOS" / "App"
CONTENT = APP / "Resources" / "Content"
OUT = ROOT / "docs" / "i18n" / "source"


# Third-party packages (RevenueCat, since 09/10/2026) emit their own debug-screen strings: not ours to translate.
THIRD_PARTY = ("/RevenueCat.build/", "/RevenueCatUI.build/", "/SourcePackages/")


def ui_strings(derived):
    keys = {}
    # Only the build products, not the package checkouts next to them (slow, and not app strings).
    root = Path(derived) / "Build" / "Intermediates.noindex"
    base = root if root.is_dir() else Path(derived)
    for f in glob.glob(f"{base}/**/*.stringsdata", recursive=True):
        if "Shortcuts" in f or "Tests.build" in f or any(part in f for part in THIRD_PARTY):
            continue
        source = Path(f).stem
        for table, entries in json.load(open(f)).get("tables", {}).items():
            for e in entries:
                item = keys.setdefault(e["key"], {"key": e["key"], "comment": e.get("comment", ""), "files": []})
                if source not in item["files"]:
                    item["files"].append(source)
    catalog = json.load(open(APP / "Localizable.xcstrings"))
    # Comments written in the catalog help the translator; keys only in the catalog are gone from code.
    for key, value in catalog["strings"].items():
        item = keys.get(key)
        if item is not None and value.get("comment") and not item["comment"]:
            item["comment"] = value["comment"]
    return sorted(keys.values(), key=lambda i: (i["files"][:1], i["key"]))


def main(argv):
    OUT.mkdir(parents=True, exist_ok=True)
    ui = ui_strings(argv[1])
    json.dump(ui, open(OUT / "ui.json", "w"), ensure_ascii=False, indent=1)
    info = json.load(open(APP / "InfoPlist.xcstrings"))["strings"]
    json.dump({k: v["localizations"]["en"]["stringUnit"]["value"] for k, v in info.items()},
              open(OUT / "infoplist.json", "w"), ensure_ascii=False, indent=1)
    ex = json.load(open(CONTENT / "exercises.json"))["exercises"]
    json.dump({e["id"]: {k: e[k] for k in ("name", "purpose", "tips", "easier", "harder") if e.get(k) is not None}
               | ({"limitNotes": {n["limit"]: n["text"] for n in e["limitNotes"]}} if e.get("limitNotes") else {})
               for e in ex}, open(OUT / "exercises.json", "w"), ensure_ascii=False, indent=1)
    js = json.load(open(CONTENT / "journeys.json"))["journeys"]
    json.dump({j["id"]: {k: j[k] for k in ("title", "subtitle", "summary") if j.get(k)}
               | {"stops": {s["id"]: {k: s[k] for k in ("name", "back", "coachLine") if s.get(k)} for s in j["stops"]}}
               for j in js}, open(OUT / "journeys.json", "w"), ensure_ascii=False, indent=1)
    json.dump({p["id"]: p["text"] for p in json.load(open(CONTENT / "notifications.json"))["phrases"]},
              open(OUT / "notifications.json", "w"), ensure_ascii=False, indent=1)
    json.dump({w["id"]: w["text"] for w in json.load(open(CONTENT / "wins.json"))["wins"]},
              open(OUT / "wins.json", "w"), ensure_ascii=False, indent=1)
    json.dump({v["id"]: v["text"] for v in json.load(open(CONTENT / "voice-lines.json"))["voiceLines"]},
              open(OUT / "voice-lines.json", "w"), ensure_ascii=False, indent=1)
    music = json.load(open(CONTENT / "music.json"))
    json.dump(music, open(OUT / "music.json", "w"), ensure_ascii=False, indent=1)
    for f in sorted(OUT.glob("*.json")):
        print(f.name, len(json.load(open(f))))


if __name__ == "__main__":
    main(sys.argv)

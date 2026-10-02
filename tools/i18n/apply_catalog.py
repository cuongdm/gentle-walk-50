#!/usr/bin/env python3
"""Put translations into the String Catalogs, and report what is missing.

Reads docs/i18n/source/ui.json (every key the code uses, from extract_sources.py) and
docs/i18n/<lang>/ui-*.json + infoplist.json (English key -> translation). Adds missing keys to
iOS/App/Localizable.xcstrings, writes the <lang> column, and checks that each translation keeps
the key's format specifiers. Usage: python3 tools/i18n/apply_catalog.py vi [--check]
"""
import glob
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "iOS" / "App"
SPEC = re.compile(r"%(?:\d+\$)?(?:lld|ld|d|@|f|\.\d+f|s)")


def specs(text):
    return sorted(re.sub(r"\d+\$", "", m) for m in SPEC.findall(text))


def load_translations(lang):
    out = {}
    for f in sorted(glob.glob(str(ROOT / "docs" / "i18n" / lang / "ui*.json"))):
        out.update(json.load(open(f, encoding="utf-8")))
    return out


def write_catalog(path, data):
    text = json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True, separators=(",", " : "))
    path.write_text(text + "\n", encoding="utf-8")


def main(argv):
    lang = argv[1]
    check_only = "--check" in argv
    keys = [item["key"] for item in json.load(open(ROOT / "docs" / "i18n" / "source" / "ui.json", encoding="utf-8"))]
    # Keys the compiler does not extract (both branches of a `?:`, the rest of a tuple): kept as manual.
    manual = json.load(open(ROOT / "docs" / "i18n" / "source" / "ui-manual.json", encoding="utf-8"))
    keys += [k for k in manual if k not in keys]
    texts = load_translations(lang)
    problems, missing = [], []
    catalog_path = APP / "Localizable.xcstrings"
    catalog = json.load(open(catalog_path, encoding="utf-8"))
    strings = catalog["strings"]
    for key in keys:
        entry = strings.setdefault(key, {})
        if key in manual:
            entry["extractionState"] = "manual"
        value = texts.get(key)
        if value is None:
            missing.append(key)
            continue
        if specs(value) != specs(key):
            problems.append(f"format specifiers differ: {key!r} -> {value!r}")
            continue
        entry.setdefault("localizations", {})[lang] = {"stringUnit": {"state": "translated", "value": value}}
    # Keys no longer in code (the source list comes from a fresh build) are removed.
    gone = [k for k in strings if k not in keys]
    for k in gone:
        del strings[k]
    if gone:
        print(f"removed {len(gone)} keys no longer in code")
    info_path = APP / "InfoPlist.xcstrings"
    info = json.load(open(info_path, encoding="utf-8"))
    info_texts = json.load(open(ROOT / "docs" / "i18n" / lang / "infoplist.json", encoding="utf-8"))
    for key, entry in info["strings"].items():
        if key in info_texts:
            entry.setdefault("localizations", {})[lang] = {"stringUnit": {"state": "translated", "value": info_texts[key]}}
        else:
            missing.append(f"InfoPlist:{key}")
    print(f"{lang}: {len(keys) - len(missing)} of {len(keys)} UI keys translated; {len(missing)} missing; {len(problems)} problems")
    for line in problems + [f"missing: {k!r}" for k in missing]:
        print("  " + line)
    if not check_only:
        write_catalog(catalog_path, catalog)
        write_catalog(info_path, info)
    return 1 if problems or missing else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

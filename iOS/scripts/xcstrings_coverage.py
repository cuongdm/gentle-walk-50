#!/usr/bin/env python3
"""Report untranslated or unreviewed entries in a String Catalog.

Usage:  python3 iOS/scripts/xcstrings_coverage.py iOS/App/Localizable.xcstrings en[,es,...]
Prints "<locale> missing: N needs_review/new: M" per locale; exit 1 if anything is open.
The source language counts as covered when its text lives in the key. Python 3.9, stdlib only.
"""
import json
import sys


def states_for(loc):
    states = []
    if "stringUnit" in loc:
        states.append(loc["stringUnit"].get("state"))
    for variation in loc.get("variations", {}).values():  # {"plural": {"one": {"stringUnit": ...}}}
        for case in variation.values():
            states.append(case.get("stringUnit", {}).get("state"))
    return [s for s in states if s]


def main(argv):
    if len(argv) != 3:
        print(__doc__)
        return 2
    path, locales = argv[1], argv[2].split(",")
    catalog = json.load(open(path, encoding="utf-8"))
    source = catalog.get("sourceLanguage")
    missing = {l: [] for l in locales}
    review = {l: [] for l in locales}
    for key, entry in catalog.get("strings", {}).items():
        if entry.get("shouldTranslate") is False:
            continue
        localizations = entry.get("localizations", {})
        for l in locales:
            if l == source and l not in localizations:
                continue
            states = states_for(localizations.get(l, {}))
            if not states:
                missing[l].append(key)
            elif any(s != "translated" for s in states):
                review[l].append(key)
    for l in locales:
        print("%s missing: %d needs_review/new: %d" % (l, len(missing[l]), len(review[l])))
        for key in (missing[l] + review[l])[:20]:
            print("  -", key)
    return 1 if any(missing.values()) or any(review.values()) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

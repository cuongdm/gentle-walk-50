#!/usr/bin/env python3
"""Lint every user-facing string for banned words, medical claims and other platform names.

Rules (app-context.md "Tone & copy rules", App Review 1.4.1 and 2.3.10):
  - banned words: read from the "- Banned:" line of app-context.md, so the list has one owner;
  - medical claims: cure, treat, prevent falls, reduce … risk, arthritis;
  - other platforms: Android, Google Play, APK.

Scans iOS/App/*.xcstrings (every localized value, or the key when the source text lives in the key)
and iOS/App/Resources/Content/*.json (every string except ids, file names and enum values).

Usage:  python3 tools/lint/copy_lint.py [paths ...]      → prints findings, then "N findings"; exit 1 if N > 0
Python 3.9, standard library only.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP_CONTEXT = ROOT / "app-context.md"
IOS_APP = ROOT / "iOS" / "App"
DEFAULT_PATHS = sorted(IOS_APP.glob("*.xcstrings")) + sorted((IOS_APP / "Resources" / "Content").glob("*.json"))

MEDICAL = [
    r"\bcure[sd]?\b",
    r"\btreat(?:s|ed|ing|ment|ments)?\b",
    r"\bprevent\w*\s+(?:a\s+)?falls?\b",
    r"\breduc\w*\b[^.]{0,40}\brisk\b",
    r"\barthritis\b",
]
PLATFORMS = [r"\bandroid\b", r"\bgoogle play\b", r"\bapk\b"]

# JSON keys whose values are identifiers or enums, not copy.
NON_COPY_KEYS = {"id", "file", "kind", "counting", "videoFile", "source", "journeyID", "line",
                 "exerciseID", "hiddenFor", "easierFor", "words", "schemaVersion"}


def banned_terms(app_context_path):
    """Terms from the '- Banned: a, b, c; …' line, up to the first ';'."""
    for line in Path(app_context_path).read_text(encoding="utf-8").splitlines():
        if line.startswith("- Banned:"):
            head = line[len("- Banned:"):].split(";")[0]
            return [t.strip().lower() for t in head.split(",") if t.strip()]
    raise ValueError("no '- Banned:' line in %s" % app_context_path)


def patterns(terms):
    word_rules = [(t, re.compile(r"\b" + re.escape(t) + r"(?:s|es|ed|ing)?\b", re.I)) for t in terms]
    other = [(p, re.compile(p, re.I)) for p in MEDICAL + PLATFORMS]
    return word_rules + other


def find(texts, terms):
    """texts: iterable of (where, text). Returns [(where, rule, text)]."""
    rules = patterns(terms)
    findings = []
    for where, text in texts:
        for rule, rx in rules:
            if rx.search(text):
                findings.append((where, rule, text))
    return findings


def _walk_json(node, where):
    if isinstance(node, dict):
        label = node.get("id", where)
        for key, value in node.items():
            if key in NON_COPY_KEYS:
                continue
            yield from _walk_json(value, "%s.%s" % (label, key))
    elif isinstance(node, list):
        for item in node:
            yield from _walk_json(item, where)
    elif isinstance(node, str):
        yield where, node


def _walk_xcstrings(catalog, name):
    for key, entry in catalog.get("strings", {}).items():
        localizations = entry.get("localizations", {})
        values = []
        for locale, loc in localizations.items():
            if "stringUnit" in loc:
                values.append(loc["stringUnit"].get("value", ""))
            for variation in loc.get("variations", {}).values():
                for case in variation.values():
                    values.append(case.get("stringUnit", {}).get("value", ""))
        if catalog.get("sourceLanguage") not in localizations:
            values.append(key)  # source text lives in the key
        for value in values:
            yield "%s:%s" % (name, key), value


def collect(paths):
    for path in map(Path, paths):
        data = json.loads(path.read_text(encoding="utf-8"))
        if path.suffix == ".xcstrings":
            yield from _walk_xcstrings(data, path.name)
        else:
            yield from _walk_json(data, path.name)


def main(argv):
    paths = argv[1:] or DEFAULT_PATHS
    findings = find(collect(paths), banned_terms(APP_CONTEXT))
    for where, rule, text in findings:
        print("%s  [%s]  %s" % (where, rule, text))
    print("%d findings" % len(findings))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

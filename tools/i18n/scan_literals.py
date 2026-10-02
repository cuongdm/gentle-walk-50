#!/usr/bin/env python3
"""Find English UI text in the app's Swift code that is not in the String Catalog.

The compiler does not extract every localizable literal (e.g. both branches of `cond ? "A" : "B"`
passed as LocalizedStringResource); those still translate at run time if the catalog has the key.
This lists candidate literals (looks like words, not an identifier, symbol, file or key) that are
missing from iOS/App/Localizable.xcstrings, with file:line, for review.
Usage: python3 tools/i18n/scan_literals.py [--json out.json]
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "iOS" / "App"
LITERAL = re.compile(r'(?<![\\#])"((?:[^"\\\n]|\\.)*)"')
SKIP_LINE = re.compile(r"systemImage|systemName|forKey|forResource|withExtension|Logger|logger|subsystem|identifier|"
                       r"#Predicate|accessibilityIdentifier|UserDefaults|defaults\.|URL\(|named:|Notification\.Name|"
                       r"^\s*//|^\s*///|fatalError|precondition|assert|print\(|case \w+ = \"|verbatim: \"[^\"]*\\\(|"
                       r"\.font\(|Color\(|art:|\.rawValue|hasPrefix|hasSuffix|split|replacingOccurrences|"
                       r"dateFormat|Locale\(|TimeZone\(|keyPath|presetID|exerciseID|\"jr\.|\"pc\.|\"st\.|\"mv\.|\"wk\.|\"bl\.")


def looks_like_text(s):
    if "\\(" in s or len(s) < 2 or not re.search(r"[A-Za-z]", s):
        return False
    if re.fullmatch(r"[a-z][A-Za-z0-9_.\-]*", s):  # identifiers, keys, ids
        return False
    if re.fullmatch(r"[\w.\-/]+\.(m4a|mp4|json|png|jpg|caf|mp3|storekit|plist)", s):
        return False
    return bool(re.search(r"[A-Z]", s[:1]) or " " in s)


def main(argv):
    catalog = set(json.load(open(APP / "Localizable.xcstrings", encoding="utf-8"))["strings"])
    found = {}
    for path in sorted(APP.rglob("*.swift")):
        if "/Debug/" in str(path):
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if SKIP_LINE.search(line):
                continue
            for m in LITERAL.finditer(line):
                text = m.group(1).replace('\\"', '"')
                if looks_like_text(text) and text not in catalog:
                    found.setdefault(text, []).append(f"{path.relative_to(APP)}:{number}")
    for text, where in sorted(found.items(), key=lambda kv: kv[1][0]):
        print(f"{text!r}  ← {', '.join(where[:3])}")
    print(f"{len(found)} candidates", file=sys.stderr)
    if "--json" in argv:
        json.dump({k: v for k, v in found.items()}, open(argv[argv.index("--json") + 1], "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main(sys.argv)

#!/usr/bin/env python3
"""Build the app's content icons from tools/art/icons-manifest.json (stdlib only).

Sources
- Phosphor Bold + Fill SVGs from the npm tarball of @phosphor-icons/core, PINNED below and checked
  against the registry's sha512 integrity before anything is read (MIT; licence text shipped in the app).
- Custom glyphs (body regions, limitations, stretch, grandkids) from assets/icons/custom/*.svg, drawn on
  Phosphor's grid and Bold weight by tools/art/draw_custom_icons.py.

Output (everything is derived, never edit by hand)
- iOS/App/Assets.xcassets/Icons/                        folder with "provides-namespace": true
    <asset>.imageset/<asset>.svg + Contents.json        Bold = normal state
    <asset>-fill.imageset/<asset>-fill.svg + ...        Fill = selected state
  Each Contents.json sets "preserves-vector-representation" and "template-rendering-intent": "template",
  so SwiftUI tints them with foregroundStyle and they stay sharp at any Dynamic Type size.
- iOS/App/Design/AppIcon.swift                          enum AppIcon (one case per concept)
- iOS/App/Resources/Licenses/Phosphor-MIT.txt           the package's LICENSE, verbatim

    python3 tools/art/build_icons.py            # write / refresh everything (idempotent)
    python3 tools/art/build_icons.py --check    # exit 1 if anything is missing, stale or extra

The tarball is cached in ~/.cache/good-footing-icons/ (re-verified on every run). To move to a new
Phosphor version: change PHOSPHOR_* (version, url, integrity from `npm view @phosphor-icons/core dist`)
and the "phosphor" block of the manifest together, run, and look at the preview sheet
docs/design/research-2026-10-08/icon-sources/app-icons-preview.html.
"""
import argparse
import base64
import hashlib
import io
import json
import re
import sys
import tarfile
import textwrap
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "tools/art/icons-manifest.json"
CUSTOM = ROOT / "assets/icons/custom"
CATALOG = ROOT / "iOS/App/Assets.xcassets/Icons"
SWIFT = ROOT / "iOS/App/Design/AppIcon.swift"
LICENSE = ROOT / "iOS/App/Resources/Licenses/Phosphor-MIT.txt"
CACHE = Path.home() / ".cache/good-footing-icons"

# Pinned Phosphor release (registry.npmjs.org metadata, read 08/10/2026).
PHOSPHOR_VERSION = "2.1.1"
PHOSPHOR_TARBALL = "https://registry.npmjs.org/@phosphor-icons/core/-/core-2.1.1.tgz"
PHOSPHOR_INTEGRITY = "sha512-v4ARvrip4qBCImOE5rmPUylOEK4iiED9ZyKjcvzuezqMaiRASCHKcRIuvvxL/twvLpkfnEODCOJp5dM4eZilxQ=="

TINTS = ("sap", "sky", "ochre", "sienna", "danger")
ASSET_NAME = re.compile(r"^[a-z][a-z0-9-]*$")


def imageset_contents(filename):
    return json.dumps({
        "images": [{"filename": filename, "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": True, "template-rendering-intent": "template"},
    }, indent=2) + "\n"


FOLDER_CONTENTS = json.dumps({
    "info": {"author": "xcode", "version": 1},
    "properties": {"provides-namespace": True},
}, indent=2) + "\n"


# ---------- sources -------------------------------------------------------------------------------
def phosphor_tarball():
    """Bytes of the pinned tarball, from cache or the registry, always integrity-checked."""
    path = CACHE / f"phosphor-core-{PHOSPHOR_VERSION}.tgz"
    data = path.read_bytes() if path.exists() else None
    if data is None or not integrity_ok(data):
        with urllib.request.urlopen(PHOSPHOR_TARBALL, timeout=60) as response:
            data = response.read()
        if not integrity_ok(data):
            sys.exit(f"integrity mismatch for {PHOSPHOR_TARBALL}; expected {PHOSPHOR_INTEGRITY}")
        CACHE.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    return data


def integrity_ok(data):
    algo, _, expected = PHOSPHOR_INTEGRITY.partition("-")
    return base64.b64encode(hashlib.new(algo, data).digest()).decode() == expected


class Phosphor:
    """Reads single members of the tarball in memory (nothing is extracted to disk)."""

    def __init__(self, data):
        self.tar = tarfile.open(fileobj=io.BytesIO(data), mode="r:gz")
        self.names = set(self.tar.getnames())
        version = json.loads(self.read("package/package.json"))["version"]
        if version != PHOSPHOR_VERSION:
            sys.exit(f"tarball holds {version}, expected {PHOSPHOR_VERSION}")

    def read(self, member):
        if member not in self.names:
            raise KeyError(member)
        return self.tar.extractfile(member).read().decode("utf-8")

    def svg(self, glyph, weight):
        return self.read(f"package/assets/{weight}/{glyph}-{weight}.svg")

    def license(self):
        return self.read("package/LICENSE")


def normalise_svg(text):
    """Explicit black instead of currentColor (template rendering only uses alpha), one trailing newline."""
    text = text.replace('fill="currentColor"', 'fill="#000000"').strip() + "\n"
    if "currentColor" in text or "<style" in text or "<mask" in text:
        raise ValueError("unsupported SVG feature for the asset catalog")
    return text


# ---------- manifest ------------------------------------------------------------------------------
def load_manifest():
    manifest = json.loads(MANIFEST.read_text())
    pin = manifest["phosphor"]
    if (pin["version"], pin["tarball"], pin["integrity"]) != (PHOSPHOR_VERSION, PHOSPHOR_TARBALL, PHOSPHOR_INTEGRITY):
        sys.exit("manifest 'phosphor' block and the pin in build_icons.py disagree")
    icons = manifest["icons"]
    problems = []
    seen_assets, glyph_owners = set(), {}
    for icon in icons:
        asset = icon["asset"]
        if not ASSET_NAME.match(asset) or asset.endswith("-fill"):
            problems.append(f"bad asset name {asset!r}")
        if asset in seen_assets:
            problems.append(f"asset {asset!r} used twice")
        seen_assets.add(asset)
        if icon["source"] not in ("phosphor", "custom"):
            problems.append(f"{asset}: unknown source {icon['source']!r}")
        if "layers" in icon and (icon["layers"] != ["base", "mark"] or icon["source"] != "custom"):
            problems.append(f"{asset}: layers must be [\"base\", \"mark\"] on a custom icon")
        if icon["tint"] not in TINTS:
            problems.append(f"{asset}: unknown tint {icon['tint']!r}")
        glyph_owners.setdefault(f"{icon['source']}:{icon['glyph']}", []).append(icon["concept"])
    shared = manifest.get("sharedGlyphs", {})
    for glyph, concepts in glyph_owners.items():
        if len(concepts) > 1 and sorted(concepts) != sorted(shared.get(glyph, [])):
            problems.append(f"glyph {glyph} carries several meanings {concepts}; list it in sharedGlyphs or pick another")
    if problems:
        sys.exit("manifest problems:\n  " + "\n  ".join(problems))
    return manifest


# ---------- outputs -------------------------------------------------------------------------------
def camel(asset):
    head, *rest = asset.split("-")
    words = [w.upper() if w in ("tv",) else w.capitalize() for w in rest]
    return head + "".join(words)


def swift_string(text):
    return text.replace("\\", "\\\\").replace('"', '\\"')


def render_swift(manifest):
    icons = manifest["icons"]
    pin = manifest["phosphor"]
    lines = [
        "// Generated by tools/art/build_icons.py from tools/art/icons-manifest.json. Do not edit by hand:",
        "// change the manifest (or assets/icons/custom/) and run `python3 tools/art/build_icons.py`.",
        "",
        "import SwiftUI",
        "",
        "/// Every content icon in the app: one case per meaning, drawn from the asset catalog folder `Icons`.",
        "///",
        "/// **One symbol, one meaning.** A glyph stands for exactly one idea across the whole app (a chair is",
        "/// always \"chair moves / a chair\", a bell is always \"reminders\"), so she learns each picture once.",
        "/// Need a new idea? Add a concept to the manifest with its own glyph; never reuse a case because it",
        "/// \"looks close\". `AppIconTests` fails when two cases share a glyph outside `sharedGlyphs`.",
        "///",
        "/// Rules that come with it (`icon-va-chong-nham-chan.md` §2, `nguon-icon.md` §4): an icon always sits",
        "/// next to its text label and is hidden from VoiceOver (the label carries the meaning); it sits on the",
        "/// watercolour wash chip; `image` (Phosphor Bold or a custom glyph of the same weight) is the normal",
        "/// state, `selectedImage` (Fill) the selected one. System controls (chevron, checkmark, xmark, plus,",
        "/// play/pause) stay SF Symbols. Glyph colour comes from the case's `tint` role, never sky or sun as",
        "/// a stroke colour.",
        "///",
        f"/// Sources: Phosphor Icons {pin['version']} (MIT, `Resources/Licenses/Phosphor-MIT.txt`) and",
        "/// custom glyphs in `assets/icons/custom/`. The raw value is the image set name inside `Icons/`.",
        "enum AppIcon: String, CaseIterable, Sendable {",
    ]
    for icon in icons:
        src = "Phosphor" if icon["source"] == "phosphor" else "Custom"
        replaces = f" Replaces SF `{icon['replaces']}`." if icon.get("replaces") else ""
        doc = f"{icon['meaning']}. {src} `{icon['glyph']}`, tint {icon['tint']}.{replaces}"
        lines += textwrap.wrap(doc, width=112, initial_indent="    /// ", subsequent_indent="    /// ",
                               break_on_hyphens=False)
        name = camel(icon["asset"])
        lines.append(f"    case {name}" if name == icon["asset"] else f'    case {name} = "{icon["asset"]}"')
    lines += [
        "",
        "    /// Colour role of the glyph (and its wash). Mapped to Palette colours by the view layer.",
        "    enum Tint: String, Sendable {",
        "        case sap, sky, ochre, sienna, danger",
        "    }",
        "",
        "    /// Namespaced asset catalog folder holding every icon.",
        '    static let folder = "Icons"',
        "",
        "    /// Catalog name of the normal-state image (Bold).",
        '    var assetName: String { "\\(Self.folder)/\\(rawValue)" }',
        "",
        "    /// Catalog name of the selected-state image (Fill).",
        '    var selectedAssetName: String { "\\(Self.folder)/\\(rawValue)-fill" }',
        "",
        "    /// Normal state, as a template so `foregroundStyle` colours it.",
        "    var image: Image { Image(assetName).renderingMode(.template) }",
        "",
        "    /// Selected state (Fill twin of the same glyph), as a template.",
        "    var selectedImage: Image { Image(selectedAssetName).renderingMode(.template) }",
        "",
        "    /// `selectedImage` when selected, otherwise `image`.",
        "    func image(selected: Bool) -> Image { selected ? selectedImage : image }",
        "",
        "    /// The two images of a two-tone icon: the figure and the meaning mark drawn over it.",
        "    enum Layer: String, Sendable {",
        "        case base, mark",
        "    }",
        "",
        "    /// Catalog name of one layer of a two-tone icon, or nil for one-colour icons. The base has a Fill",
        "    /// twin for the selected state (solid head); the mark is the same in both states.",
        "    func layerAssetName(_ layer: Layer, selected: Bool = false) -> String? {",
        "        guard isLayered else { return nil }",
        "        return switch layer {",
        '        case .base: "\\(Self.folder)/\\(rawValue)-base\\(selected ? "-fill" : "")"',
        '        case .mark: "\\(Self.folder)/\\(rawValue)-mark"',
        "        }",
        "    }",
        "",
        "    /// Source glyph, `phosphor:<name>` or `custom:<name>`: two cases with the same glyph would mean",
        "    /// one picture carrying two meanings.",
        "    var glyph: String {",
        "        switch self {",
    ]
    for icon in icons:
        lines.append(f'        case .{camel(icon["asset"])}: "{icon["source"]}:{icon["glyph"]}"')
    layered = ["." + camel(i["asset"]) for i in icons if i.get("layers")]
    lines += ["        }", "    }", "",
              "    /// Two-tone icons (body regions and limitations): show them with `LayeredIcon`; their `image` is",
              "    /// only a single-colour fallback.",
              "    var isLayered: Bool {", "        switch self {"]
    lines += textwrap.wrap(", ".join(layered) + ": true", width=118, initial_indent="        case ",
                           subsequent_indent="             ", break_on_hyphens=False)
    lines += ["        default: false"]
    lines += ["        }", "    }", "", "    /// Colour role of this icon (`icon-va-chong-nham-chan.md`, icon vocabulary).",
              "    var tint: Tint {", "        switch self {"]
    by_tint = {}
    for icon in icons:
        by_tint.setdefault(icon["tint"], []).append("." + camel(icon["asset"]))
    for tint in TINTS:
        if tint in by_tint:
            cases = by_tint[tint]
            chunks, line = [], "        case "
            for i, case in enumerate(cases):
                piece = case + (", " if i < len(cases) - 1 else f": .{tint}")
                if len(line) + len(piece) > 118:
                    chunks.append(line.rstrip())
                    line = "             "
                line += piece
            chunks.append(line)
            lines += chunks
    lines += ["        }", "    }", ""]
    shared = manifest.get("sharedGlyphs", {})
    lines.append("    /// Glyphs deliberately shared by several concepts (`sharedGlyphs` in the manifest).")
    if shared:
        lines.append("    static let sharedGlyphs: [String: Set<AppIcon>] = [")
        for glyph, concepts in shared.items():
            assets = [i["asset"] for i in icons if i["concept"] in concepts]
            lines.append(f'        "{glyph}": [{", ".join("." + camel(a) for a in assets)}],')
        lines.append("    ]")
    else:
        lines.append("    static let sharedGlyphs: [String: Set<AppIcon>] = [:]")
    lines.append("}")
    lines.append(LAYERED_ICON_VIEW)
    return "\n".join(lines) + "\n"


LAYERED_ICON_VIEW = """
/// Draws an `AppIcon` in two colours, like the Claude Design sore-spot mock: the figure (`base` layer,
/// usually ink at about 55 %) and the meaning mark (`mark` layer: the sore spot, the clock, the swirl,
/// the "no" badge) in solid sienna, stacked from two template images so each takes its own colour.
/// Use it for the body and limitation icons, which do not read in one colour at 20 pt, e.g.
/// `LayeredIcon(icon: .bodyKnees, baseColor: Palette.text.opacity(0.55), markColor: Palette.accent)`.
/// A one-colour icon renders whole in `markColor`. The view fills its frame (`scaledToFit`): size it
/// with `.frame`. Decorative: hidden from VoiceOver, the text label beside it carries the meaning.
struct LayeredIcon: View {
    let icon: AppIcon
    let baseColor: Color
    let markColor: Color
    var selected = false

    var body: some View {
        ZStack {
            if let base = icon.layerAssetName(.base, selected: selected), let mark = icon.layerAssetName(.mark) {
                layer(base).foregroundStyle(baseColor)
                layer(mark).foregroundStyle(markColor)
            } else {
                layer(selected ? icon.selectedAssetName : icon.assetName).foregroundStyle(markColor)
            }
        }
        .accessibilityHidden(true)
    }

    private func layer(_ name: String) -> some View {
        Image(name).renderingMode(.template).resizable().scaledToFit()
    }
}"""


LAYER_FILES = ("-base", "-base-fill", "-mark")   # extra images of a two-tone ("layers") icon


def custom_suffixes(icon):
    """Image suffixes a custom icon ships: single-colour Bold/Fill, plus the layers when two-tone."""
    return ("", "-fill") + (LAYER_FILES if icon.get("layers") else ())


def expected_files(manifest, phosphor):
    """Every derived file, path -> text."""
    files = {CATALOG / "Contents.json": FOLDER_CONTENTS}
    for icon in manifest["icons"]:
        asset = icon["asset"]
        if icon["source"] == "phosphor":
            sources = {"": phosphor.svg(icon["glyph"], "bold"), "-fill": phosphor.svg(icon["glyph"], "fill")}
        else:
            sources = {sfx: (CUSTOM / f"{icon['glyph']}{sfx}.svg").read_text() for sfx in custom_suffixes(icon)}
        for suffix, svg in sources.items():
            name = asset + suffix
            folder = CATALOG / f"{name}.imageset"
            files[folder / f"{name}.svg"] = normalise_svg(svg)
            files[folder / "Contents.json"] = imageset_contents(f"{name}.svg")
    files[SWIFT] = render_swift(manifest)
    files[LICENSE] = phosphor.license()
    return files


def stray_files(expected):
    """Files inside Icons/ that the manifest no longer produces."""
    if not CATALOG.exists():
        return []
    return sorted(p for p in CATALOG.rglob("*") if p.is_file() and p not in expected and p.name != ".DS_Store")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="exit 1 if outputs are missing or stale")
    args = parser.parse_args()

    manifest = load_manifest()
    missing_custom = [f"{i['glyph']}{s}.svg" for i in manifest["icons"] if i["source"] == "custom"
                      for s in custom_suffixes(i) if not (CUSTOM / f"{i['glyph']}{s}.svg").exists()]
    if missing_custom:
        sys.exit("missing custom sources in assets/icons/custom: " + ", ".join(missing_custom))
    phosphor = Phosphor(phosphor_tarball())
    expected = expected_files(manifest, phosphor)
    stale = [p for p, text in expected.items() if not p.exists() or p.read_bytes() != text.encode()]
    extra = stray_files(expected)

    counts = (f"{len(manifest['icons'])} concepts "
              f"({sum(i['source'] == 'phosphor' for i in manifest['icons'])} Phosphor {PHOSPHOR_VERSION}, "
              f"{sum(i['source'] == 'custom' for i in manifest['icons'])} custom)")
    if args.check:
        for p in stale:
            print(f"stale or missing: {p.relative_to(ROOT)}")
        for p in extra:
            print(f"not in manifest:  {p.relative_to(ROOT)}")
        if stale or extra:
            sys.exit(f"icons out of date ({len(stale)} stale, {len(extra)} extra): run python3 tools/art/build_icons.py")
        print(f"icons up to date: {counts}")
        return

    for p in stale:
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(expected[p].encode())  # bytes: keeps the licence text exactly as shipped
    for p in extra:
        p.unlink()
    for folder in sorted({p.parent for p in extra}, reverse=True):
        if folder.exists() and not any(folder.iterdir()):
            folder.rmdir()
    print(f"{counts}: {len(stale)} file(s) written, {len(extra)} removed")


if __name__ == "__main__":
    main()

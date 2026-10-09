#!/usr/bin/env python3
"""Copy raw simulator captures into the appstore-mockup input layout.

    appstore/input/iPhone/en/NN-slug.png + captions.txt
    appstore/input/iPad/en/NN-slug.png   + captions.txt

Sources are the git-ignored captures made with iOS/scripts/capture_states.sh
(see appstore/README.md): docs/release/1.0/shots (iPhone 17 Pro Max) and
docs/release/1.0/shots-ipad (iPad Pro 13-inch).

appstore/captions.txt holds one block per slug ("## 03-voice" -> slug "voice"). Each device
has its own gallery below; files and caption blocks are renumbered per device, so both
galleries read 01, 02, 03… with no gaps.

iPad captures get two pieces of system chrome painted over with the colour next to them,
because neither is part of the app and both look like debug noise in a store image:
  - the status-bar date, which follows the simulator's own language (not the app's);
  - the bottom-right resize grabber that iPadOS shows in windowed-apps multitasking.
The app's own pixels are never touched. Needs Pillow.

Usage: python3 appstore/prepare-mockup-inputs.py
"""
import pathlib
import re
import shutil
import sys

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parents[1]
CAPTIONS = ROOT / "appstore" / "captions.txt"
INPUT = ROOT / "appstore" / "input"
LANG = "en"

# Gallery order per device: (slug, -ScreenshotMode state). On iPad the welcome screen is a
# narrow column over an empty page, so Today (fuller on a big screen) carries the hero caption.
GALLERIES = {
    "iPhone": [
        ("hero", "onboarding-welcome"),
        ("today", "today-goal-line"),
        ("voice", "walk-player"),
        ("chair", "chair-player"),
        ("plan", "program"),
        ("results", "progress-results"),
        ("journey", "journey"),
    ],
    "iPad": [
        ("hero", "today-goal-line"),
        ("voice", "walk-player"),
        ("chair", "chair-player"),
        ("plan", "program"),
        ("results", "progress-results"),
        ("journey", "journey"),
    ],
}
SOURCES = {
    "iPhone": ROOT / "docs" / "release" / "1.0" / "shots",
    "iPad": ROOT / "docs" / "release" / "1.0" / "shots-ipad",
}
EXPECTED_SIZE = {"iPhone": (1320, 2868), "iPad": (2064, 2752)}

# iPad Pro 13" pixel boxes (left, top, right, bottom) and the point whose colour fills each box.
IPAD_MASKS = [
    ((118, 12, 292, 56), (300, 33)),          # status-bar date after "9:41"
    ((1998, 2686, 2064, 2752), (1990, 2680)),  # windowed-apps resize grabber
]


def caption_blocks() -> dict:
    """slug -> the block's body lines (title/subtitle), from appstore/captions.txt."""
    blocks, slug = {}, None
    for line in CAPTIONS.read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            slug = re.sub(r"^\d+-", "", line[3:].strip())
            blocks[slug] = []
        elif slug and line.strip():
            blocks[slug].append(line)
    return blocks


def mask_ipad_chrome(image: Image.Image) -> Image.Image:
    image = image.convert("RGB")
    draw = ImageDraw.Draw(image)
    for box, sample in IPAD_MASKS:
        draw.rectangle(box, fill=image.getpixel(sample))
    return image


def main() -> int:
    blocks = caption_blocks()
    problems = []
    for device, gallery in GALLERIES.items():
        out = INPUT / device / LANG
        if out.exists():
            shutil.rmtree(out)
        out.mkdir(parents=True)
        captions = [f"# Generated from appstore/captions.txt for {device} by prepare-mockup-inputs.py"]
        for number, (slug, state) in enumerate(gallery, start=1):
            stem = f"{number:02d}-{slug}"
            if slug not in blocks:
                problems.append(f"{device}: no caption block for '{slug}' in appstore/captions.txt")
                continue
            captions += ["", f"## {stem}", *blocks[slug]]
            src = SOURCES[device] / f"{state}.png"
            if not src.is_file():
                problems.append(f"{device}: missing capture {src.relative_to(ROOT)}")
                continue
            image = Image.open(src)
            if image.size != EXPECTED_SIZE[device]:
                problems.append(f"{device}: {src.name} is {image.size}, expected {EXPECTED_SIZE[device]}")
                continue
            if device == "iPad":
                image = mask_ipad_chrome(image)
            image.save(out / f"{stem}.png")
        (out / "captions.txt").write_text("\n".join(captions) + "\n", encoding="utf-8")
        print(f"{out.relative_to(ROOT)}: {len(list(out.glob('*.png')))} screenshots")

    for problem in problems:
        print("  !", problem)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())

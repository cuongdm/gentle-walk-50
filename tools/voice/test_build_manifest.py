"""Tests for build_manifest.py — run: python3 -m unittest tools/voice/test_build_manifest.py"""
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_manifest as bm  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
CACHE = ROOT / "assets" / "voice" / "cache"


class WordsFromAlignmentTests(unittest.TestCase):
    def test_groups_characters_into_words_with_times(self):
        al = {"characters": list("Hi, you."),
              "character_start_times_seconds": [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7],
              "character_end_times_seconds": [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]}
        self.assertEqual(bm.words_from_alignment(al), [
            {"word": "Hi,", "start": 0.0, "end": 0.3},
            {"word": "you.", "start": 0.4, "end": 0.8},
        ])


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        sample = sorted(CACHE.glob("*.json"))[0]
        self.cache = self.tmp / "cache"
        self.cache.mkdir()
        for ext in (".json", ".mp3"):
            shutil.copy(sample.with_suffix(ext), self.cache / (sample.stem + ext))
        self.text = json.loads(sample.read_text(encoding="utf-8"))["text"]
        self.lines = self.tmp / "voice-lines.json"
        self.lines.write_text(json.dumps({"schemaVersion": 1, "voiceLines": [
            {"id": "a.match", "text": self.text},
            {"id": "a.miss", "text": "No audio exists for this line."},
        ]}), encoding="utf-8")
        self.media = self.tmp / "Voice"

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def test_matches_by_text_and_writes_media_fields(self):
        matched, missing = bm.update(self.lines, self.cache, self.media)
        self.assertEqual((matched, missing), (1, 1))
        lines = {l["id"]: l for l in json.loads(self.lines.read_text(encoding="utf-8"))["voiceLines"]}
        hit = lines["a.match"]
        self.assertEqual(hit["file"], "a.match.m4a")
        self.assertGreater(hit["duration"], 0.5)
        self.assertEqual(hit["words"][0]["word"], self.text.split()[0])
        self.assertTrue((self.media / "a.match.m4a").stat().st_size > 1000)
        self.assertNotIn("file", lines["a.miss"])

    def test_text_match_ignores_curly_quotes_and_spacing(self):
        self.assertEqual(bm.normalize("It’s  fine…"), bm.normalize("It's fine..."))


if __name__ == "__main__":
    unittest.main()

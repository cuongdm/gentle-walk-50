"""Tests for copy_lint.py — run: python3 -m unittest tools/lint/test_copy_lint.py"""
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import copy_lint as cl  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]


class BannedTermsTests(unittest.TestCase):
    def test_reads_banned_words_from_app_context(self):
        terms = cl.banned_terms(ROOT / "app-context.md")
        for word in ("lazy", "senior", "burn", "before/after", "tone up"):
            self.assertIn(word, terms)


class FindTests(unittest.TestCase):
    def setUp(self):
        self.terms = cl.banned_terms(ROOT / "app-context.md")

    def test_flags_banned_medical_and_platform_words(self):
        texts = [
            ("a", "Great for seniors."),
            ("b", "Burn more calories today."),
            ("c", "This will reduce your risk of falls."),
            ("d", "Also on Android."),
        ]
        findings = cl.find(texts, self.terms)
        self.assertEqual(sorted(f[0] for f in findings), ["a", "b", "c", "d"])

    def test_clean_copy_has_no_findings(self):
        texts = [("x", "A gentle walk at your pace. Stretch to a gentle pull, never to pain.")]
        self.assertEqual(cl.find(texts, self.terms), [])

    def test_whole_words_only(self):
        # "fat" must not match "fatigue", "burn" must not match "Burnham"
        self.assertEqual(cl.find([("y", "Fatigue is normal. Walk past Burnham Park.")], self.terms), [])


class CollectTests(unittest.TestCase):
    def test_collects_texts_from_json_and_xcstrings(self):
        tmp = Path(tempfile.mkdtemp())
        try:
            (tmp / "c.json").write_text(json.dumps({"voiceLines": [{"id": "a1", "text": "Hello there."}]}), encoding="utf-8")
            (tmp / "L.xcstrings").write_text(json.dumps({"sourceLanguage": "en", "strings": {
                "Hi": {"localizations": {"en": {"stringUnit": {"state": "translated", "value": "Hi, senior"}}}}}}), encoding="utf-8")
            texts = dict(cl.collect([tmp / "c.json", tmp / "L.xcstrings"]))
            self.assertIn("Hello there.", texts.values())
            self.assertIn("Hi, senior", texts.values())
        finally:
            shutil.rmtree(tmp)


if __name__ == "__main__":
    unittest.main()

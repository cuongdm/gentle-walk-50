#!/usr/bin/env python3
"""Render coach lines through Vibi (vibi.pro, an ElevenLabs partner) into the same cache as
tools/voice/render_lines.py, so build_manifest.py / i18n/build_content_overlay.py attach them as usual.

Vibi runs ElevenLabs models (eleven_v4 speaks Vietnamese) with the same voice ids and settings, billed in
Vibi credits (1 credit per character for eleven_v4, 02/10/2026). Differences from the ElevenLabs API:
  - a request returns a task id; the audio comes from GET /v1/history/{id} once "completed";
  - no per-character timing (its SRT is one block per line): word times come from Vibi's speech to text
    (ElevenLabs Scribe v2, word timestamps) run on the downloaded audio and matched to the line's own
    words; words it heard differently ("mười" as "10") take times between their neighbours. Measured
    02/10/2026 on 119 words with known times: 0.05 s mean, 0.10 s for 90%, about 0.3 Vibi credit per
    second of audio. If that fails, an estimate is written instead (speech span from ffmpeg
    silencedetect, characters spread over it, pauses after punctuation: 0.12 s mean, 0.44 s worst);
  - Cloudflare refuses requests without a User-Agent (error 1010).

Usage:  python3 tools/voice/render_lines_vibi.py --voice bella-v4-vi a1.07 a1.08 ...
        python3 tools/voice/render_lines_vibi.py --voice bella-v4-vi --all          (every line not cached)
        python3 tools/voice/render_lines_vibi.py --voice bella-v4-vi --all --dry-run (count, no calls)
        python3 tools/voice/render_lines_vibi.py --balance                          (credits left)
Options: --workers N (parallel tasks, default 4).
The key is read from ~/.config/vibi/api_key and never printed. Python 3.9, stdlib + ffmpeg/ffprobe.
"""
import difflib
import json
import re
import unicodedata
import uuid
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import render_lines as rl  # noqa: E402  (voices, settings, cache key and line texts are shared)

API = "https://api.vibi.pro"
HEADERS = {"User-Agent": "curl/8.7.1", "Accept": "application/json"}
POLL_SECONDS = 2
TIMEOUT_SECONDS = 300


def api_key():
    return (Path.home() / ".config" / "vibi" / "api_key").read_text().strip()


def call(path, key, body=None):
    headers = dict(HEADERS, **{"xi-api-key": key})
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode()
    req = urllib.request.Request(API + path, data=data, headers=headers)
    return json.load(urllib.request.urlopen(req, timeout=60))


def balance(key):
    return call("/v1/auth/me", key).get("credit_balance")


def speech_span(mp3):
    """(start, end) of speech in seconds: first and last non-silent moments."""
    duration = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
                                     str(mp3)], capture_output=True, text=True, check=True).stdout.strip())
    log = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(mp3), "-af",
                          "silencedetect=noise=-40dB:d=0.12", "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    starts = [float(x) for x in re.findall(r"silence_start: ([\d.]+)", log)]
    ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", log)]
    start = ends[0] if starts and starts[0] < 0.05 and ends else 0.0
    end = starts[-1] if starts and (not ends or starts[-1] > ends[-1]) else duration
    if end - start < 0.2:
        start, end = 0.0, duration
    return start, end


def estimated_alignment(text, start, end):
    """ElevenLabs-shaped alignment: characters spread over the speech span; punctuation holds a short
    pause and spaces a little, so word times follow the rhythm of the sentence."""
    weights = []
    for ch in text:
        if ch in ".!?":
            weights.append(4.0)
        elif ch in ",;:":
            weights.append(2.5)
        elif ch.isspace():
            weights.append(0.6)
        else:
            weights.append(1.0)
    total = sum(weights) or 1.0
    scale = (end - start) / total
    starts, ends, t = [], [], start
    for w in weights:
        starts.append(round(t, 3))
        t += w * scale
        ends.append(round(t, 3))
    return {"characters": list(text), "character_start_times_seconds": starts, "character_end_times_seconds": ends,
            "estimated": True}


def transcribe_words(mp3, key, language):
    """Vibi speech to text: [{text, start, end}] for each word heard."""
    boundary = uuid.uuid4().hex
    body = b""
    for name, value in (("language_code", language), ("timestamps_granularity", "word"), ("tag_audio_events", "false")):
        body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\"\r\n\r\n{value}\r\n".encode()
    body += (f"--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"line.mp3\"\r\n"
             "Content-Type: audio/mpeg\r\n\r\n").encode() + Path(mp3).read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    req = urllib.request.Request(API + "/v1/speech-to-text", data=body,
                                 headers=dict(HEADERS, **{"xi-api-key": key, "Content-Type": f"multipart/form-data; boundary={boundary}"}))
    task = json.load(urllib.request.urlopen(req, timeout=120))
    task_id = task.get("task_id") or task.get("id")
    deadline = time.time() + TIMEOUT_SECONDS
    while True:
        time.sleep(POLL_SECONDS)
        detail = call(f"/v1/speech-to-text/{task_id}", key)
        if detail.get("status") == "completed":
            break
        if detail.get("status") == "failed" or time.time() > deadline:
            raise RuntimeError(f"speech to text {detail.get('status')}")
    return [w for w in detail["result"]["words"] if w.get("type", "word") == "word"]


def _norm(word):
    return re.sub(r"[^\w]", "", unicodedata.normalize("NFC", word.lower()))


def heard_alignment(text, heard, span):
    """The line's own words, timed by the words speech to text heard. A word heard differently takes
    times spread between its matched neighbours (or the speech span at either end)."""
    words = text.split()
    times = [None] * len(words)
    matcher = difflib.SequenceMatcher(a=[_norm(w) for w in words], b=[_norm(w["text"]) for w in heard], autojunk=False)
    for block in matcher.get_matching_blocks():
        for k in range(block.size):
            h = heard[block.b + k]
            times[block.a + k] = (float(h["start"]), float(h["end"]))
    start, end = span
    i = 0
    while i < len(words):
        if times[i] is not None:
            i += 1
            continue
        j = i
        while j < len(words) and times[j] is None:
            j += 1
        left = times[i - 1][1] if i > 0 else start
        right = times[j][0] if j < len(words) else end
        right = max(right, left + 0.05 * (j - i))
        step = (right - left) / (j - i)
        for k in range(i, j):
            times[k] = (left + step * (k - i), left + step * (k - i + 1))
        i = j
    chars, starts, ends = [], [], []
    for index, (word, (w_start, w_end)) in enumerate(zip(words, times)):
        if index:
            chars.append(" ")
            starts.append(round(ends[-1], 3))
            ends.append(round(w_start, 3))
        step = max(w_end - w_start, 0.01) / len(word)
        for k, ch in enumerate(word):
            chars.append(ch)
            starts.append(round(w_start + step * k, 3))
            ends.append(round(w_start + step * (k + 1), 3))
    return {"characters": chars, "character_start_times_seconds": starts, "character_end_times_seconds": ends,
            "source": "vibi-speech-to-text"}


def alignment_for(text, mp3, key, language):
    """(alignment, heard text): word times from speech to text when it works, the estimate otherwise.
    The heard text is kept for the quality check (tools/voice/qc_lines.py)."""
    span = speech_span(mp3)
    try:
        heard = transcribe_words(mp3, key, language)
        return heard_alignment(text, heard, span), " ".join(w["text"] for w in heard)
    except (urllib.error.URLError, OSError, KeyError, ValueError, RuntimeError):
        return estimated_alignment(text, *span), None


def render_one(line_id, text, key):
    voice = rl.VOICE
    mp3 = rl.CACHE / f"{rl.cache_key(text)}.mp3"
    meta = mp3.with_suffix(".json")
    if mp3.exists() and meta.exists():
        return line_id, "cached", 0
    body = {"text": text, "model_id": voice["model"], "language_code": voice.get("language", "en"),
            "voice_settings": rl.SETTINGS}
    task = call(f"/v1/text-to-speech/{voice['voice_id']}", key, body)
    deadline = time.time() + TIMEOUT_SECONDS
    while True:
        time.sleep(POLL_SECONDS)
        detail = call(f"/v1/history/{task['id']}", key)
        if detail["status"] == "completed":
            break
        if detail["status"] == "failed" or time.time() > deadline:
            raise RuntimeError(f"{line_id}: {detail['status']} {detail.get('error')}")
    url = detail["result"]["audio_url"]
    audio = urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=120).read()
    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp:
        tmp.write(audio)
    alignment, heard = alignment_for(text, tmp.name, key, voice.get("language", "en"))
    Path(tmp.name).replace(mp3)
    json.dump({"text": text, "voice_id": voice["voice_id"], "model": voice["model"], "via": "vibi",
               "task_id": task["id"], "alignment": alignment, "heard": heard},
              open(meta, "w", encoding="utf-8"), ensure_ascii=False)
    return line_id, "rendered", detail.get("credits_deducted") or 0


def main(argv):
    args = argv[1:]
    dry = "--dry-run" in args
    every = "--all" in args
    workers = 4
    if "--workers" in args:
        workers = int(args[args.index("--workers") + 1])
        del args[args.index("--workers"):args.index("--workers") + 2]
    if "--voice" in args:
        at = args.index("--voice")
        rl.VOICE = rl.VOICES[args[at + 1]]
        rl.CACHE = rl.VOICE["cache"]
        del args[at:at + 2]
    if "--balance" in args:
        print("credits:", balance(api_key()))
        return 0
    ids = [a for a in args if not a.startswith("--")]
    texts = rl.load_lines()
    if every:
        ids = list(texts)
    missing = [i for i in ids if i not in texts]
    if missing:
        print("unknown ids:", ", ".join(missing))
        return 2
    todo = [i for i in dict.fromkeys(ids) if not (rl.CACHE / f"{rl.cache_key(texts[i])}.mp3").exists()]
    chars = sum(len(texts[i]) for i in todo)
    print("lines: %d, to render: %d, characters: %d" % (len(set(ids)), len(todo), chars))
    if dry or not todo:
        return 0
    key = api_key()
    before = balance(key)
    if before is not None and before < chars:
        print(f"not enough credits: {before} < {chars}")
        return 3
    rl.CACHE.mkdir(parents=True, exist_ok=True)
    failed, spent = [], 0
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {pool.submit(render_one, i, texts[i], key): i for i in todo}
        for done, future in enumerate(as_completed(futures), 1):
            line_id = futures[future]
            try:
                _, state, credits = future.result()
                spent += credits
                print(f"[{done}/{len(todo)}] {state} {line_id}", flush=True)
            except (urllib.error.URLError, RuntimeError, OSError, KeyError) as error:
                failed.append(line_id)
                print(f"[{done}/{len(todo)}] FAILED {line_id}: {error}", flush=True)
    print(f"credits spent: {spent}; left: {balance(key)}")
    if failed:
        print("failed (run again to retry):", " ".join(failed))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

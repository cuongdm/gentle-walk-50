#!/usr/bin/env python3
"""Build a narrated instruction preview (loop + TTS voice + CapCut-style dynamic captions).

Usage: python3 build_preview.py config.json out_dir
Config:
  name, loop (24 fps mp4), cycle (s), intro (s frozen first frame), reps, outro (s frozen last frame)
  voice: "Samantha" (macOS `say`, placeholder) or
         {"engine": "elevenlabs", "voice_id": "...", "model": "eleven_multilingual_v2",
          "settings": {"stability": 0.6, "similarity_boost": 0.75, "style": 0.15, "speed": 0.92}, "cache": "assets/voice/cache"}
         ElevenLabs key is read from ~/.config/elevenlabs/api_key. Its /with-timestamps endpoint gives exact
         per-character times, used for word highlighting. Each line is cached by hash (rebuilds cost no credits).
  rate (wpm, macOS only)
  caption: {"mode": "dynamic" | "static",
            "x": left px | "align": "right", "right": px,  "y_center": px,  "max_width": px,
            "y_top": px (fixed top edge, default from y_center), "size": pt, "font": path, "font_index": n, "bg": "#RRGGBB", "bg_alpha": 0-255,
            "color": "#RRGGBB", "highlight": "#RRGGBB", "max_words": 4}
  crf (default 20), preset (default medium), audio_bitrate (default 160k); layout numbers are for 1280x720 and
  are scaled automatically to the loop resolution (e.g. x1.5 for 1920x1080).
  cues: [{"text": "spoken line", "caption": "short text (static mode only)", "at": "intro"|"repN", "offset": s}]
Dynamic mode: the FULL spoken line is shown in chunks of <= max_words words, chunk boundaries follow the
pauses found in the TTS audio (silencedetect), the word being spoken is drawn in the highlight colour.
Outputs: <name>_preview.mp4, <name>_voice.srt (sentence level), <name>_chunks.srt (chunk level).
Needs ffmpeg + Pillow. Captions are PNG states packed into an alpha .mov (this ffmpeg has no libass/drawtext).
"""
import base64, hashlib, json, os, re, shutil, subprocess, sys, urllib.request
from PIL import Image, ImageDraw, ImageFont

cfg = json.load(open(sys.argv[1])); out = sys.argv[2]; tmp = f"{out}/tts"; os.makedirs(tmp, exist_ok=True)
name, C, intro = cfg.get("name", "clip"), cfg["cycle"], cfg["intro"]
cap = {"mode": "dynamic", "size": 48, "font": "/System/Library/Fonts/Helvetica.ttc", "font_index": 1, "bg": "#3F6B55",
       "bg_alpha": 240, "color": "#FFFFFF", "highlight": "#F2B84B", "y_center": 300, "max_width": 460, "max_words": 4,
       **cfg.get("caption", {})}
run = lambda *a: subprocess.run(list(a), check=True, capture_output=True, text=True)
dur = lambda p: float(run("ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p).stdout)
hexc = lambda h, a=255: tuple(int(h[i:i + 2], 16) for i in (1, 3, 5)) + (a,)
VW, VH = [int(x) for x in run("ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height",
                               "-of", "csv=p=0", cfg["loop"]).stdout.strip().split(",")]
k = VW / 1280  # caption layout is authored for 1280x720 and scaled to the loop resolution
for key in ("size", "x", "right", "y_center", "y_top", "max_width"):
    if key in cap: cap[key] = int(round(cap[key] * k))
font = ImageFont.truetype(cap["font"], cap["size"], index=cap["font_index"])
nframes = int(run("ffprobe", "-v", "error", "-count_frames", "-select_streams", "v:0", "-show_entries",
                  "stream=nb_read_frames", "-of", "csv=p=0", cfg["loop"]).stdout)

def speech_segments(wav, total):
    """Speech intervals inside a TTS clip, split at pauses >= 90 ms."""
    err = subprocess.run(["ffmpeg", "-i", wav, "-af", "silencedetect=noise=-35dB:d=0.09", "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    starts = [float(x) for x in re.findall(r"silence_start: ([\d.]+)", err)]
    ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", err)]
    segs, t = [], 0.0
    for s, e in zip(starts, ends + [total] * (len(starts) - len(ends))):
        if s > t + 0.05: segs.append((t, s))
        t = e
    if t < total - 0.05: segs.append((t, total))
    return segs

def word_timings(text, wav):
    """[(word, start, end)] relative to the clip: phrases (split at punctuation) mapped onto speech segments."""
    total = dur(wav); segs = speech_segments(wav, total)
    phrases = [p.strip() for p in re.split(r"(?<=[.,?!;:…])\s+", text) if p.strip()]
    if len(segs) != len(phrases):  # fall back: one span covering all speech
        segs = [(segs[0][0], segs[-1][1])] if segs else [(0, total)]; phrases = [text]
    out = []
    for (s, e), ph in zip(segs, phrases):
        words = ph.split(); weights = [len(w) + 1 for w in words]; k = (e - s) / sum(weights); t = s
        for w, wt in zip(words, weights):
            out.append((w, t, t + wt * k)); t += wt * k
    return out

def chunks(words, max_words):
    """Split at punctuation into phrases, then split each phrase into balanced parts of <= max_words
    (e.g. 5 words -> 3+2, 4 words with max 3 -> 2+2), so no single word is left alone."""
    phrases, cur = [], []
    for w in words:
        cur.append(w)
        if re.search(r"[.,?!;:…]$", w[0]): phrases.append(cur); cur = []
    if cur: phrases.append(cur)
    res = []
    for ph in phrases:
        k = -(-len(ph) // max_words); size = -(-len(ph) // k); i = 0
        while i < len(ph):
            left = len(ph) - i; parts_left = -(-left // size)
            take = -(-left // parts_left); res.append(ph[i:i + take]); i += take
    return res

def layout(words):
    """Wrap chunk words into lines that fit max_width."""
    dr = ImageDraw.Draw(Image.new("RGB", (1, 1))); lines, cur = [], []
    for w in words:
        trial = " ".join(cur + [w])
        if cur and dr.textlength(trial, font=font) > cap["max_width"]: lines.append(cur); cur = [w]
        else: cur.append(w)
    lines.append(cur)
    # Balance a 2-line wrap so no word is left alone on line 2 ("Now the other / way." -> "Now the / other way.")
    if len(lines) == 2 and len(words) >= 3:
        tl = lambda ws: dr.textlength(" ".join(ws), font=font)
        best = min(range(1, len(words)), key=lambda k: max(tl(words[:k]), tl(words[k:])))
        if max(tl(words[:best]), tl(words[best:])) <= cap["max_width"]:
            lines = [words[:best], words[best:]]
    return lines

def render(words, hi, path):
    img = Image.new("RGBA", (VW, VH), (0, 0, 0, 0)); dr = ImageDraw.Draw(img)
    lines = layout(words); size = cap["size"]; pad = int(size * 0.45); lh = int(size * 1.2); sp = dr.textlength(" ", font=font)
    w = max(dr.textlength(" ".join(l), font=font) for l in lines) + 2 * pad; h = lh * len(lines) + 2 * pad
    x0 = cap["right"] - w if cap.get("align") == "right" else cap.get("x", 40)
    y0 = cap.get("y_top", cap["y_center"] - (lh + 2 * pad) / 2)  # fixed top edge: box grows downward, never jumps
    assert x0 >= 0 and x0 + w <= VW, f"caption too wide: {words}"
    dr.rounded_rectangle([x0, y0, x0 + w, y0 + h], radius=int(size * 0.35), fill=hexc(cap["bg"], cap["bg_alpha"]))
    idx = 0
    for j, l in enumerate(lines):
        x = x0 + pad
        for word in l:
            dr.text((x, y0 + pad + j * lh - int(size * 0.08)), word, font=font,
                    fill=hexc(cap["highlight"] if idx == hi else cap["color"]))
            x += dr.textlength(word, font=font) + sp; idx += 1
    img.save(path)

# 1) voice clips + absolute timings
voice = cfg.get("voice", "Samantha")

def eleven(text, i):
    """Return (wav, [(word, start, end)]) using ElevenLabs with-timestamps, cached on disk."""
    body = {"text": text, "model_id": voice.get("model", "eleven_multilingual_v2"), "voice_settings": voice.get("settings", {})}
    h = hashlib.sha1(json.dumps([voice["voice_id"], body], sort_keys=True).encode()).hexdigest()[:16]
    cache = voice.get("cache", "assets/voice/cache"); os.makedirs(cache, exist_ok=True)
    mp3, js = f"{cache}/{h}.mp3", f"{cache}/{h}.json"
    if not (os.path.exists(mp3) and os.path.exists(js)):
        key = open(os.path.expanduser("~/.config/elevenlabs/api_key")).read().strip()
        req = urllib.request.Request(f"https://api.elevenlabs.io/v1/text-to-speech/{voice['voice_id']}/with-timestamps?output_format=mp3_44100_128",
                                     data=json.dumps(body).encode(), headers={"xi-api-key": key, "Content-Type": "application/json"})
        res = json.load(urllib.request.urlopen(req))
        open(mp3, "wb").write(base64.b64decode(res["audio_base64"]))
        json.dump({"text": text, "alignment": res["alignment"]}, open(js, "w"))
    al = json.load(open(js))["alignment"]
    words, cur, start, end = [], "", None, None
    for ch, a, b in zip(al["characters"], al["character_start_times_seconds"], al["character_end_times_seconds"]):
        if ch.isspace():
            if cur: words.append((cur, start, end)); cur = ""
            continue
        if not cur: start = a
        cur += ch; end = b
    if cur: words.append((cur, start, end))
    wav = f"{tmp}/c{i:02d}.wav"; run("ffmpeg", "-v", "error", "-y", "-i", mp3, "-ar", "48000", "-ac", "2", wav)
    return wav, words

def macos(text, i):
    wav = f"{tmp}/c{i:02d}.wav"
    run("say", "-v", voice, "-r", str(cfg.get("rate", 145)), "-o", f"{tmp}/c{i:02d}.aiff", text)
    run("ffmpeg", "-v", "error", "-y", "-i", f"{tmp}/c{i:02d}.aiff", "-ar", "48000", "-ac", "2", wav)
    return wav, word_timings(text, wav)

cues = []
for i, c in enumerate(cfg["cues"]):
    base = 0 if c["at"] == "intro" else intro + (int(c["at"][3:]) - 1) * C
    wav, words = eleven(c["text"], i) if isinstance(voice, dict) else macos(c["text"], i)
    s = base + c["offset"]
    cues.append({"text": c["text"], "caption": c.get("caption", c["text"]), "s": s, "e": s + dur(wav) + 0.4,
                 "wav": wav, "words": [(w, s + a, s + b) for w, a, b in words]})
cues.sort(key=lambda x: x["s"])
for a, b in zip(cues, cues[1:]):
    a["e"] = min(a["e"], b["s"] - 0.05)
total = intro + cfg["reps"] * C + cfg["outro"]
ts = lambda x: f"{int(x // 3600):02d}:{int(x % 3600 // 60):02d}:{int(x % 60):02d},{int(round((x % 1) * 1000)) % 1000:03d}"
with open(f"{out}/{name}_voice.srt", "w") as f:
    for i, c in enumerate(cues, 1): f.write(f"{i}\n{ts(c['s'])} --> {ts(c['e'])}\n{c['text']}\n\n")

# 2) caption states: (start, end, png)
states, n_png = [], 0
def add_state(s, e, words, hi):
    global n_png
    p = f"{tmp}/s{n_png:04d}.png"; render(words, hi, p); states.append((s, e, p)); n_png += 1
chunk_srt = []
for c in cues:
    if cap["mode"] == "static":
        add_state(c["s"], c["e"], c["caption"].split(), -1); continue
    groups = chunks(c["words"], cap["max_words"])
    for gi, g in enumerate(groups):
        g_end = groups[gi + 1][0][1] if gi + 1 < len(groups) else c["e"]
        chunk_srt.append((g[0][1], g_end, " ".join(w for w, _, _ in g)))
        for wi, (w, a, b) in enumerate(g):
            end = g[wi + 1][1] if wi + 1 < len(g) else g_end
            add_state(a, end, [x for x, _, _ in g], wi)
with open(f"{out}/{name}_chunks.srt", "w") as f:
    for i, (s, e, t) in enumerate(chunk_srt, 1): f.write(f"{i}\n{ts(s)} --> {ts(e)}\n{t}\n\n")

# 3) caption track: concat of states with transparent gaps -> alpha mov
Image.new("RGBA", (VW, VH), (0, 0, 0, 0)).save(f"{tmp}/blank.png")
lines, t = [], 0.0
for s, e, p in sorted(states):
    if s > t + 1e-3: lines += [f"file '{os.path.abspath(tmp)}/blank.png'", f"duration {s - t:.3f}"]
    lines += [f"file '{os.path.abspath(p)}'", f"duration {max(e - s, 0.04):.3f}"]; t = e
lines += [f"file '{os.path.abspath(tmp)}/blank.png'", f"duration {max(total - t, 0.04):.3f}", f"file '{os.path.abspath(tmp)}/blank.png'"]
open(f"{tmp}/caps.txt", "w").write("\n".join(lines) + "\n")
run("ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", f"{tmp}/caps.txt", "-vf", "fps=24,format=rgba",
    "-c:v", "png", f"{tmp}/caps.mov")

# 4) compose video + captions + voice
n = len(cues); inputs = ["-i", cfg["loop"], "-i", f"{tmp}/caps.mov"]
for c in cues: inputs += ["-i", c["wav"]]
fg = ["[0:v]split=3[s0][s1][s2]",
      f"[s0]trim=end_frame=1,setpts=PTS-STARTPTS,tpad=stop_mode=clone:stop_duration={intro}[i]",
      f"[s1]loop=loop={cfg['reps'] - 1}:size={nframes}:start=0,setpts=N/24/TB[r]",
      f"[s2]trim=start_frame={nframes - 1},setpts=PTS-STARTPTS,tpad=stop_mode=clone:stop_duration={cfg['outro']}[o]",
      "[i][r][o]concat=n=3:v=1:a=0,fps=24[base]", "[1:v]setpts=PTS-STARTPTS[cap]",
      f"[base][cap]overlay=0:0:eof_action=pass,trim=duration={total:.3f},format=yuv420p[vout]"]
for i, c in enumerate(cues): fg.append(f"[{2 + i}:a]adelay={int(c['s'] * 1000)}|{int(c['s'] * 1000)}[a{i}]")
fg.append("".join(f"[a{i}]" for i in range(n)) + f"amix=inputs={n}:normalize=0,loudnorm=I=-16:TP=-1.5:LRA=11,aresample=48000,apad,atrim=duration={total:.3f}[aout]")
run("ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", ";".join(fg), "-map", "[vout]", "-map", "[aout]",
    "-c:v", "libx264", "-crf", str(cfg.get("crf", 20)), "-preset", cfg.get("preset", "medium"), "-profile:v", "high",
    "-c:a", "aac", "-b:a", cfg.get("audio_bitrate", "160k"), "-movflags", "+faststart", f"{out}/{name}_preview.mp4")
if not cfg.get("keep_tmp"): shutil.rmtree(tmp)
print(f"{out}/{name}_preview.mp4 {total:.2f}s, {n} cues, {len(chunk_srt)} chunks, {n_png} caption states")

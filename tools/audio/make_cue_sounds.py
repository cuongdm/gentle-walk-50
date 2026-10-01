#!/usr/bin/env python3
"""Cue sounds: a soft "ting" for 3, 2 and 1 and a brighter two-note chime for "Go" in the "Get ready"
countdown (WorkoutCountdownView), and a warm rising "ta-da" with the falling leaves on Complete. Synthesised (no licensed samples): sine partials with a fast attack and an
exponential decay, like a small bell / marimba. Writes iOS/App/Resources/Media/Sounds/countdown-{tick,go}.m4a and complete-cheer.m4a.
Usage: tools/video/.venv/bin/python3 tools/audio/make_cue_sounds.py"""
import os, subprocess, tempfile, wave
import numpy as np

SR = 44100
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "iOS/App/Resources/Media/Sounds")


def bell(freq, length, decay, partials=((1, 1.0), (2.76, 0.35), (5.4, 0.12)), at=0.0, total=None):
    n = int(SR * (total or (at + length)))
    t = np.arange(int(SR * length)) / SR
    env = np.minimum(1, t / 0.004) * np.exp(-t / decay)          # 4 ms attack, no click
    tone = sum(a * np.sin(2 * np.pi * freq * m * t) * np.exp(-t * (m - 1) * 3) for m, a in partials)
    out = np.zeros(n); start = int(SR * at)
    out[start:start + len(t)] += tone * env
    return out


def write(name, signal, peak_db=-6):
    signal = signal / np.max(np.abs(signal)) * 10 ** (peak_db / 20)
    fade = int(SR * 0.02); signal[-fade:] *= np.linspace(1, 0, fade)
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, name + ".wav")
        with wave.open(wav, "wb") as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
            w.writeframes((signal * 32767).astype(np.int16).tobytes())
        out = os.path.join(OUT, name + ".m4a")
        subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "-b", "96000", wav, out], check=True)
    print("wrote", out)


write("countdown-tick", bell(880, 0.45, 0.11), peak_db=-8)                     # A5, short
go = bell(1046.5, 1.1, 0.35, total=1.2) + 0.9 * bell(1568, 1.0, 0.3, at=0.12, total=1.2)   # C6 then G6
write("countdown-go", go, peak_db=-5)

# C5 E5 G5 rising quickly, then C6 ringing on: a small, happy "ta-da", not a fanfare.
notes = [(523.25, 0.00), (659.25, 0.11), (783.99, 0.22), (1046.5, 0.36)]
cheer = sum(bell(f, 1.6 - at, 0.25 if f < 1000 else 0.55, at=at, total=1.8) * (1.0 if f > 1000 else 0.75) for f, at in notes)
write("complete-cheer", cheer, peak_db=-6)

#!/usr/bin/env python3
"""Cut an AI source clip into an app loop from a segment list.

Usage: python3 build_loop.py source.mp4 out.mp4 "3.6-7.3,0.4-0.6,0.6-2.3x1.3,2.3-3.6" [crf=18]
Each segment: start-end[xSLOW] (seconds in the source; xSLOW stretches time, e.g. x1.3 = 30% slower).
Output: H.264, 24 fps, yuv420p, no audio, faststart. Then run qa_measure.py on the result.
"""
import subprocess, sys
src, out, spec = sys.argv[1], sys.argv[2], sys.argv[3]
crf = sys.argv[4] if len(sys.argv) > 4 else "18"  # optional: CRF (lower = higher quality)
parts = []
for i, seg in enumerate(spec.split(",")):
    slow = 1.0
    if "x" in seg: seg, s = seg.split("x"); slow = float(s)
    a, b = seg.split("-")
    parts.append(f"[0:v]trim=start={a}:end={b},setpts={slow}*(PTS-STARTPTS)[s{i}]")
n = len(parts)
fg = ";".join(parts) + ";" + "".join(f"[s{i}]" for i in range(n)) + f"concat=n={n}:v=1:a=0,fps=24,format=yuv420p[v]"
subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", src, "-filter_complex", fg, "-map", "[v]", "-an",
                "-c:v", "libx264", "-crf", crf, "-preset", "slow", "-profile:v", "high", "-movflags", "+faststart", out], check=True)
print(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", out]).decode().strip(), "s")

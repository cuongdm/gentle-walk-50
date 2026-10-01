#!/usr/bin/env python3
"""Re-join a two-part clip (side A then side B) at the frames where the two parts match best.

Crossfading two AI clips at an arbitrary rest frame leaves a double image ("ghost") when the coach's
hands or feet sit a little differently in each part. This tool searches the rest windows for the
frame pair with the smallest difference, joins A→B there with a short crossfade, and closes the loop
B→A the same way, so the ghost shrinks to one or two frames.

Usage:
  python3 rejoin_best.py A.mp4 B.mp4 OUT.mp4 [--a-head 0-1.5] [--a-tail 6.5-8] [--b-head 0-1.5]
         [--b-tail 6.5-8] [--xf 0.15] [--loop-xf 0.083] [--size 1124x632]
Windows are seconds in each source; defaults are the first / last 1.5 s (coach at rest).
Prints the chosen cut points and their match scores (mean abs gray difference, 0-255).
"""
import argparse, subprocess
import numpy as np

FPS = 24


def gray(path, w=281, h=158):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-vf", f"fps={FPS},scale={w}:{h},format=gray",
                          "-f", "rawvideo", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.uint8).reshape(-1, h, w).astype(np.float32)


def window(spec, n):
    a, b = (float(v) for v in spec.split("-"))
    return max(0, int(round(a * FPS))), min(n - 1, int(round(b * FPS)))


def best_pair(x, xw, y, yw):
    best = None
    for i in range(xw[0], xw[1] + 1):
        d = np.abs(y[yw[0]:yw[1] + 1] - x[i]).mean(axis=(1, 2))
        j = int(d.argmin())
        if best is None or d[j] < best[0]:
            best = (float(d[j]), i, yw[0] + j)
    return best


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("a"); ap.add_argument("b"); ap.add_argument("out")
    ap.add_argument("--a-head", default=None); ap.add_argument("--a-tail", default=None)
    ap.add_argument("--b-head", default=None); ap.add_argument("--b-tail", default=None)
    ap.add_argument("--xf", type=float, default=0.15); ap.add_argument("--loop-xf", type=float, default=0.083)
    ap.add_argument("--size", default="1124x632")
    o = ap.parse_args()
    A, B = gray(o.a), gray(o.b)
    na, nb = len(A) / FPS, len(B) / FPS
    aw_h = window(o.a_head or "0-1.5", len(A)); aw_t = window(o.a_tail or f"{na - 1.5}-{na}", len(A))
    bw_h = window(o.b_head or "0-1.5", len(B)); bw_t = window(o.b_tail or f"{nb - 1.5}-{nb}", len(B))
    jd, i, j = best_pair(A, aw_t, B, bw_h)      # A end -> B start
    ld, k, l = best_pair(B, bw_t, A, aw_h)      # B end -> A start (loop)
    a0, a1 = l / FPS, i / FPS
    b0, b1 = j / FPS, k / FPS
    w, h = o.size.split("x")
    xf, lxf = o.xf, o.loop_xf
    len_a = a1 - a0 + xf / 2
    filt = (f"[0:v]trim={a0:.3f}:{a1 + xf / 2:.3f},setpts=PTS-STARTPTS,fps={FPS},scale={w}:{h}[a];"
            f"[1:v]trim={max(0, b0 - xf / 2):.3f}:{b1 + lxf:.3f},setpts=PTS-STARTPTS,fps={FPS},scale={w}:{h}[b];"
            f"[a][b]xfade=transition=fade:duration={xf}:offset={len_a - xf:.3f},split[c1][c2];"
            f"[c2]trim=0:{lxf},setpts=PTS-STARTPTS[hd];"
            f"[c1][hd]xfade=transition=fade:duration={lxf}:offset=__OFF__,trim=start={lxf},setpts=PTS-STARTPTS,format=yuv420p[v]")
    tmp_len = len_a + (b1 + lxf - max(0, b0 - xf / 2)) - xf
    filt = filt.replace("__OFF__", f"{tmp_len - lxf:.3f}")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", o.a, "-i", o.b, "-filter_complex", filt, "-map", "[v]",
                    "-an", "-c:v", "libx264", "-crf", "16", "-preset", "slow", "-movflags", "+faststart", o.out], check=True)
    print(f"A {a0:.2f}-{a1:.2f}s -> B {b0:.2f}-{b1:.2f}s | join diff {jd:.2f} | loop diff {ld:.2f} | {o.out}")


if __name__ == "__main__":
    main()

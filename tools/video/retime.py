#!/usr/bin/env python3
"""Change the tempo of a finished loop clip by motion-interpolated time-remapping, then
re-trim it to whole movement cycles so it still loops cleanly.

Why: prompts only ask Flow for correct form and EVEN repetitions at one natural pace;
the easy / quicker / slow-lowering versions are made here (owner's rule 30/09/2026,
docs/scripts/P-production-prompts.md §6).

Usage:
  python3 retime.py IN.mp4 --factor 0.92 [-o OUT.mp4] [--cycles N] [--engine minterpolate|rife]
                    [--segment START-END] [--crf 16]

  --factor   speed factor: <1 slower (easy), >1 faster (quicker). Allowed 0.75-1.3;
             without interpolation (--engine none) only 0.87-1.15.
  --cycles   number of whole movement cycles in IN (e.g. 2 step pairs). The output is
             re-trimmed to exactly that many cycles of the new length, so the seam stays clean.
  --segment  only remap this part (seconds, e.g. 4.4-5.3 for a slower lowering phase);
             the rest plays at 1x.
  --engine   minterpolate (ffmpeg, default) | rife (needs `rife-ncnn-vulkan` on PATH) | none

Prints the QA numbers the plan asks for: output length, median/max frame-to-frame change,
and the loop seam, via tools/video/qa_measure.py when it is next to this script.
"""
import argparse, os, shutil, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
MI = "minterpolate=fps={fps}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"


def probe(path):
    out = subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
                                   "stream=r_frame_rate,width,height:format=duration", "-of", "default=nw=1", path]).decode()
    vals = dict(line.split("=", 1) for line in out.strip().splitlines())
    num, den = vals["r_frame_rate"].split("/")
    return float(vals["duration"]), float(num) / float(den), int(vals["width"]), int(vals["height"])


def run(cmd):
    subprocess.run(cmd, check=True)


def remap(src, dst, factor, fps, engine, crf):
    """Whole-clip speed change by `factor` with motion interpolation back to `fps`."""
    if engine == "none":
        vf = f"setpts=PTS/{factor}"
    elif engine == "minterpolate":
        vf = f"setpts=PTS/{factor}," + MI.format(fps=fps)
    else:  # rife: double the frame rate with RIFE, then retime and resample
        tmp = tempfile.mkdtemp()
        try:
            run(["ffmpeg", "-v", "error", "-y", "-i", src, os.path.join(tmp, "in_%05d.png")])
            os.makedirs(os.path.join(tmp, "out"))
            run(["rife-ncnn-vulkan", "-i", tmp, "-o", os.path.join(tmp, "out"), "-f", "%05d.png"])
            run(["ffmpeg", "-v", "error", "-y", "-framerate", str(fps * 2), "-i", os.path.join(tmp, "out", "%05d.png"),
                 "-vf", f"setpts=PTS/{factor},fps={fps}", "-an", "-c:v", "libx264", "-crf", str(crf),
                 "-preset", "slow", "-pix_fmt", "yuv420p", dst])
        finally:
            shutil.rmtree(tmp, ignore_errors=True)
        return
    run(["ffmpeg", "-v", "error", "-y", "-i", src, "-vf", vf, "-an", "-c:v", "libx264", "-crf", str(crf),
         "-preset", "slow", "-pix_fmt", "yuv420p", dst])


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("--factor", type=float, required=True)
    ap.add_argument("-o", "--out")
    ap.add_argument("--cycles", type=int, help="whole movement cycles in the input clip")
    ap.add_argument("--segment", help="START-END seconds to remap; the rest stays at 1x")
    ap.add_argument("--engine", default="minterpolate", choices=["minterpolate", "rife", "none"])
    ap.add_argument("--crf", type=int, default=16)
    a = ap.parse_args(argv)

    lo, hi = (0.87, 1.15) if a.engine == "none" else (0.75, 1.3)
    if not lo <= a.factor <= hi:
        sys.exit(f"factor {a.factor} outside {lo}-{hi} for engine {a.engine} (plan rule); make a separate clip instead")
    if a.engine == "rife" and not shutil.which("rife-ncnn-vulkan"):
        sys.exit("rife-ncnn-vulkan not on PATH; use --engine minterpolate")
    dur, fps, w, h = probe(a.src)
    tag = "easy" if a.factor < 1 else "quick"
    out = a.out or a.src.rsplit(".", 1)[0] + f"-{tag}.mp4"
    tmp = tempfile.mkdtemp()
    try:
        if a.segment:
            s, e = (float(x) for x in a.segment.split("-"))
            parts = []
            for i, (ps, pe, f) in enumerate([(0, s, 1.0), (s, e, a.factor), (e, dur, 1.0)]):
                if pe - ps < 1.0 / fps:
                    continue
                cut = os.path.join(tmp, f"c{i}.mp4")
                run(["ffmpeg", "-v", "error", "-y", "-ss", str(ps), "-to", str(pe), "-i", a.src, "-an",
                     "-c:v", "libx264", "-crf", "10", "-pix_fmt", "yuv420p", cut])
                if f != 1.0:
                    rem = os.path.join(tmp, f"r{i}.mp4")
                    remap(cut, rem, f, fps, a.engine, 10)
                    cut = rem
                parts.append(cut)
            lst = os.path.join(tmp, "list.txt")
            with open(lst, "w") as fh:
                fh.write("".join(f"file '{p}'\n" for p in parts))
            run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-an", "-c:v", "libx264",
                 "-crf", str(a.crf), "-preset", "slow", "-pix_fmt", "yuv420p", out])
        else:
            full = os.path.join(tmp, "full.mp4")
            remap(a.src, full, a.factor, fps, a.engine, 10)
            if a.cycles:
                # new cycle length = old / factor; keep exactly `cycles` of them (drop the
                # interpolation tail) so the last frame meets the first again
                keep = round((dur / a.factor) * fps) / fps
                run(["ffmpeg", "-v", "error", "-y", "-i", full, "-t", f"{keep:.4f}", "-an", "-c:v", "libx264",
                     "-crf", str(a.crf), "-preset", "slow", "-pix_fmt", "yuv420p", out])
            else:
                shutil.move(full, out)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    nd, _, _, _ = probe(out)
    print(f"in  {dur:.3f}s  factor {a.factor}  engine {a.engine}{'  segment ' + a.segment if a.segment else ''}")
    print(f"out {nd:.3f}s  {out}")
    qa = os.path.join(HERE, "qa_measure.py")
    if os.path.exists(qa):
        res = subprocess.run([sys.executable, qa, out], capture_output=True, text=True).stdout
        for line in res.splitlines():
            if "seam" in line or "camera" in line or "head" in line.lower():
                print("qa  " + line)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

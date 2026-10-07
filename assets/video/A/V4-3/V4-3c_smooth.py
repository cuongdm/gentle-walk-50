"""V4-3 loop from the one-take V4-3c clip with an even, eased tempo (06/10/2026, owner: "not smooth yet").

Measured on the pinned 1080p frames of V4-3c (src frame numbers):
  rest -> heel raise 2 up 57..67 (only 0.4 s: jerky) -> hold 67..80 -> down 80..98 (0.75 s) -> rest 98..108
  -> toes up 109..131 (image-measured; pose misses it) -> hold 131..143.
Each move is re-timed by its own progress (heel height from the pose track, toe-sole height from the image): the output follows a
cosine ease (slow start, slow stop) over a fixed number of frames, so up and down take the same time and
an uneven AI move plays evenly. In-between frames are made by optical-flow interpolation (OpenCV DIS,
two-way warp + blend). The toes go back down along the same eased path (reversed), then the rest frames
play back to frame B and the last 8 frames morph (optical flow, not a crossfade of different poses) from that
rest into the frames that lead up to A, the start of the loop.

Usage: python V4-3c_smooth.py pinned_frames_dir up1080.pose.npz out.mp4
"""
import glob, os, subprocess, sys, tempfile
import cv2, numpy as np

src_dir, pose, out = sys.argv[1:4]
paths = sorted(glob.glob(f"{src_dir}/*.png"))
frames = [cv2.imread(p) for p in paths]
H, W = frames[0].shape[:2]
xy = np.load(pose)["xy"].astype(float)
heel = (xy[:, 29, 1] + xy[:, 30, 1]) / 2


def toe_sole(im):
    """Height of the toe-box sole (lowest white row in a strip near the toe tip). The pose toe point lags and
    misses the real toe move here: a slow creep (src 109-124) then a jump of 21 px in 6 frames (124-130)."""
    hsv = cv2.cvtColor(im[945:1035, 765:800], cv2.COLOR_BGR2HSV)
    rows = np.where((((hsv[..., 1] < 35) & (hsv[..., 2] > 195)).sum(1)) > 8)[0]
    return rows.max() + 945.0


toe = np.array([toe_sole(f) for f in frames])

HEEL_UP, HEEL_DOWN, TOE_UP = (57, 67), (80, 98), (109, 131)
HOLD_TOP_END, REST_END, LAST = 80, 108, len(frames) - 1
N_HEEL_UP, N_HEEL_DOWN, N_TOE = 20, 22, 24          # output frames per move (24 fps)


def smooth(v, sigma=1.2):
    k = np.exp(-0.5 * (np.arange(-4, 5) / sigma) ** 2)
    return np.convolve(np.pad(v, 4, mode="edge"), k / k.sum(), mode="valid")


def eased(sig, s0, s1, n, w=0.65):
    """Source times for n output frames that move `sig` from s0 to s1 along a cosine ease."""
    idx = np.arange(s0, s1 + 1, dtype=float)
    v = smooth(sig)[s0:s1 + 1]
    p = (v - v[0]) / (v[-1] - v[0])
    p = np.maximum.accumulate(np.clip(p, 0, 1)) + np.linspace(0, 1e-3, len(p))   # monotonic for the inverse
    p = (p - p[0]) / (p[-1] - p[0])
    # blend with plain time so a stall in the AI move is not skipped in one leap (the rest of the body keeps
    # moving through it)
    p = w * p + (1 - w) * np.linspace(0, 1, len(p))
    q = (1 - np.cos(np.pi * np.arange(n) / (n - 1))) / 2
    return list(np.interp(q, p, idx))


# --- optical-flow in-betweens -------------------------------------------------------------------------
dis = cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM)
SC = 0.5
gray = [cv2.cvtColor(cv2.resize(f, None, fx=SC, fy=SC), cv2.COLOR_BGR2GRAY) for f in frames]
flows = {}


def flow(i, j):
    if (i, j) not in flows:
        f = dis.calc(gray[i], gray[j], None)
        flows[(i, j)] = cv2.resize(f, (W, H)) / SC
    return flows[(i, j)]


gy, gx = np.mgrid[0:H, 0:W].astype(np.float32)


def mix(i, j, a):
    """Frame between source frames i and j at fraction a (motion-compensated, two-way warp + blend)."""
    if a < 0.02:
        return frames[i]
    if a > 0.98:
        return frames[j]
    fij, fji = flow(i, j), flow(j, i)
    wi = cv2.remap(frames[i], gx - a * fij[..., 0], gy - a * fij[..., 1], cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)
    wj = cv2.remap(frames[j], gx - (1 - a) * fji[..., 0], gy - (1 - a) * fji[..., 1], cv2.INTER_LINEAR,
                   borderMode=cv2.BORDER_REPLICATE)
    return cv2.addWeighted(wi, 1 - a, wj, a, 0)


def at(t):
    """A frame from the time map: a (fractional) source time, or ("morph", b, a, alpha) at the loop seam."""
    if isinstance(t, tuple):
        _, fb, fa, al = t
        return mix(fb, fa, al)
    i = int(np.floor(t))
    return frames[LAST] if i >= LAST else mix(i, i + 1, t - i)


# --- loop seam -------------------------------------------------------------------------------------------
# Before the heel raise the body eases forward; after the toes come down it eases back, so no hard cut reads
# as one motion. Instead the last M frames morph (motion-compensated) from the after-toes rest, still playing
# backwards (B-1, B-2, ...), into the frames that lead up to A (A-M .. A-1), so both motions keep going.
M = 8
small = [cv2.resize(g, (240, 135)).astype(np.float32) for g in gray]
best = None
for a in range(41 + M, 57):
    for b in range(98 + M + 1, TOE_UP[0]):
        cost = np.mean([np.abs(small[b - k] - small[a - M - 1 + k]).mean() for k in range(M + 2)])
        if best is None or cost < best[0]:
            best = (cost, a, b)
_, A, B = best
seam = [("morph", B - k, A - M - 1 + k, (1 - np.cos(np.pi * k / (M + 1))) / 2) for k in range(1, M + 1)]

# --- source-time map ---------------------------------------------------------------------------------
ts = list(range(A, HEEL_UP[0]))
ts += eased(-heel, *HEEL_UP, N_HEEL_UP)
ts += list(range(HEEL_UP[1] + 1, HOLD_TOP_END))
ts += eased(heel, *HEEL_DOWN, N_HEEL_DOWN)
ts += list(range(HEEL_DOWN[1] + 1, TOE_UP[0]))
toe_up = eased(-toe, *TOE_UP, N_TOE, w=0.5)        # the toe stalls at src 115-121 while head/hips move
ts += toe_up
hold = list(range(TOE_UP[1] + 1, TOE_UP[1] + 7))     # toes-up hold; the AI lets the toes sag after src ~137
ts += hold + hold[-2::-1]
ts += toe_up[::-1]
ts += list(range(TOE_UP[0] - 1, B - 1, -1))
ts += seam
print(f"seam B={B} -> A={A} over {M} morph frames (mean diff {best[0]:.2f}); {len(ts)} frames = {len(ts) / 24:.2f} s")

with tempfile.TemporaryDirectory() as tmp:
    for k, t in enumerate(ts):
        cv2.imwrite(f"{tmp}/{k:04d}.png", at(t if isinstance(t, tuple) else float(t)))
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", "24", "-i", f"{tmp}/%04d.png",
                    "-c:v", "libx265", "-crf", "24", "-preset", "medium", "-tag:v", "hvc1", "-pix_fmt", "yuv420p",
                    "-x265-params", "log-level=error", "-movflags", "+faststart", out], check=True)
np.save(out + ".timemap.npy", np.array([t[2] if isinstance(t, tuple) else t for t in ts], dtype=float))

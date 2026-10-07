"""Pin the feet in the toe-raise half of V4-3 (frames 96-152).

The AI toe clip slides both shoes ~20 px forward while the toes lift (frames 99-103) and back at the end
(147-150); the hand, chair, wall and floor stay still and the shins move only a little. For each frame of
that half the person layer below the knees is moved back by the heel drift (back edge of the shoes against frames
91-95), the shift growing from 0 at the knees to the full drift at the shoes. The strip the shoes leave is
filled from a clean background plate (per-pixel median of every frame where the person does not cover
that pixel, inpainted where the person always covers it). Outside the person nothing moves, so the floor boards stay straight.

Usage: python V4-3_feet_pin.py in.mp4 out_frames_dir [toe_start ref_from:ref_to]   (encode: libx265 crf 24, hvc1, 24 fps)
(defaults 95 90:95 = the 06/10 two-clip join; V4-3c one-take: see V4-3c_build.py)
"""
import os, sys, cv2, numpy as np
import mediapipe as mp

src, out = sys.argv[1:3]
os.makedirs(out, exist_ok=True)
# first frame of the toe raise and the flat-foot frames just before it that the heels are pinned to
TOE0 = int(sys.argv[3]) if len(sys.argv) > 3 else 95
REF = slice(*map(int, sys.argv[4].split(":"))) if len(sys.argv) > 4 else slice(90, 95)

cap = cv2.VideoCapture(src)
frames = []
while True:
    ok, im = cap.read()
    if not ok:
        break
    frames.append(im)


def heel_back(im):
    """x of the back edge of the white shoes, measured on the sole rows (the pose heel point lags and
    under-reads while the foot tilts)."""
    hsv = cv2.cvtColor(im[940:990, 630:860], cv2.COLOR_BGR2HSV)
    white = (hsv[..., 1] < 30) & (hsv[..., 2] > 215)
    cols = np.where(white.sum(0) > 4)[0]
    return cols.min() + 630.0


heel = np.array([heel_back(f) for f in frames])
ref = heel[REF].mean()
drift = np.zeros(len(heel))
drift[TOE0:] = heel[TOE0:] - ref
drift[TOE0:] = np.convolve(np.pad(drift[TOE0:], 1, mode="edge"), np.ones(3) / 3, mode="valid")  # 3-frame smooth

Y0, Y1, X0, X1 = 700, 1060, 540, 905            # knees down to below the soles; stops before the chair leg
KNEE, SHOE = 740, 925                           # rows where the shift starts and reaches the full drift
bh, bw = Y1 - Y0, X1 - X0

seg = mp.solutions.pose.Pose(static_image_mode=False, model_complexity=2, enable_segmentation=True,
                             smooth_segmentation=True)
soft, wide, tight = [], [], []
for im in frames:
    r = seg.process(cv2.cvtColor(im, cv2.COLOR_BGR2RGB))
    m = r.segmentation_mask[Y0:Y1, X0:X1] if r.segmentation_mask is not None else np.zeros((bh, bw), np.float32)
    soft.append(cv2.dilate(np.clip((m - 0.2) / 0.3, 0, 1).astype(np.float32), np.ones((5, 5), np.uint8)))
    wide.append(cv2.dilate((m > 0.1).astype(np.uint8), np.ones((11, 11), np.uint8)).astype(bool))
    tight.append(cv2.dilate((m > 0.1).astype(np.uint8), np.ones((9, 9), np.uint8)).astype(bool))

# clean background: per-pixel median over frames where the (generously grown) person mask is off
stack = np.stack([f[Y0:Y1, X0:X1] for f in frames]).astype(np.float32)
free = ~np.stack(tight)
known = free.any(0)
plate = np.stack([np.nanmedian(np.where(free, stack[..., c], np.nan), axis=0) for c in range(3)], -1)
# pixels the person always covers (under the planted shoes): inpaint from the floor/wall around them
plate = cv2.inpaint(np.nan_to_num(plate).clip(0, 255).astype(np.uint8), (~known).astype(np.uint8), 7,
                    cv2.INPAINT_TELEA).astype(np.float32)
print("plate seen %.1f%% of the box, rest inpainted" % (100 * known.mean()))
# the AI scene drifts a little over time, so where the rest frames just before the pin starts see the floor
# (the band in front of the planted shoes) take it from them: same light, same baseboard line
near = slice(max(0, TOE0 - 16), TOE0)
nfree = free[near]
nplate = np.stack([np.nanmedian(np.where(nfree, stack[near][..., c], np.nan), axis=0) for c in range(3)], -1)
nknown = nfree.sum(0) >= 3
plate[nknown] = nplate[nknown]

gy, gx = np.mgrid[0:bh, 0:bw].astype(np.float32)
t = np.clip((gy + Y0 - KNEE) / (SHOE - KNEE), 0, 1)
ramp = t * t * (3 - 2 * t)
fy = np.minimum(np.arange(bh), np.arange(bh)[::-1]) / 12
fx = np.minimum(np.arange(bw), np.arange(bw)[::-1]) / 12
edge = np.clip(np.minimum.outer(fy, fx), 0, 1)[..., None]           # fade the box into the untouched frame

for i, im in enumerate(frames):
    d = drift[i]
    if abs(d) > 0.25:
        box = stack[i]
        mapx = gx + d * ramp
        moved = cv2.remap(box, mapx, gy, cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
        a = cv2.remap(soft[i], mapx, gy, cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT)[..., None]
        # where the person was (wide mask) the background comes from the plate, elsewhere from the frame
        # plate only where the person was and the moved person is not (the band the shoes leave); everywhere
        # else the frame itself stays, so the floor keeps its own shading and no patch flickers in and out
        gone = wide[i].astype(np.float32) * (1 - np.clip(a[..., 0] * 2, 0, 1))
        was = cv2.GaussianBlur(gone, (15, 15), 0)[..., None]
        bg = box * (1 - was) + plate * was
        comp = moved * a + bg * (1 - a)
        im = im.copy()
        im[Y0:Y1, X0:X1] = np.clip(comp * edge + box * (1 - edge), 0, 255).astype(np.uint8)
    cv2.imwrite(f"{out}/{i:04d}.png", im)
print(len(frames), "frames; drift px min %.1f max %.1f" % (drift.min(), drift.max()))

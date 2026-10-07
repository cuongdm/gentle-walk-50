"""Toes-up end-pose image for V4-3b, made locally (0 credits) from the V4-alt rest frame:
rotate the shoes about the ankle joint so the front of the feet lifts and the heels stay down,
inpaint the floor uncovered under the toes. Usage: python3 this.py ANGLE OUT.png"""
import cv2, numpy as np, sys
src = cv2.imread('V4-3_start_from-V4-alt_1280.png')
H, W = src.shape[:2]
ang = float(sys.argv[1]); out_path = sys.argv[2]
px, py = 465, 636                      # ankle joint (pivot): the shin does not move in a toe raise
x0, x1, y0, y1 = 432, 572, 619, 684    # shoe box (below the legging hem)
hsv = cv2.cvtColor(src, cv2.COLOR_BGR2HSV)
box = np.zeros((H, W), bool); box[y0:y1, x0:x1] = True
shoe = (hsv[..., 2] > 140) & (hsv[..., 1] < 27) & box                       # white shoes
sock = (hsv[..., 1] >= 27) & (hsv[..., 1] < 70) & (hsv[..., 0] < 16) & box   # skin/sock at the ankle
sock[641:, :] = False
mask = ((shoe | sock) * 255).astype(np.uint8)
mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, np.ones((7, 7), np.uint8))
cnts, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
mask = np.zeros_like(mask)
cv2.drawContours(mask, [c for c in cnts if cv2.contourArea(c) > 300], -1, 255, -1)
mask[:y0] = 0
# include the dark sole edge just under the white shoe
sole = (hsv[..., 2] < 130) & box
sole[:655] = False
mask = np.maximum(mask, (sole * 255).astype(np.uint8))
hole = cv2.dilate(mask, np.ones((7, 7), np.uint8))
# plate: floor rows copied from the clean floor 120 px to the left (same depth), wall rows by inpaint
plate = src.copy()
shift = np.roll(src, 120, axis=1)
floor_rows = np.zeros((H, W), bool); floor_rows[628:, :] = True
fill = (hole > 0) & floor_rows
plate[fill] = shift[fill]
plate = cv2.inpaint(plate, ((hole > 0) & ~floor_rows).astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA)
edge = cv2.dilate(hole, np.ones((5, 5), np.uint8)) - cv2.erode(hole, np.ones((5, 5), np.uint8))
blur = cv2.GaussianBlur(plate, (5, 5), 0)
plate[edge > 0] = blur[edge > 0]
M = cv2.getRotationMatrix2D((px, py), ang, 1.0)
rot = cv2.warpAffine(src, M, (W, H), flags=cv2.INTER_CUBIC)
rmask = cv2.warpAffine(mask, M, (W, H), flags=cv2.INTER_LINEAR).astype(np.float32) / 255
rmask[:y0 - 2] = 0
a = cv2.GaussianBlur(rmask, (3, 3), 0)[..., None]
out = plate * (1 - a) + rot * a
cv2.imwrite(out_path, out.astype(np.uint8))
cv2.imwrite(out_path.replace('.png', '_mask.png'), mask)

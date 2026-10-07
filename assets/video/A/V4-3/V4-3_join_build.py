"""V4-3 = V4-alt heel raise (frames A_START..A_END) + toe raise (B out B0..BP, then reversed back),
joined at matched rest frames with a hard cuts (no crossfade)."""
import os, shutil, numpy as np
from PIL import Image
S = os.path.dirname(os.path.abspath(__file__))
A_START, A_END = 30, 124          # V4-alt: rest (from A30) -> heel raise -> rest (to A124)
B0, BP = 56, 84                   # toe clip: rest at 56 -> toes up, peak/hold to 84
XF = 0
a = [f"{S}/a/{i:04d}.png" for i in range(A_START, A_END + 1)]
b_out = [f"{S}/b/{i:04d}.png" for i in range(B0, BP + 1)]
b = b_out + b_out[-2::-1]         # out, then reversed back to B0 (rest) before the wrap to A_START
seq = a + b
out = os.path.join(S, "seq"); shutil.rmtree(out, ignore_errors=True); os.makedirs(out)
frames = list(seq)
def blend(p, q, t):
    return Image.blend(Image.open(p).convert("RGB"), Image.open(q).convert("RGB"), t)
n = len(frames)
imgs = {}
# join A_END -> B0: dissolve over the last XF frames of A into the first frames of B
ja = len(a)
for k in range(XF):
    t = (k + 1) / (XF + 1)
    imgs[ja - XF + k] = blend(frames[ja - XF + k], frames[ja + k], t)
# loop wrap B(end) -> A_START: dissolve the last XF frames of B toward the first frames of A
for k in range(XF):
    t = (k + 1) / (XF + 1)
    imgs[n - XF + k] = blend(frames[n - XF + k], frames[k], t)
for i, p in enumerate(frames):
    dst = f"{out}/{i:04d}.png"
    if i in imgs: imgs[i].save(dst)
    else: shutil.copy(p, dst)
print(n, "frames", n / 24, "s; heel part", len(a), "toe part", len(b))

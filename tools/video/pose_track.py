#!/usr/bin/env python3
"""Extract 2-D body landmarks for every frame of a clip with MediaPipe Pose (33 points), cached as .npz.

Run with the tools/video/.venv interpreter (mediapipe + opencv-python-headless installed there):
  tools/video/.venv/bin/python3 tools/video/pose_track.py CLIP.mp4 [...] [--force]
Output: <clip>.pose.npz next to the clip, with
  xy  : (frames, 33, 2) pixel coordinates (x right, y down), NaN when the point was not found
  vis : (frames, 33) visibility 0-1
  fps, width, height
Landmark ids used downstream: 11/12 shoulders, 23/24 hips, 25/26 knees, 27/28 ankles, 29/30 heels,
31/32 foot index (toes); even = person's RIGHT side, odd = person's LEFT side (anatomical, not image side).
Model: bundled with mediapipe 0.10.x (solutions.pose, model_complexity=2).
"""
import os, sys
import numpy as np
import cv2
import mediapipe as mp

# mediapipe 0.10.x "solutions" API: CPU only, no Metal (1.0.x crashes on macOS with "Service is unavailable").


def track(path, force=False):
    out = path + ".pose.npz"
    if os.path.exists(out) and not force and os.path.getmtime(out) >= os.path.getmtime(path):
        return out
    cap = cv2.VideoCapture(path)
    fps = cap.get(cv2.CAP_PROP_FPS) or 24.0
    w, h = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)), int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    xy, vis = [], []
    with mp.solutions.pose.Pose(static_image_mode=False, model_complexity=2, smooth_landmarks=True,
                                min_detection_confidence=0.5, min_tracking_confidence=0.5) as pose:
        while True:
            ok, frame = cap.read()
            if not ok:
                break
            res = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if res.pose_landmarks:
                p = res.pose_landmarks.landmark
                xy.append([[q.x * w, q.y * h] for q in p]); vis.append([q.visibility for q in p])
            else:
                xy.append([[np.nan, np.nan]] * 33); vis.append([0.0] * 33)
    np.savez_compressed(out, xy=np.array(xy, np.float32), vis=np.array(vis, np.float32), fps=fps, width=w, height=h)
    return out


if __name__ == "__main__":
    force = "--force" in sys.argv
    for p in [a for a in sys.argv[1:] if a != "--force"]:
        o = track(p, force)
        d = np.load(o)
        found = np.isfinite(d["xy"][:, 0, 0]).mean() * 100
        print(f"{os.path.basename(p)}: {len(d['xy'])} frames, pose found {found:.0f}% -> {os.path.basename(o)}")

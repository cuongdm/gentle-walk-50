#!/usr/bin/env python3
"""Write preview.json (720p) and 1080/preview_1080p.json for V3-1..V6-1.
Voice and caption blocks are copied from V2-1 so every clip shares the same voice and caption style.
Cue offsets are timed against each loop's measured phases (see docs/scripts/V-exercise-clips.md §5·0)."""
import json

base = json.load(open("assets/video/V2-1/preview.json"))
voice, cap = base["voice"], base["caption"]


def cues(lst):
    return [{"text": t, "at": a, "offset": o} for t, a, o in lst]


CFG = {
    "V3-1": dict(cycle=8.916667, intro=13.6, reps=3, outro=2.0, cues=cues([
        ("Seated leg extensions. The move you use for climbing stairs.", "intro", 0.5),
        ("Sit tall and hold the sides of your seat.", "intro", 4.6),
        ("Start with a small lift. Straighten your leg just halfway.", "intro", 8.2),
        ("If that's comfortable, straighten it all the way, toes to the ceiling.", "rep1", 0.1),
        ("Keep your leg pointing straight ahead… and lower it slowly.", "rep1", 4.8),
        ("Want more? Hold it up for a count of three.", "rep2", 0.4),
        ("If your knee complains, make the lift smaller. That still counts.", "rep3", 0.4)])),
    "V4-1": dict(cycle=7.625, intro=8.0, reps=3, outro=2.0, cues=cues([
        ("Heel and toe raises. The move you use for reaching a high shelf.", "intro", 0.5),
        ("Sit tall, feet flat on the floor.", "intro", 5.0),
        ("Lift your heels a little, then lower them.", "rep1", 0.2),
        ("Now the other way. Lift your toes, heels stay down.", "rep1", 3.8),
        ("Small and easy is perfect.", "rep2", 1.0),
        ("Want more? Stand behind your chair, hold on with both hands, and rise onto your toes.", "rep3", 0.4)])),
    "V5-1": dict(cycle=8.0, intro=14.0, reps=3, outro=2.0, cues=cues([
        ("Wall push-ups. They make pushing doors and lifting bags easier.", "intro", 0.5),
        ("Stand about an arm's length from the wall. Hands flat, at shoulder height.", "intro", 4.6),
        ("Start by standing a little closer. Bend your elbows just a bit.", "intro", 9.4),
        ("Bring your chest toward the wall… and press back.", "rep1", 0.2),
        ("Keep your body straight, like a plank of wood.", "rep1", 4.5),
        ("Want more? Step your feet back a little.", "rep3", 0.5)])),
    "V6-1": dict(cycle=8.291667, intro=9.0, reps=3, outro=2.0, cues=cues([
        ("Balance time. Stand behind your chair and hold on with both hands.", "intro", 0.5),
        ("Start easy. Lift just your heel, toes stay down.", "intro", 5.0),
        ("If you feel steady, lift your foot a little off the floor.", "rep1", 0.0),
        ("Look at one spot in front of you. It helps.", "rep1", 4.0),
        ("Hold… you're doing great… and set it down.", "rep2", 4.0),
        ("If you wobble, that's normal. Hold the chair a little tighter.", "rep3", 0.2),
        ("Want more? Try holding on with just one hand.", "rep3", 4.4)])),
}

for v, c in CFG.items():
    d = {"name": v, "loop": f"assets/video/{v}/{v}_loop.mp4",
         **{k: c[k] for k in ("cycle", "intro", "reps", "outro")},
         "voice": voice, "caption": cap, "cues": c["cues"]}
    json.dump(d, open(f"assets/video/{v}/preview.json", "w"), indent=2)
    h = dict(d, name=v + "_1080p", loop=f"assets/video/{v}/1080/{v}_loop_1080p.mp4",
             crf=17, preset="slow", audio_bitrate="192k")
    json.dump(h, open(f"assets/video/{v}/1080/preview_1080p.json", "w"), indent=2)
    print("wrote", v)

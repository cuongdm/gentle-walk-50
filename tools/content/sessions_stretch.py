"""Stretch templates (docs/scripts/A10-stretch.md §3, §8) and Morning stretch (A11-extras.md §3).

  ses.stretch.seated.<intensity>    Gentle seated stretch 6 (gentle) · Seated stretch 8 (steady, strong)
  ses.stretch.standing.<intensity>  Gentle standing stretch 6 · Standing stretch 8
  ses.cooldown / ses.cooldown.stand cool-down after a walk with chair moves (A10 §3.2)
  ses.morning                       Morning stretch 6

Holds (changed 06/10/2026 for women 58–75, review docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md
Q4/Q6): Gentle 20 s, Steady and Strong 30 s; a second round for the key poses at every intensity (Strong: every
held pose), so the main muscle groups get 40–60 s. Steady drops neck tilt and shoulder rolls, Strong also the
upper back, to keep sessions near 12 minutes (measured with --report: 9–12:15). Neck turn, chin tuck, shoulder rolls and ankles are slow repeated
moves without a hold (segment hold 0). Every held pose ends its hold with the "switch" or "release"
line, which the stretch player reads to show the countdown.
Python 3.9, standard library only.
"""
from timing import Seg, template

JR, KNEES, DIZZY, SHOULDERS, BACK, STANDING = ("jointReplacement", "knees", "dizzy", "shoulders", "lowerBack",
                                              "standingIsHard")
HOLD = {"gentle": 20, "steady": 30, "strong": 30}
BILATERAL = {"st.neck-turn", "st.neck-tilt", "st.twist", "st.side", "st.thigh", "st.ankle", "st.calf"}

# How each held pose is entered: setup and move lines, with the safer line for body limits.
POSES = {
    "st.neck-tilt": dict(setup=[("a10.neck-tilt.setup", None, [DIZZY, SHOULDERS]), ("a10.neck-tilt.easy", [DIZZY, SHOULDERS], None)],
                         move=[("a10.neck-tilt.move", None, None)]),
    "st.chest": dict(setup=[("a10.chest.setup", None, None)],
                     move=[("a10.chest.move", None, [SHOULDERS]), ("a10.chest.easy", [SHOULDERS], None)]),
    "st.upper-back": dict(setup=[("a10.upper-back.setup", None, None)],
                          move=[("a10.upper-back.move", None, [BACK, SHOULDERS]), ("a10.upper-back.easy", [BACK, SHOULDERS], None)]),
    "st.twist": dict(setup=[("a10.twist.setup", None, None)], move=[("a10.twist.move", None, None)],
                     after=[("a10.twist.easy", [BACK], None)]),
    "st.side": dict(setup=[("a10.side.setup", None, None)],
                    move=[("a10.side.move", None, [BACK, SHOULDERS]), ("a10.side.easy", [BACK, SHOULDERS], None)]),
    "st.thigh": dict(setup=[("a10.thigh.setup", None, None)],
                     move=[("a10.thigh.move", None, [BACK, KNEES]), ("a10.thigh.back", [BACK], None),
                           ("a10.thigh.easy", [KNEES], [BACK])]),
    "st.calf": dict(setup=[("a10.calf.setup", None, None)], move=[("a10.calf.move", None, None)],
                    after=[("a10.calf.easy", [KNEES], None)]),
    "st.overhead": dict(setup=[("a10.overhead.setup", None, [STANDING]), ("a10.overhead.seated", [STANDING], None)],
                        move=[("a10.overhead.move", None, [STANDING])], after=[("a10.overhead.easy", [SHOULDERS], None)]),
}
ROUND_TWO = {  # key poses held twice (06/10/2026: every intensity; sessions kept near 12 minutes)
    "seated": {"gentle": {"st.chest", "st.twist", "st.thigh"}, "steady": {"st.chest", "st.thigh"},
               "strong": {"st.chest", "st.twist", "st.thigh"}},
    "standing": {"gentle": {"st.calf", "st.chest"}, "steady": {"st.calf", "st.chest"},
                 "strong": {"st.calf", "st.chest", "st.twist"}},
}
SEATED = {
    "gentle": ["st.neck-turn", "st.chin-tuck", "st.chest", "st.twist", "st.thigh"],
    "steady": ["st.neck-turn", "st.chin-tuck", "st.chest", "st.twist", "st.thigh"],
    "strong": ["st.neck-turn", "st.chest", "st.twist", "st.thigh"],
}
STANDING_ORDER = {
    "gentle": ["st.calf", "st.overhead", "st.side", "st.chest", "st.neck-turn"],
    "steady": ["st.calf", "st.overhead", "st.side", "st.chest", "st.upper-back", "st.neck-turn"],
    "strong": ["st.calf", "st.overhead", "st.chest", "st.twist", "st.neck-turn"],
}


class Stretch:
    def __init__(self, voice, level, intensity):
        self.voice, self.level, self.intensity = voice, level, intensity
        self.hold = HOLD.get(intensity, 20)
        self.k = 0  # variant counter so neighbouring poses say different words

    def next_k(self):
        self.k += 1
        return self.k

    def build(self, seg, name):
        return seg.build(self.voice, self.level, None, name)

    def hold_slot(self, s, hold):
        """One hold: 'hold here' at the start, breathing lines by intensity, a countdown at the end."""
        k = self.next_k()
        lines = [(0, "a10.hold.start.%d" % (k % 2 + 1))]
        if hold >= 20:
            lines.append((8, "a10.hold.%d" % (k % 5 + 1)))
        if hold >= 30:
            lines.append((18, "a10.hold.%d" % ((k + 2) % 5 + 1)))
        lines.append((hold - (10 if hold >= 30 else 5), "a5.10s" if hold >= 30 else "a5.5s"))
        s.slot(hold, lines)

    def held(self, pid, hold=None, round_two=False, extra_after=(), open_line=None):
        hold = hold or self.hold
        d, key = POSES[pid], pid.split(".", 1)[1]
        s = Seg("stretch", pid, hold=hold)
        if open_line:
            s.line(open_line, at=0)
        if round_two:
            s.line("a10.again" if self.k % 2 else "a10.round2.%d" % (self.k % 2 + 1), at=0)
        else:
            s.line("a10.%s.intro" % key, at=None if open_line else 0)
            s.choice(d["setup"])
        if pid in BILATERAL:
            s.line("a10.left")
        into = "a10.into.%d" % (self.k % 2 + 1)
        if round_two:
            s.line(into, optional=True)
        else:
            s.choice(d["move"])
            for lid, only, not_ in extra_after:
                s.line(lid, only=only, not_=not_)
            after = [] if extra_after else d.get("after", [])
            if after:  # the safer line for a body limit takes the place of "ease into it"
                lid, only, _ = after[0]
                s.choice([(into, None, only), (lid, only, None)])
            else:
                s.line(into, optional=True)
        self.hold_slot(s, hold)
        if pid in BILATERAL:
            s.line("a10.switch.%d" % (self.k % 2 + 1))
            self.hold_slot(s, hold)
        s.line("a10.release.%d" % (self.k % 3 + 1))
        return self.build(s, "%s %s%s" % (self.level, pid, " round 2" if round_two else ""))

    def repeated(self, pid, count, every, move_line=None, only=None):
        """Neck turn, chin tuck, shoulder rolls: counted slow repeats, no hold."""
        key = pid.split(".", 1)[1]
        s = Seg("stretch", pid, hold=0, only=only)
        s.line("a10.%s.intro" % key, at=0).line("a10.%s.setup" % key)
        easy = {"st.neck-turn": [DIZZY, SHOULDERS], "st.shoulder-roll": [SHOULDERS]}.get(pid)
        move = move_line or "a10.%s.move" % key
        if easy:
            s.choice([(move, None, easy), ("a10.%s.easy" % key, easy, None)])
        else:
            s.line(move)
        s.line("a10.reps")
        for r in range(1, count + 1):
            s.slot(every, [(0, "a5.n.%d" % r)])
        s.line("a10.release.%d" % (self.next_k() % 3 + 1))
        return self.build(s, "%s %s" % (self.level, pid))

    def ankle(self, only=None, open_line=None):
        s = Seg("stretch", "st.ankle", hold=0, only=only)
        if open_line:
            s.line(open_line, at=0)
        s.line("a10.ankle.intro", at=None if open_line else 0).line("a10.ankle.setup")
        s.choice([("a10.ankle.move", None, [KNEES]), ("a10.ankle.easy", [KNEES], None)])
        s.wait(20).line("a10.switch.1").wait(20).line("a10.release.1")
        return self.build(s, "%s ankle" % self.level)

    def pose(self, pid, round_two):
        out = []
        if pid == "st.neck-turn":
            out.append(self.repeated(pid, 5, 5))
        elif pid == "st.chin-tuck":
            out.append(self.repeated(pid, 10, 4))
        elif pid == "st.shoulder-roll":
            out.append(self.repeated(pid, 5, 5))
        elif pid == "st.ankle":
            out.append(self.ankle())
        else:
            # Gentle: a small twist for everyone ("twist (nhỏ)", A10 §3.1).
            extra = [("a10.twist.easy", None, None)] if pid == "st.twist" and self.intensity == "gentle" else ()
            out.append(self.held(pid, extra_after=extra))
            if round_two:
                out.append(self.held(pid, round_two=True))
            if pid == "st.thigh":  # a joint replacement never gets the thigh stretch: ankles instead
                out.append(self.ankle(only=[JR]))
        return out

    def warm_up(self, seconds, standing):
        s = Seg("warmup", "wk.march")
        s.line("a10.warm.1", at=0).line("a1.05").line("a1.06").line("a2.warm.1", optional=True)
        if standing:
            s.line("a2.move.heel-dig.intro", optional=True).line("a2.move.heel-dig.inplace", optional=True)
        s.line("a2.warm.4", optional=True)
        s.line("a10.warm.end", at=seconds - 5)
        return s.build(self.voice, self.level, seconds, "%s warm-up" % self.level)

    def breathing(self):
        s = Seg("cooldown")
        s.line("a10.breathe.open", at=0).line("a10.breathe.how")
        s.line("a10.breathe.in").line("a10.breathe.out").line("a10.breathe.in").line("a10.breathe.out")
        s.line("a10.breathe.mid").wait(16).line("a10.breathe.end")
        return self.build(s, "breathing")

    def session(self, standing):
        full = self.intensity != "gentle"
        order = (STANDING_ORDER if standing else SEATED)[self.intensity]
        twice = ROUND_TWO["standing" if standing else "seated"][self.intensity]
        s = Seg("intro")
        s.line("a10.open.stand" if standing else "a10.open.1", at=0).line("a10.open.2").line("a7.dizzy")
        segments = [self.build(s, "open"), self.warm_up(90 if full else 60, standing)]
        for pid in order:
            if standing and pid == "st.overhead":
                r = Seg("rest")
                r.line("a10.to-wall", at=0)
                segments.append(self.build(r, "to the wall"))
            if standing and pid == "st.side":
                r = Seg("rest")
                r.line("a10.to-sit", at=0)
                segments.append(self.build(r, "to the seat"))
            segments += self.pose(pid, pid in twice)
        segments.append(self.breathing())
        o = Seg("outro")
        o.line("a10.close.1", at=0)
        segments.append(self.build(o, "close"))
        tid = "ses.stretch.%s.%s" % ("standing" if standing else "seated", self.intensity)
        return template(tid, "stretch", segments, self.level)


def cooldown(voice, standing):
    """After a walk and chair moves (A10 §3.2): calf or ankle 20 s, thigh 20 s, chest 15 s + 3 breaths."""
    st = Stretch(voice, "inplace" if standing else "seated", "steady")
    segments = []
    if standing:
        segments.append(st.held("st.calf", hold=20, open_line="a10.cool.open.stand"))
        r = Seg("rest")
        r.line("a10.to-sit", at=0)
        segments.append(st.build(r, "to the seat"))
    else:
        segments.append(st.ankle(open_line="a10.cool.open"))
    segments.append(st.held("st.thigh", hold=20))
    s = Seg("stretch", "st.chest", hold=15)
    s.line("a10.chest.intro", at=0).line("a10.chest.setup")
    s.choice([("a10.chest.move", None, [SHOULDERS]), ("a10.chest.easy", [SHOULDERS], None)])
    s.slot(15, [(0, "a10.hold.start.1"), (4, "a10.hold.1")])
    s.line("a10.release.2").line("a10.hold.1").wait(2).line("a10.cool.close")
    segments.append(st.build(s, "cool-down chest"))
    return template("ses.cooldown.stand" if standing else "ses.cooldown", "cooldown", segments,
                    "inplace" if standing else "seated")


def morning(voice):
    st = Stretch(voice, "seated", "gentle")
    segments = []
    s = Seg("intro")
    s.line("a9.extras", at=0).line("a11.morning.open").line("a11.morning.sit").wait(12)
    s.line("a11.morning.dizzy").line("a11.morning.gentle")
    segments.append(st.build(s, "morning open"))

    s = Seg("stretch", "st.neck-turn", hold=0)
    s.line("a10.neck-turn.intro", at=0).line("a10.neck-turn.setup")
    s.choice([("a11.neck-turn.reps", None, [DIZZY]), ("a10.neck-turn.easy", [DIZZY], None)]).line("a10.reps")
    for r in range(1, 6):
        s.slot(5, [(0, "a5.n.%d" % r)])
    segments.append(st.build(s, "morning neck turn"))

    s = Seg("stretch", "st.chin-tuck", hold=0)
    s.line("a10.chin-tuck.intro", at=0).line("a10.chin-tuck.setup").line("a10.chin-tuck.move")
    for r in range(1, 6):
        s.slot(4, [(0, "a5.n.%d" % r)])
    segments.append(st.build(s, "morning chin tuck"))

    s = Seg("stretch", "st.shoulder-roll", hold=0)
    s.line("a10.shoulder-roll.intro", at=0).line("a10.shoulder-roll.setup")
    s.choice([("a10.shoulder-roll.move", None, [SHOULDERS]), ("a10.shoulder-roll.easy", [SHOULDERS], None)])
    for r in range(1, 6):
        s.slot(5, [(0, "a5.n.%d" % r)])
    segments.append(st.build(s, "morning shoulder rolls"))

    s = Seg("stretch", "st.chest", hold=10)
    s.line("a10.chest.intro", at=0).line("a10.chest.setup")
    s.choice([("a10.chest.move", None, [SHOULDERS]), ("a10.chest.easy", [SHOULDERS], None)])
    s.slot(10, [(0, "a10.hold.start.1")])
    s.line("a10.release.1")
    segments.append(st.build(s, "morning chest"))
    s = Seg("stretch", "st.chest", hold=10)
    s.line("a10.again", at=0).slot(10, [(0, "a10.hold.start.2")]).line("a10.release.2")
    segments.append(st.build(s, "morning chest 2"))

    s = Seg("stretch", "st.twist", hold=0)
    s.line("a10.twist.intro", at=0).line("a10.twist.setup").line("a11.twist.reps").line("a10.twist.easy", only=[BACK])
    for r in range(1, 6):
        s.slot(5, [(0, "a5.n.%d" % r)])
    segments.append(st.build(s, "morning twist"))

    s = Seg("stretch", "wk.march", hold=0)
    s.line("a11.march.seated", at=0).slot(30, [(1, "a2.move.march.joint", [JR], None)])
    segments.append(st.build(s, "morning march"))

    s = Seg("stretch", "mv.leg-ext", hold=0)
    s.line("a4.v3.1", at=0).line("a4.v3.2").line("a4.v3.3").line("a4.v3.5")
    for side in range(2):
        if side:
            s.slot(3, [(0, "a5.side")])
        for r in range(1, 9):
            s.slot(3.5, [(0, "a5.n.%d" % r)])
    segments.append(st.build(s, "morning leg extension"))

    s = Seg("stretch", "st.ankle", hold=0)
    s.line("a10.ankle.intro", at=0).line("a10.ankle.setup")
    s.choice([("a10.ankle.move", None, [KNEES]), ("a10.ankle.easy", [KNEES], None)])
    for side in range(2):
        if side:
            s.slot(3, [(0, "a5.side")])
        for r in range(1, 11):  # points: about 2 s each, slow and smooth
            s.slot(2, [(0, "a5.n.%d" % r)])
        s.line("a11.ankle.circles")
        for r in range(1, 6):
            s.slot(2.5, [(0, "a5.n.%d" % r)])
    segments.append(st.build(s, "morning ankle"))

    s = Seg("stretch", "mv.sit-to-stand", hold=0)
    s.line("a11.morning.stand", at=0).line("a4.v1.4").line("a4.v1.5")
    for r in range(1, 4):
        s.slot(8, [(0, "a5.n.%d" % r)])
    s.line("a11.morning.lightheaded").line("a11.morning.still").wait(12).line("a11.morning.close")
    segments.append(st.build(s, "morning sit-to-stand"))
    return template("ses.morning", "stretch", segments, "seated")


def templates(voice):
    out = []
    for standing in (False, True):
        for intensity in ("gentle", "steady", "strong"):
            out.append(Stretch(voice, "inplace" if standing else "seated", intensity).session(standing))
    out += [cooldown(voice, False), cooldown(voice, True), morning(voice)]
    return out

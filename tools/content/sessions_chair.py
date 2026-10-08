"""Chair move templates (docs/scripts/A4-chair-moves.md §5) and Balance (A11-extras.md §2).

  ses.moves.<intensity>        one ready segment per chair move (SessionBuilder picks and orders them)
  ses.chair.<intensity>.open   opening lines and the seated warm-up march (1:00 / 1:30)
  ses.chair.rest.15 / .10      rest between moves (3 breaths)
  ses.chair.to-stand[.sts]     30 s change from sitting to standing behind the chair
  ses.chair.to-sit             30 s change back to the seat
  ses.chair.close              chest stretch, two breaths and the closing line (1:00)
  ses.balance.<intensity>      Balance (hand level per intensity, A11 §2.2; Otago moves added 06/10/2026, A11 §9)
  ses.steady-set.<intensity>.a / .b, ses.steady-set.seated
                               Steady set 2 (A11 §8): about two minutes of balance closing every planned day

Counted moves: the coach demonstrates one slow rep, then counts every rep at >= 6 s a rep
(STD §3.1, §7 rule 3). Reps (06/10/2026, review Q1, Otago 10 / NIA 10–15): Gentle 8, Steady 10, Strong 12;
sit-to-stand 6 / 8 / 2 sets of 8 with a minute's rest; one-sided moves split them between the legs.
Timed moves fill 45 s (Steady 40 s).
Python 3.9, standard library only.
"""
from timing import Seg, template

JR, KNEES, DIZZY, SHOULDERS, BACK, STANDING = ("jointReplacement", "knees", "dizzy", "shoulders", "lowerBack",
                                              "standingIsHard")
UNSTEADY = "unsteady"
INTENSITIES = ("gentle", "steady", "strong")
TIMED_SECONDS = {"gentle": 45, "steady": 40, "strong": 45}
REPS = {"gentle": 8, "steady": 10, "strong": 12}
STS_REPS = {"gentle": 6, "steady": 8, "strong": 8}
STS_SETS = {"gentle": 1, "steady": 1, "strong": 2}
SET_REST = 60      # seconds between sets (STEADI Chair Rise: rest for a minute)
TEMPO = 6          # seconds a rep (2-3 up, 1 hold, 3-4 down)
STS_TEMPO = 7      # sit-to-stand: stand, one breath, sit slowly

# Counted moves (A4 §3–§4), spoken in the order of A4 §3: intro → setup → "watch one first" + what
# the coach's slow rep shows → "now with me" + breathing → counting, with the easier version after
# rep 1, the harder one (Steady / Strong) and form tips between later reps, "last one" before the last.
# Lists are alternatives for body limits: (line, onlyFor, notFor) — exactly one of them plays.
REP_MOVES = {
    "mv.sit-to-stand": dict(intro="a4.v1.1", setup=[[("a4.v1.2", None, [JR]), ("a4.v1.var.joint", [JR], None)]],
                            demo=[[("a4.v1.4", None, [JR]), ("a4.v1.var.joint-lean", [JR], None)]],
                            breath="a4.v1.breath", easier=[("a4.v1.3", None, None)],
                            harder=[("a4.v1.7", None, [KNEES, JR]), ("a4.v1.6", [KNEES, JR], None)],
                            tips=[[("a4.v1.top", None, None)], [("a4.v1.5", None, None)]], done=None),
    "mv.wall-push": dict(intro="a4.v5.1", setup=[[("a4.v5.2", None, None)]],
                         demo=[[("a4.v5.4", None, [SHOULDERS]), ("a4.v5.var.shoulder", [SHOULDERS], None)]],
                         breath="a4.v5.breath", easier=[("a4.v5.3", None, None)],
                         harder=[("a4.v5.6", None, [SHOULDERS]), ("a4.v5.var.shoulder", [SHOULDERS], None)],
                         tips=[[("a4.v5.5", None, None)], [("a4.v5.heels", None, None)]], done=None),
    "mv.side-leg": dict(intro="a4.side-leg.intro", setup=[[("a4.stand.setup", None, None)], [("a4.side-leg.setup.1", None, None)]],
                        demo=[[("a4.side-leg.demo.1", None, None)]], breath="a4.side-leg.breath",
                        easier=[("a4.side-leg.easier", None, [JR]), ("a4.side-leg.var.joint", [JR], None)],
                        harder=[("a4.side-leg.harder", None, [DIZZY, JR]), ("a4.side-leg.form.2", [DIZZY, JR], None)],
                        tips=[[("a4.side-leg.form.1", None, None)], [("a4.side-leg.form.2", None, None)]],
                        done="a4.side-leg.done", sides=True),
    "mv.back-leg": dict(intro="a4.back-leg.intro", setup=[[("a4.stand.setup", None, None)], [("a4.back-leg.setup.1", None, None)]],
                        demo=[[("a4.back-leg.demo.1", None, None)]], breath="a4.back-leg.breath",
                        easier=[("a4.back-leg.easier", None, [BACK]), ("a4.back-leg.var.back", [BACK], None)],
                        harder=[("a4.back-leg.harder", None, [BACK]), ("a4.back-leg.form.1", [BACK], None)],
                        tips=[[("a4.back-leg.form.1", None, None)], [("a4.back-leg.form.2", None, None)]],
                        done="a4.back-leg.done", sides=True),
    "mv.knee-curl": dict(intro="a4.knee-curl.intro", setup=[[("a4.stand.setup", None, None)], [("a4.knee-curl.setup.1", None, None)]],
                         demo=[[("a4.knee-curl.demo.1", None, None)]], breath="a4.knee-curl.breath",
                         easier=[("a4.knee-curl.easier", None, [JR, KNEES]), ("a4.knee-curl.var.joint", [JR, KNEES], None)],
                         harder=[("a4.knee-curl.harder", None, [DIZZY, JR, KNEES]), ("a4.knee-curl.form.2", [DIZZY, JR, KNEES], None)],
                         tips=[[("a4.knee-curl.form.1", None, None)], [("a4.knee-curl.form.2", None, None)]],
                         done="a4.knee-curl.done", sides=True),
    "mv.mini-squat": dict(intro="a4.mini-squat.intro", setup=[[("a4.mini-squat.setup.1", None, None)]],
                          demo=[[("a4.mini-squat.demo.1", None, None)]], breath="a4.mini-squat.breath",
                          easier=[("a4.mini-squat.easier", None, [KNEES, JR]), ("a4.mini-squat.var.knees.1", [KNEES, JR], None)],
                          harder=[("a4.mini-squat.harder", None, [KNEES, JR]), ("a4.mini-squat.form.2", [KNEES, JR], None)],
                          tips=[[("a4.mini-squat.form.1", None, [KNEES]), ("a4.mini-squat.var.knees.2", [KNEES], None)],
                                [("a4.mini-squat.form.2", None, None)]],
                          done="a4.mini-squat.done"),
    "mv.arm-raise": dict(intro="a4.arm-raise.intro", setup=[[("a4.arm-raise.setup.1", None, None)]],
                         demo=[[("a4.arm-raise.demo.1", None, None)], [("a4.arm-raise.demo.2", None, None)]],
                         breath="a4.arm-raise.breath",
                         easier=[("a4.arm-raise.easier", None, [SHOULDERS]), ("a4.arm-raise.var.shoulder", [SHOULDERS], None)],
                         harder=[("a4.arm-raise.harder", None, [SHOULDERS]), ("a4.arm-raise.form.2", [SHOULDERS], None)],
                         tips=[[("a4.arm-raise.form.1", None, None)], [("a4.arm-raise.form.2", None, None)]],
                         done="a4.arm-raise.done"),
    "mv.row": dict(intro="a4.row.intro", setup=[[("a4.row.setup.1", None, None)], [("a4.row.setup.2", None, None)]],
                   demo=[[("a4.row.demo.1", None, None)]], breath="a4.row.breath", easier=[("a4.row.easier", None, None)],
                   harder=[("a4.row.harder", None, None)],
                   tips=[[("a4.row.form.1", None, None)], [("a4.row.form.2", None, None)]], done="a4.row.done"),
}

# Timed moves: lines in speaking order after the demo; "harder" is replaced by the chip line.
TIMED_MOVES = {
    "mv.knee-lift": dict(intro="a4.v2.1", setup="a4.v2.2", easier="a4.v2.3",
                         tips=["a4.v2.4", "a4.v2.5"], harder=("a4.v2.6", "a4.v2.var.joint", [JR]), ten="a4.v2.7"),
    "mv.leg-ext": dict(intro="a4.v3.1", setup="a4.v3.2", easier="a4.v3.3", breath="a4.v3.breath",
                       tips=["a4.v3.4", "a4.v3.5", "a4.v3.7"], harder=("a4.v3.6", None, [KNEES])),
    "mv.heel-toe": dict(intro="a4.v4.1", setup="a4.v4.2", easier="a4.v4.5",
                        tips=["a4.v4.3", "a4.v4.4"], harder=("a4.v4.6", "a4.v4.var.dizzy", [DIZZY])),
    "mv.single-leg": dict(intro="a4.v6.1", setup=None, easier="a4.v6.2", breath="a4.v6.breath",
                          tips=["a4.v6.3", "a4.v6.4", "a4.v6.5", "a4.v6.6"], harder=("a4.v6.7", "a4.v6.var.dizzy", [DIZZY])),
}
ORDER = ["mv.sit-to-stand", "mv.knee-lift", "mv.leg-ext", "mv.heel-toe", "mv.wall-push", "mv.single-leg",
         "mv.side-leg", "mv.back-leg", "mv.knee-curl", "mv.mini-squat", "mv.arm-raise", "mv.row"]


def rep_move(voice, mid, intensity, k, reps=None, sets=None):
    """A counted move; `reps`/`sets` override the intensity's amount (rep ladder steps)."""
    d = REP_MOVES[mid]
    sts = mid == "mv.sit-to-stand"
    reps = reps or (STS_REPS if sts else REPS)[intensity]
    sets = sets or (STS_SETS[intensity] if sts else 1)
    tempo = STS_TEMPO if sts else TEMPO
    s = Seg("move", mid, reps=reps, sets=sets if sets > 1 else None)
    s.line(d["intro"], at=0)
    for options in d["setup"]:
        s.choice(options)
    s.line("a4.demo.%d" % (k % 3 + 1))
    for options in d["demo"]:
        s.choice(options)
    s.wait(1.5)  # the coach's slow rep finishes
    s.line("a4.with-me.%d" % (k % 3 + 1)).line(d["breath"]).line("a4.count.1")
    # Lines between the counts: easier after rep 1, then the harder version or form tips, slow down.
    between = [d["easier"]]
    tips = list(d["tips"])
    if intensity != "gentle":
        between.append(d["harder"])
    between += tips + [[("a4.slow.%d" % (k % 2 + 1), None, None)]]
    sides = [reps // 2, reps - reps // 2] if d.get("sides") else [reps]
    for set_number in range(sets):
        if set_number:  # a minute seated, then the same set again
            s.slot(SET_REST, [(0, "a4.v1.rest"), (SET_REST - 6, "a4.v1.set2")])
        for side, count in enumerate(sides):
            if side:
                s.slot(4, [(0, "a5.side")])
            for r in range(1, count + 1):
                lines = [(0, "a5.n.%d" % r)]
                last_side = side == len(sides) - 1
                if last_side and r == count - 1:
                    lines.append((1.2, "a4.v1.8" if sts and set_number == sets - 1 else "a5.last"))
                elif r < count - 1 and between:
                    lines += [(1.2, lid, only, not_) for lid, only, not_ in between.pop(0)]
                s.slot(tempo, lines)
    if d["done"]:
        s.line(d["done"])
    return s.build(voice, None, None, "ses.moves.%s %s" % (intensity, mid))


def timed_move(voice, mid, intensity, k, seconds=None):
    d = TIMED_MOVES[mid]
    seconds = seconds or TIMED_SECONDS[intensity]
    s = Seg("move", mid)
    s.line(d["intro"], at=0)
    if d["setup"]:
        s.line(d["setup"], at=4)
    s.line("a4.demo.%d" % (k % 3 + 1), at=8).line(d["easier"])
    s.line("a4.with-me.%d" % (k % 3 + 1))
    if d.get("breath"):
        s.line(d["breath"], optional=True)
    tips = list(d["tips"])
    s.line(tips.pop(0))
    harder, chip, limits = d["harder"]
    if intensity != "gentle":
        options = [(harder, None, limits)] + ([(chip, limits, None)] if chip else [])
        s.choice(options)
    elif chip:
        s.line(chip, only=limits)
    for lid in tips:
        s.line(lid, optional=True)
    s.line(d.get("ten", "a5.10s.change"), at=seconds - 10)
    return s.build(voice, None, seconds, "ses.moves.%s %s" % (intensity, mid))


def library(voice, intensity):
    segments = []
    for k, mid in enumerate(ORDER):
        segments.append(rep_move(voice, mid, intensity, k) if mid in REP_MOVES else timed_move(voice, mid, intensity, k))
    return template("ses.moves.%s" % intensity, "chair", segments)


# Rep ladder steps (steady program, owner 08/10/2026); keep equal to RepLadder.steps(for:) in GentleWalkCore.
REP_STEPS = {
    "mv.sit-to-stand": [(1, 6), (1, 8), (1, 10), (2, 8), (2, 10)],
    "mv.mini-squat": [(1, 8), (1, 10), (1, 12), (2, 10)],
    "mv.side-leg": [(1, 8), (1, 10), (1, 12), (2, 10)],
}


def rep_variants(voice):
    """One template per rep ladder step, the move alone with the coach's counts: ses.reps.<id>.<sets>x<reps>.
    The first step speaks like a gentle day, the others like a steady day (they add the harder version)."""
    out = []
    for mid, steps in REP_STEPS.items():
        k = ORDER.index(mid)
        for index, (sets, reps) in enumerate(steps):
            intensity = "gentle" if index == 0 else "steady"
            seg = rep_move(voice, mid, intensity, k, reps=reps, sets=sets)
            out.append(template("ses.reps.%s.%dx%d" % (mid, sets, reps), "chair", [seg]))
    return out


def opening(voice, intensity):
    seconds = 60 if intensity == "gentle" else 90
    s = Seg("warmup", "wk.march")
    s.line("a9.chair.open", at=0).line("a4.pain.1").line("a7.stop.1").line("a7.stop.2")
    s.line("a4.warm.1").line("a1.04").line("a1.05").line("a1.06", optional=True).line("a4.warm.toe")
    s.line("a1.07", optional=True)
    if seconds > 60:
        s.line("a1.09", optional=True, not_=[JR]).line("a2.warm.1", optional=True)
    s.line("a4.warm.done", at=seconds - 6)
    return template("ses.chair.%s.open" % intensity, "chair", [s.build(voice, "seated", seconds, "chair open")], "seated")


def small(voice, tid, seconds, lines):
    s = Seg("rest")
    for n, (lid, at, optional) in enumerate(lines):
        s.line(lid, at=at, optional=optional)
    return template(tid, "chair", [s.build(voice, "seated", seconds, tid)], "seated")


def close(voice):
    s = Seg("stretch", "st.chest", hold=20)
    s.line("a9.to-stretch", at=0).line("a10.chest.setup")
    s.choice([("a10.chest.move", None, [SHOULDERS]), ("a10.chest.easy", [SHOULDERS], None)])
    s.slot(20, [(0, "a10.hold.start.1"), (8, "a10.hold.2"), (15, "a5.5s")])
    s.line("a10.release.2").line("a1.27").line("a1.28").line("a9.chair.close")
    return template("ses.chair.close", "cooldown", [s.build(voice, "seated", None, "chair close")], "seated")


# ---------------------------------------------------------------- Balance 6 (A11 §2)
HANDS = {  # A11 §2.2: which hands line per exercise and intensity
    "shift": ("two", "two", "one"), "tandem": ("two", "one", "tips"), "single": ("two", "two", "one"),
    "side": ("two", "one", "one"), "heeltoe": ("two", "two", "one"),
    "back": ("two", "two", "one"), "turn": ("two", "two", "one"), "heelwalk": ("two", "one", "one"),
}


def hands(s, which, intensity):
    level = HANDS[which][INTENSITIES.index(intensity)]
    if level == "two":
        s.line("a11.hands.two")
    else:  # someone who gets dizzy or feels unsteady keeps both hands on at every intensity
        s.choice([("a11.hands.%s" % level, None, [DIZZY, UNSTEADY]), ("a11.hands.two", [DIZZY, UNSTEADY], None)])


class BalanceParts:
    """Balance exercises as segments, shared by Balance and the Steady set (A11 §2, §8, §9)."""

    def __init__(self, voice, intensity, name):
        self.voice, self.intensity, self.name = voice, intensity, name

    def build(self, seg, label, level="inplace"):
        return seg.build(self.voice, level, None, "%s %s" % (self.name, label))

    def rest(self):
        r = Seg("rest")
        r.line("a11.hands.back", at=0)
        return r.build(self.voice, "inplace", 10, "%s rest" % self.name)

    def back_extension(self):
        """Otago back extension, five slow times, hands on the hips. Left out for dizziness or feeling
        unsteady (hands off the chair)."""
        s = Seg("stretch", "st.back-ext", hold=0, not_=[DIZZY, UNSTEADY])
        s.line("a11.back-ext.intro", at=0).line("a11.back-ext.move")
        s.choice([("a11.back-ext.small", None, None)])
        for r in range(1, 6):
            s.slot(5, [(0, "a5.n.%d" % r)])
        return self.build(s, "back extension")

    def shift(self):
        s = Seg("move", "wk.shift")
        hands(s, "shift", self.intensity)
        s.line("a11.balance.shift").wait(12)
        return self.build(s, "shift")

    def sit_to_stand(self, only=None):
        s = Seg("move", "mv.sit-to-stand", reps=5, only=only)
        s.line("a11.sts.intro", at=0)
        s.choice([("a4.v1.2", None, [JR]), ("a4.v1.var.joint", [JR], None)])
        if self.intensity == "strong":
            s.choice([("a11.sts.one", None, [DIZZY, UNSTEADY]), ("a11.sts.two", [DIZZY, UNSTEADY], None)])
        else:
            s.line("a11.sts.two")
        s.line("a4.v1.5")
        for r in range(1, 6):
            lines = [(0, "a5.n.%d" % r)]
            if r == 2 and self.intensity == "steady":
                lines.append((1.2, "a11.sts.one", None, [DIZZY, UNSTEADY]))
            if r == 4:
                lines.append((1.2, "a5.last"))
            s.slot(STS_TEMPO, lines)
        return self.build(s, "sit-to-stand")

    def tandem(self, rounds=2):
        s = Seg("move", "bl.tandem")
        s.line("a11.tandem.intro", at=0)
        hands(s, "tandem", self.intensity)
        s.line("a11.tandem.move").line("a11.tandem.jr", only=[JR]).line("a4.v6.4")
        for rnd in range(rounds):
            if rnd:
                s.line("a11.tandem.easy").line("a10.again").line("a11.tandem.move")
            s.slot(10, [(0, "a10.hold.start.2"), (5, "a5.5s")])
            s.line("a11.tandem.switch")
            s.slot(10, [(5, "a5.5s")])
        return self.build(s, "tandem")

    def single_leg(self, rounds=2, not_=None):
        s = Seg("move", "mv.single-leg", not_=not_)
        s.line("a11.single-leg.intro", at=0)
        hands(s, "single", self.intensity)
        s.line("a11.hands.keep").line("a4.v6.2" if self.intensity == "gentle" else "a4.v6.3").line("a4.v6.4")
        if self.intensity != "gentle":
            s.line("a11.recover", optional=True)
        for rnd in range(rounds):
            if rnd:
                s.line("a10.again")
                if self.intensity == "strong":
                    s.line("a4.v6.7", not_=[DIZZY, UNSTEADY])
            s.slot(10, [(1, "a4.v6.breath")] if rnd == 0 else [])
            s.line("a4.v6.5").line("a5.side")
            s.slot(10, [])
            s.line("a4.v6.5")
        return self.build(s, "single-leg")

    def side_walk(self):
        s = Seg("move", "bl.side-walk")
        s.line("a11.side-walk.intro", at=0)
        hands(s, "side", self.intensity)
        s.line("a11.side-walk.move").line("a11.side-walk.count").line("a11.side-walk.nocounter")
        s.slot(12, [(1, "a11.side-walk.easy", [DIZZY, UNSTEADY], None)])
        s.line("a5.half").wait(12).line("a10.again").wait(12).line("a5.half").wait(12)
        return self.build(s, "sideways walking")

    def back_walk(self):
        s = Seg("move", "bl.back-walk")
        s.line("a11.back-walk.intro", at=0)
        hands(s, "back", self.intensity)
        s.line("a11.back-walk.move").line("a11.back-walk.count")
        s.slot(14, [(1, "a11.back-walk.easy")])
        s.line("a5.half").wait(14)
        return self.build(s, "walking backwards")

    def walk_turn(self):
        s = Seg("move", "bl.walk-turn")
        s.line("a11.walk-turn.intro", at=0)
        hands(s, "turn", self.intensity)
        s.line("a11.walk-turn.move").line("a11.walk-turn.easy", only=[UNSTEADY])
        s.slot(15, [])
        s.line("a11.walk-turn.back").wait(15)
        return self.build(s, "walk and turn")

    def heel_toe_raises(self):
        s = Seg("move", "mv.heel-toe")
        s.line("a11.heel-toe.intro", at=0)
        hands(s, "heeltoe", self.intensity)
        s.line("a11.heel-toe.up")
        for r in range(1, 9):
            s.slot(3, [(0, "a5.n.%d" % r)])
        s.line("a4.v4.4")
        for r in range(1, 9):
            s.slot(3, [(0, "a5.n.%d" % r)])
        s.line("a4.v4.5")
        return self.build(s, "heel and toe raises")

    def heel_toe_walking(self):
        s = Seg("move", "bl.heel-toe-walking", not_=[UNSTEADY])
        s.line("a11.heel-walk.intro", at=0)
        hands(s, "heelwalk", self.intensity)
        s.line("a11.heel-walk.heels").wait(15)
        s.line("a11.heel-walk.toes").wait(15)
        s.line("a11.heel-walk.easy", optional=True)
        return self.build(s, "heel and toe walking")

    def close(self, level="inplace"):
        s = Seg("outro")
        s.line("a11.balance.sit", at=0).line("a10.hold.1").wait(4).line("a11.balance.close")
        return self.build(s, "close", level)


def balance(voice, intensity):
    """Balance (Pro extra). 06/10/2026: back extension in the warm-up for everyone; Steady adds walking
    backwards; Strong adds walk and turn and walking backwards, and walks on heels and toes (A11 §9)."""
    p = BalanceParts(voice, intensity, "ses.balance.%s" % intensity)
    s = Seg("move", "wk.shift")
    s.line("a9.extras", at=0).line("a4.stand.setup").line("a11.balance.place").line("a11.balance.reach")
    s.line("a7.dizzy").line("a11.balance.posture").line("a11.balance.breaths").wait(10)
    hands(s, "shift", intensity)
    s.line("a11.balance.shift").wait(12)
    segments = [p.build(s, "shift"), p.back_extension()]
    if intensity == "gentle":
        parts = [p.sit_to_stand, p.tandem, p.single_leg, p.side_walk, p.heel_toe_raises]
    elif intensity == "steady":
        parts = [p.sit_to_stand, p.tandem, p.single_leg, p.side_walk, p.back_walk, p.heel_toe_raises]
    else:
        parts = [p.sit_to_stand, p.tandem, p.single_leg, p.walk_turn, p.back_walk, p.heel_toe_walking, p.heel_toe_raises]
    for part in parts:
        segments.append(p.rest())
        segments.append(part())
    segments.append(p.close())
    return template("ses.balance.%s" % intensity, "balance", segments, "inplace")


def steady_set(voice, intensity, variant):
    """Steady set 2 (A11 §8): tandem stance once each foot, then sit-to-stand (.a) or single-leg stand
    (.b; sit-to-stand instead for dizziness or feeling unsteady). Closes every planned day."""
    p = BalanceParts(voice, intensity, "ses.steady-set.%s.%s" % (intensity, variant))
    s = Seg("intro")
    s.line("a11.steady.open", at=0).line("a11.balance.posture")
    segments = [p.build(s, "open"), p.tandem(rounds=1), p.rest()]
    if variant == "a":
        segments.append(p.sit_to_stand())
    else:
        segments.append(p.single_leg(rounds=1, not_=[DIZZY, UNSTEADY]))
        segments.append(p.sit_to_stand(only=[DIZZY, UNSTEADY]))
    segments.append(p.close())
    return template("ses.steady-set.%s.%s" % (intensity, variant), "balance", segments, "inplace")


def steady_set_seated(voice):
    """Steady set for "Standing for long is hard": seated knee lift and heel and toe raises, 40 s each."""
    s = Seg("intro")
    s.line("a11.steady.seated", at=0)
    open_seg = s.build(voice, "seated", None, "ses.steady-set.seated open")
    knee = timed_move(voice, "mv.knee-lift", "gentle", 0, seconds=40)
    heel = timed_move(voice, "mv.heel-toe", "gentle", 1, seconds=40)
    rest = Seg("rest")
    rest.line("a4.rest.1", at=0)
    o = Seg("outro")
    o.line("a10.hold.1", at=0).line("a11.balance.close")
    segments = [open_seg, knee, rest.build(voice, "seated", 10, "steady seated rest"), heel,
                o.build(voice, "seated", None, "ses.steady-set.seated close")]
    return template("ses.steady-set.seated", "chair", segments, "seated")


def templates(voice):
    out = [library(voice, i) for i in INTENSITIES] + [opening(voice, i) for i in INTENSITIES]
    out.append(small(voice, "ses.chair.rest.15", 15, [(("a4.rest.1"), 0, False), ("a9.next-move", 11, True)]))
    out.append(small(voice, "ses.chair.rest.10", 10, [("a4.rest.1", 0, False), ("a9.next-move", 7, True)]))
    out.append(small(voice, "ses.chair.to-stand", 30, [("a4.to-stand.1", 0, False), ("a4.to-stand.2", None, False),
                                                       ("a4.stand.setup", None, False), ("a4.stand.feet", None, True),
                                                       ("a4.stand.chair", None, True)]))
    out.append(small(voice, "ses.chair.to-stand.sts", 30, [("a4.to-stand.behind", 0, False), ("a4.to-stand.2", None, False),
                                                           ("a4.stand.feet", None, True), ("a4.stand.chair", None, True)]))
    out.append(small(voice, "ses.chair.to-sit", 30, [("a4.to-sit.1", 0, False), ("a4.to-sit.2", None, False)]))
    out.append(close(voice))
    out += [balance(voice, i) for i in INTENSITIES]
    out += [steady_set(voice, i, v) for i in INTENSITIES for v in ("a", "b")]
    out.append(steady_set_seated(voice))
    out += rep_variants(voice)
    return out

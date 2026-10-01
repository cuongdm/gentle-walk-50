"""Walk templates of docs/scripts/A2-walk.md §3: ses.walk.<level>.<pace> for level seated / inplace / pad
and pace gentle (Gentle walk 5), steady (Steady walk 8), strong (Strong walk 10), long (Longer walk 15)
and commercial (Commercial break walk 5, A11 §4).

Every move block carries its move (wk.*) so the player shows that move's clip; the warm-up and the
slow part of the cool-down march (wk.march); the cool-down stretches carry their pose (st.*).
Python 3.9, standard library only.
"""
from timing import Seg, template

JR, KNEES, DIZZY, SHOULDERS, STANDING = "jointReplacement", "knees", "dizzy", "shoulders", "standingIsHard"

FRAMES = {  # warm-up s, (easy s, quicker s) per block, cool-down s, moves (A2 §3.1)
    "gentle": (60, (60, 0), 60, ["march", "heel-dig", "side-step"]),
    "commercial": (60, (60, 0), 60, ["march", "heel-dig", "shift"]),
    "steady": (120, (40, 20), 120, ["march", "side-step", "knee-lift", "heel-dig"]),
    "strong": (120, (30, 30), 120, ["march", "side-step", "knee-lift", "heel-dig", "toe-tap", "heel-back"]),
    "long": (180, (60, 30), 180, ["march", "side-step", "knee-lift", "heel-dig", "toe-tap", "shift"]),
}
# Safer line that replaces "harder" (or joins the easy slot) for a body limit (A2 §3.7).
CHIP_LINE = {
    "march": ("a2.move.march.joint", [JR]), "knee-lift": ("a2.move.knee-lift.joint", [JR]),
    "heel-back": ("a2.move.heel-back.joint", [JR]), "toe-tap": ("a2.move.toe-tap.knees", [KNEES]),
    "side-step": ("a2.move.side-step.dizzy", [DIZZY]), "arms": ("a2.move.arms.shoulders", [SHOULDERS]),
}
TWO_DEMOS = {"side-step", "heel-back", "shift"}  # demo lines written per level


class Walk:
    def __init__(self, voice, level, pace):
        self.voice, self.level, self.pace = voice, level, pace
        self.move_level = "seated" if level == "seated" else "inplace"
        warm, (easy, quick), cool, moves = FRAMES[pace]
        if level == "pad":  # the belt: march and arms only (plan §2.1, STD §2.5)
            moves = ["march" if i % 2 == 0 else "arms" for i in range(len(moves))]
        self.warm, self.easy, self.quick, self.cool, self.moves = warm, easy, quick, cool, moves

    # ------------------------------------------------------------ helpers
    def nth(self, family, k):
        """k-th variant of a rotating family that fits the level (the app rotates from there)."""
        ids = self.voice.family(family, self.level)
        if not ids:
            raise SystemExit("no line of %s fits %s" % (family, self.level))
        return ids[k % len(ids)]

    def ok(self, lid):
        return self.voice.fits(lid, self.level)

    def name(self, suffix):
        return "ses.walk.%s.%s%s" % (self.level, self.pace, suffix)

    def build(self):
        segments = [self.warm_up()]
        for i, move in enumerate(self.moves):
            segments += self.block(i, move)
        segments += self.cool_down()
        return template("ses.walk.%s.%s" % (self.level, self.pace), "walk", segments, self.level)

    # ------------------------------------------------------------ warm-up (A2 §3.3)
    def warm_up(self):
        s, L = Seg("warmup", "wk.march"), self.level
        long, short = self.warm >= 180, self.warm <= 60
        if self.pace == "commercial":
            s.line("a11.break.open.1", at=0).line("a11.break.open.2")
        else:
            s.line("a2.long.open" if long else "a2.open.1", at=0)
        if L == "pad":
            s.line("a7.pad.start", at=6).line("a7.pad.slow").line("a2.setup.pad.1")
            s.line("a7.pad.rail", optional=short)
            if not short:
                s.line("a7.pad.clip", optional=True).line("a7.pad.phone", optional=True).line("a2.pad.moves")
        else:
            s.line(self.nth("a2.setup.%s" % L, 0), at=6)
            if L == "seated":
                s.line("a2.setup.seated.joint", only=[JR])
            if not short:
                if L == "seated":
                    s.line(self.nth("a2.setup.seated", 2), at=16)
                else:
                    s.line(self.nth("a2.setup.inplace", 2), at=16).line("a2.setup.inplace.shoes")
        s.line("a4.pain.1", at=16 if short else 26).line("a4.pain.2", optional=short)
        if not short:
            if L == "pad":
                s.line("a7.pad.dizzy")
            else:
                s.line("a7.stop.1").line("a7.stop.2")
        if short:
            if L == "seated":
                s.line("a1.04", at=26).line("a1.05", at=38, optional=True)
            else:
                s.line("a2.warm.1", at=26).line("a2.warm.2", optional=True).line("a2.warm.8", optional=True)
            s.line("a2.move.march.next", at=self.warm - 10)
            return s.build(self.voice, L, self.warm, self.name(" warm-up"))
        seated = L == "seated"
        firsts = ["a1.04", "a1.05", "a1.08"] if seated else ["a2.warm.1", "a2.warm.2", "a2.warm.6"]
        for k, lid in enumerate(firsts):
            s.line(lid, at=36 + 11 * k, optional=True)
        arms_at = 70 if not long else 100
        s.line("a2.move.arms.intro", at=arms_at)
        s.line("a2.move.arms.pad" if L == "pad" else "a2.move.arms.swing")
        rest = ["a1.07", "a1.09", "a1.10", "a1.11"]
        if long:
            rest = ["a2.warm.3", "a2.warm.5", "a2.warm.4", "a2.warm.7"] + rest
        for lid in rest:
            s.line(lid, optional=True, not_=[JR] if lid == "a1.09" else None)
        s.line("a2.move.march.next", at=self.warm - 10)
        return s.build(self.voice, L, self.warm, self.name(" warm-up"))

    # ------------------------------------------------------------ move blocks (A2 §3.4)
    def block(self, i, m):
        last = i == len(self.moves) - 1
        nxt = None if last else self.moves[i + 1]
        if self.quick == 0:
            return [self.easy_only(i, m, nxt)]
        return [self.easy_part(i, m), self.quick_part(i, m, nxt)]

    def opening(self, s, i, m):
        """Name, demo, "now with me" (skipped for the first March: she has marched since the warm-up)."""
        if i > 0 and self.pace == "long" and i in (2, 4):
            s.line("a2.long.round.%d" % (i // 2 + 1), at=0)
        s.line("a2.move.%s.intro" % m, at=0)
        if m == "arms" or (i == 0 and m == "march"):
            return
        demo = "a2.move.%s.demo.%s" % (m, self.move_level) if m in TWO_DEMOS else "a2.move.%s.demo" % m
        s.line(self.nth("a4.demo", i), at=3).line(demo)
        s.line(self.nth("a2.now", i), at=10)

    def posture(self, m):
        if m == "arms":
            return "a2.move.arms.pad" if self.level == "pad" else "a2.move.arms.soft"
        return "a2.move.%s.%s" % (m, self.move_level)

    def easy_line(self, s, m, at):
        """Easier version; with the move's body limit, its safety line instead."""
        easy = "a2.move.%s.easy" % m
        if m in CHIP_LINE:
            chip, limits = CHIP_LINE[m]
            s.choice([(easy, None, limits), (chip, limits, None)], at=at)
        else:
            s.line(easy, at=at)

    def harder_line(self, s, m, at, optional=False):
        """A little more (Steady / Strong); with the move's body limit, its safety line instead."""
        harder = "a2.move.%s.harder" % m
        options = [(harder, None, CHIP_LINE[m][1] if m in CHIP_LINE else None)] if self.ok(harder) else []
        if m in CHIP_LINE:
            options.append((CHIP_LINE[m][0], CHIP_LINE[m][1], None))
        if options:
            s.choice(options, at=at, optional=optional)

    def next_line(self, s, nxt, at):
        if nxt is None:
            return
        s.line("a2.move.%s.next" % nxt, at=at)

    def easy_only(self, i, m, nxt):
        """Gentle walk 5 / Commercial break: one easy minute per move, no quicker part."""
        s = Seg("easy", "wk.%s" % m)
        self.opening(s, i, m)
        if m == "arms":
            s.choice([("a2.move.arms.swing", None, [SHOULDERS]), ("a2.move.arms.shoulders", [SHOULDERS], None)], at=3)
        s.line(self.posture(m), at=16)
        if m != "arms":
            s.line("a2.move.%s.easy" % m, at=28)
        if self.pace == "commercial" and i == 1:
            s.line("a11.break.mid", at=40)
        elif m in CHIP_LINE and m != "arms":
            chip, limits = CHIP_LINE[m]
            s.choice([(self.nth("a2.gentle", i), None, limits), (chip, limits, None)], at=40)
        else:
            s.line(self.nth("a2.gentle", i), at=40, optional=True)
        if nxt:
            self.next_line(s, nxt, self.easy - 10)
        else:
            s.line("a1.24", at=self.easy - 8)
        return s.build(self.voice, self.level, self.easy, self.name(" block %d" % (i + 1)))

    def easy_part(self, i, m):
        s = Seg("easy", "wk.%s" % m)
        self.opening(s, i, m)
        if m == "arms":
            s.choice([("a2.move.arms.swing", None, [SHOULDERS]), ("a2.move.arms.shoulders", [SHOULDERS], None)], at=3)
        if self.pace == "long":
            s.line(self.posture(m), at=18)
            if m != "arms":
                self.easy_line(s, m, 30)
            s.line("a2.long.half" if i == 3 else self.nth("a2.easy.mid", i), at=42, optional=i != 3)
            soon_at = 50
        elif self.quick == 20:  # Steady: 40 easy / 20 quicker
            s.line(self.posture(m), at=16)
            if m != "arms":
                self.easy_line(s, m, 24)
            soon_at = 30
        else:  # Strong: 30 / 30
            if i % 2 == 0 or m == "arms":
                s.line(self.posture(m), at=15)
            else:
                self.easy_line(s, m, 15)
            soon_at = 20
        if i == 0:
            soon = "a1.12"
        elif self.quick == 30 and i % 3 == 1:
            soon = "a1.18"  # "Just thirty seconds": only where the quicker part is 0:30
        elif i % 2:
            soon = self.nth("a2.round", i)
        else:
            soon = self.nth("a2.soon", i)
        s.line(soon, at=soon_at)
        return s.build(self.voice, self.level, self.easy, self.name(" block %d easy" % (i + 1)))

    def quick_part(self, i, m, nxt):
        s, L = Seg("brisk", "wk.%s" % m), self.level
        last = nxt is None
        if i == 0:
            s.line(self.nth("a2.brisk.%s" % L, 0), at=0)
        elif last:
            s.line("a2.brisk.last", at=0)
        elif i % 2:
            s.line(self.nth("a2.brisk.again", i), at=0)
        else:
            s.line("a1.19", at=0)
        if L == "pad" and i == 0:
            s.line("a7.pad.slow", optional=True)
        # Talk test: A1's short "Still able to talk?" fits a 0:20 quicker part; longer parts use A2's.
        talk = "a1.14" if self.quick == 20 else "a2.talk.seated" if L == "seated" else self.nth("a2.talk", i // 2)
        mid_at = 6 if self.quick == 20 else 8 if self.pace == "long" else 14
        if self.quick == 30 and self.pace != "long":
            self.harder_line(s, m, 6)
        # The talk test and the "can't catch your breath" line always play (the next-move warning may
        # then come at 0:08 instead of 0:10).
        if i % 2 == 0:
            s.line(talk, at=mid_at)
        elif i == 1:
            s.line("a7.stop.breath", at=mid_at)
        elif self.quick == 20 or self.pace == "long":
            self.harder_line(s, m, mid_at, optional=True)
        else:
            s.line(self.nth("a2.brisk.mid", i), at=mid_at, optional=True)
        if last:
            s.line(self.nth("a2.brisk.end", 0), at=self.quick - 10)
        else:
            self.next_line(s, nxt, self.quick - 10)
        return s.build(self.voice, L, self.quick, self.name(" block %d quicker" % (i + 1)))

    # ------------------------------------------------------------ cool-down (A2 §3.5)
    def cool_down(self):
        L = self.level
        walk_s = 30 if self.cool <= 60 else 60 if self.cool <= 120 else 90
        s = Seg("cooldown", "wk.march")
        s.line("a2.cool.pad.1" if L == "pad" else self.nth("a2.cool.%s" % self.move_level, 0), at=0)
        mids = [self.nth("a2.cool.mid", 0), "a1.17", "a1.26", "a1.23"] if walk_s > 30 else ["a1.26"]
        if walk_s > 60:
            mids += [self.nth("a2.cool.mid", 1), "a2.warm.7"]
        for k, lid in enumerate(mids):
            s.line(lid, at=10 + 12 * k, optional=True)
        if L == "pad":
            s.line("a7.pad.off", at=walk_s - 14).line("a2.cool.pad.2")
        else:
            s.line("a2.cool.feet", at=walk_s - 6)
        segments = [s.build(self.voice, L, walk_s, self.name(" cool-down walk"))]
        if self.cool > 60:
            if L == "seated":
                segments.append(self.ankle(first=True))
            else:
                segments.append(self.calf())
                segments.append(self.ankle(first=True, only=[STANDING]))
            if self.cool >= 180:
                segments.append(self.thigh())
        segments.append(self.chest())
        return segments

    def stretch_lead(self):
        """"Two gentle stretches" before calf/ankle + chest; "a few" when the thigh joins (Longer walk)."""
        return "a2.cool.stretch.1" if self.cool >= 180 else "a2.cool.stretch.2"

    def calf(self):
        s = Seg("cooldown", "st.calf")
        s.line(self.stretch_lead(), at=0)
        s.line("a10.calf.intro").line("a10.calf.setup").line("a10.calf.move").line("a10.calf.easy", only=[KNEES])
        s.line("a10.hold.start.1").wait(20).line("a10.switch.1").wait(20).line("a10.release.1")
        return s.build(self.voice, self.level, None, self.name(" calf"))

    def ankle(self, first, only=None):
        s = Seg("cooldown", "st.ankle", only=only)
        if first:
            s.line(self.stretch_lead(), at=0)
        s.line("a10.ankle.intro").line("a10.ankle.setup")
        s.choice([("a10.ankle.move", None, [KNEES]), ("a10.ankle.easy", [KNEES], None)])
        s.wait(20).line("a10.switch.1").wait(20).line("a10.release.1")
        return s.build(self.voice, self.level, None, self.name(" ankle"))

    def thigh(self):
        s = Seg("cooldown", "st.thigh")
        s.line("a10.thigh.intro", at=0).line("a10.thigh.setup")
        s.choice([("a10.thigh.move", None, ["lowerBack", KNEES]), ("a10.thigh.easy", ["lowerBack", KNEES], None)])
        s.line("a10.hold.start.1").wait(20).line("a10.switch.1").wait(20).line("a10.release.1")
        return s.build(self.voice, self.level, None, self.name(" thigh"))

    def chest(self):
        """Chest stretch with three breaths, then the closing line (A2 §3.5; the 1:00 cool-down goes
        straight from "let your feet come to rest" to the chest)."""
        s = Seg("cooldown", "st.chest")
        at = 0
        if self.level == "seated":
            s.line("a10.chest.setup", at=at)
            at = None
        s.choice([("a10.chest.move", None, [SHOULDERS]), ("a10.chest.easy", [SHOULDERS], None)], at=at)
        s.line("a2.cool.breath").wait(3).line("a1.27").wait(3).line("a2.cool.breath.last").wait(2)
        s.line(self.nth("a11.break.close", 0) if self.pace == "commercial" else self.nth("a2.close", 0))
        return s.build(self.voice, self.level, None, self.name(" chest"))


def templates(voice):
    return [Walk(voice, level, pace).build()
            for level in ("seated", "inplace", "pad") for pace in ("gentle", "steady", "strong", "long", "commercial")]

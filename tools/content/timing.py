"""Cue layout: places voice lines inside a segment so they never talk over each other and never run
past the segment (the app pushes a line that would overlap the previous one, so an overfull segment
would drift the voice away from the picture).

A segment is a list of items in speaking order:
  line(id, at=...)          earliest start in seconds from the segment start (default: right after the previous line)
  choice([(id, cond), ...]) lines for different body limits, spoken at the same moment (one plays)
  wait(seconds)             silence: a hold, reps, breathing
Optional lines are dropped when they would not fit before the next fixed line or the segment end.
Durations are the recorded ones when voice-lines.json has them, else estimated from the words.
Python 3.9, standard library only.
"""
import math

SECONDS_PER_WORD = 0.30   # Bella at speed 0.92: 71 recorded lines of 30/09/2026 fit 0.29 s/word + 0.67 s
LINE_OVERHEAD = 0.7
PAUSE_PER_ELLIPSIS = 0.6
GAP = 0.6                 # silence between two lines
ANCHOR_SLACK = 1.0
BELL_LEAD = 1.0           # a paced segment's first line waits for the bell (SessionTimeline.bellLead)
PACED = {"warmup", "brisk", "easy", "cooldown"}

# Same families as VoiceRotation.families (Swift): a cue may become any fitting variant.
FAMILIES = {
    "a2.open", "a2.setup.seated", "a2.setup.inplace", "a2.setup.pad", "a2.soon",
    "a2.brisk.seated", "a2.brisk.inplace", "a2.brisk.pad", "a2.brisk.again", "a2.brisk.mid", "a2.brisk.end",
    "a2.easy", "a2.easy.mid", "a2.round", "a2.close", "a2.now", "a2.gentle", "a2.talk",
    "a2.cool.seated", "a2.cool.inplace", "a2.cool.mid",
    "a4.demo", "a4.with-me", "a4.rest", "a4.slow",
    "a10.into", "a10.switch", "a10.hold.start", "a10.round2", "a10.close", "a11.break.close",
}

WARNINGS = []


class Voice:
    """Line book with durations: recorded when known, else estimated."""

    def __init__(self, lines):
        self.lines = {l["id"]: l for l in lines}

    def text(self, lid):
        if lid not in self.lines:
            raise SystemExit("unknown voice line in a session: %s" % lid)
        return self.lines[lid]["text"]

    def fits(self, lid, level):
        levels = self.lines[lid].get("levels")
        return level is None or not levels or level in levels

    def variants(self, lid, level):
        family, _, number = lid.rpartition(".")
        if family in FAMILIES and number.isdigit():
            ids = [i for i in self.lines if i.rpartition(".")[0] == family and i.rpartition(".")[2].isdigit()]
            ids = [i for i in ids if self.fits(i, level)]
            if lid in ids:
                return ids
        return [lid]

    def family(self, family, level):
        """Numbered variants of a family that fit the level, in number order."""
        ids = [i for i in self.lines if i.rpartition(".")[0] == family and i.rpartition(".")[2].isdigit()]
        return sorted((i for i in ids if self.fits(i, level)), key=lambda i: int(i.rpartition(".")[2]))

    def duration(self, lid, level=None):
        return max(self._one(i) for i in self.variants(lid, level))

    def _one(self, lid):
        line = self.lines[lid] if lid in self.lines else None
        if line is None:
            raise SystemExit("unknown voice line in a session: %s" % lid)
        if line.get("duration"):
            return float(line["duration"])
        text = line["text"]
        words = len(text.split())
        return words * SECONDS_PER_WORD + text.count("…") * PAUSE_PER_ELLIPSIS + LINE_OVERHEAD


class Seg:
    def __init__(self, kind, exercise=None, hold=None, reps=None, only=None, not_=None, sets=None):
        self.kind, self.exercise, self.hold, self.reps, self.sets = kind, exercise, hold, reps, sets
        self.only, self.not_ = only, not_
        self.items = []

    def line(self, lid, at=None, optional=False, only=None, not_=None):
        self.items.append({"type": "line", "options": [(lid, only, not_)], "at": at, "optional": optional})
        return self

    def choice(self, options, at=None, optional=False):
        """options: [(id, only, not)] spoken at the same time; exactly one fits her limits."""
        self.items.append({"type": "line", "options": list(options), "at": at, "optional": optional})
        return self

    def wait(self, seconds):
        self.items.append({"type": "wait", "seconds": seconds})
        return self

    def slot(self, length, lines):
        """A fixed stretch of time (a rep, a hold) starting right after the previous line: lines are
        (offset, id[, only, not]) from its start; the next item starts when the slot ends."""
        self.items.append({"type": "slot", "length": length, "lines": [tuple(l) + (None,) * (4 - len(l)) for l in lines]})
        return self

    def build(self, voice, level, seconds=None, name="?"):
        """-> segment dict for sessions.json. seconds=None: length from the content (+1 s tail)."""
        cues, cursor = [], 0.0
        fixed_after = self._next_fixed_times()
        for index, item in enumerate(self.items):
            if item["type"] == "wait":
                cursor += item["seconds"]
                continue
            if item["type"] == "slot":
                slot_start = cursor + (GAP if cues else 0.0)
                inner, previous = slot_start, None
                for offset, lid, only, not_ in item["lines"]:
                    conditional = bool(only or not_)
                    if previous and conditional and previous[0] == offset and previous[2]:
                        at = previous[1]  # an alternative for other body limits: same moment
                    else:
                        at = int(math.ceil(max(slot_start + offset, inner + GAP if inner > slot_start else inner) - 1e-6))
                    previous = (offset, at, conditional)
                    cue = {"at": at, "line": lid}
                    if only:
                        cue["onlyFor"] = only
                    if not_:
                        cue["notFor"] = not_
                    cues.append(cue)
                    inner = max(inner, at + voice.duration(lid, level))
                if inner > slot_start + item["length"] + 3.0:  # a rep or hold a little longer is fine
                    WARNINGS.append("%s: slot of %.0f s overfull (%.1f s)" % (name, item["length"], inner - slot_start))
                cursor = max(inner, slot_start + item["length"]) - GAP
                continue
            dur = max(voice.duration(lid, level) for lid, _, _ in item["options"])
            start = cursor if not cues and cursor == 0 else cursor + GAP
            if item["at"] is not None:
                start = max(start, item["at"])
            at = int(math.ceil(start - 1e-6))
            lead = BELL_LEAD if at == 0 and self.kind in PACED else 0.0
            end = at + lead + dur
            # An optional line may push the next fixed line back by up to a second ("ten more seconds" at 0:09).
            limit = min(fixed_after[index] + ANCHOR_SLACK - GAP if fixed_after[index] is not None else 1e9,
                        (seconds - 0.3) if seconds is not None else 1e9)
            if item["optional"] and end > limit:
                continue
            if not item["optional"] and seconds is not None and end > seconds + 0.5:
                WARNINGS.append("%s: %s ends at %.1f s of %d" % (name, item["options"][0][0], end, seconds))
            for lid, only, not_ in item["options"]:
                cue = {"at": at, "line": lid}
                if only:
                    cue["onlyFor"] = only
                if not_:
                    cue["notFor"] = not_
                cues.append(cue)
            cursor = end
        length = seconds if seconds is not None else int(math.ceil(cursor + 1.0))
        seg = {"kind": self.kind, "seconds": length}
        if self.exercise:
            seg["exerciseID"] = self.exercise
        seg["cues"] = cues
        for key, value in (("hold", self.hold), ("reps", self.reps), ("sets", self.sets), ("onlyFor", self.only),
                           ("notFor", self.not_)):
            if value is not None:
                seg[key] = value
        return seg

    def _next_fixed_times(self):
        """For each item, the 'at' of the next mandatory line with a fixed time (None if none)."""
        out, upcoming = [None] * len(self.items), None
        for i in range(len(self.items) - 1, -1, -1):
            out[i] = upcoming
            item = self.items[i]
            if item["type"] == "line" and not item["optional"] and item["at"] is not None:
                upcoming = item["at"]
        return out


def template(tid, kind, segments, level=None):
    t = {"id": tid, "kind": kind}
    if level:
        t["level"] = level
    t["segments"] = segments
    return t

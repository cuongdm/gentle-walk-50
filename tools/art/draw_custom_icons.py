#!/usr/bin/env python3
"""Draw the custom body and limitation glyphs that Phosphor lacks (sources for build_icons.py).

Every glyph sits on Phosphor's 256 x 256 grid at Phosphor **Bold** weight (stroke 24, round caps and
joins, head = ring of outer radius 36 like Phosphor's people).

Body and limitation glyphs are TWO-TONE, like the Claude Design mock (SoreSpots.dc.html): a "base"
layer (the figure, shown in ink at ~55 %) and a "mark" layer (the sore spot / the meaning: knees,
hips band, lower-spine arc, clock, swirl, "no" badge..., shown solid sienna). The app stacks the two
template images (`LayeredIcon` in AppIcon.swift). Where the mark is hollow (the joint-replacement
ring) the base is cut away under it, like the mock's paper-filled ring.

Output in assets/icons/custom/ (plain paths, explicit black, no CSS, masks or currentColor):
    <name>-base.svg, <name>-base-fill.svg (solid head = selected state), <name>-mark.svg
    <name>.svg, <name>-fill.svg   single-colour fallback: base cut back around the mark with a gap
Glyphs without a mark (stretch, grandkids) only have <name>.svg and <name>-fill.svg.

    python3 tools/art/draw_custom_icons.py           # rewrite the SVG sources
    python3 tools/art/build_icons.py                 # then copy them into the asset catalog

Geometry follows claude-design/SoreSpots.dc.html (stick figure + highlighted spot) and the
"Anything else" set in docs/design/research-2026-10-08/icon-va-chong-nham-chan.md section 2c.
Stdlib only.
"""
import copy
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/icons/custom"

SW = 24.0          # Phosphor Bold stroke width on the 256 grid
HALF = SW / 2


def f(v):
    s = f"{v:.2f}".rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


# ---------- primitives ------------------------------------------------------------------------
class Line:
    def __init__(self, a, b):
        self.a, self.b = a, b

    def at(self, t):
        return (self.a[0] + (self.b[0] - self.a[0]) * t, self.a[1] + (self.b[1] - self.a[1]) * t)

    def piece(self, t0, t1):
        p, q = self.at(t0), self.at(t1)
        return f"M{f(p[0])} {f(p[1])}L{f(q[0])} {f(q[1])}"


class Quad:
    def __init__(self, a, c, b):
        self.a, self.c, self.b = a, c, b

    def at(self, t):
        u = 1 - t
        return (u * u * self.a[0] + 2 * u * t * self.c[0] + t * t * self.b[0],
                u * u * self.a[1] + 2 * u * t * self.c[1] + t * t * self.b[1])

    def piece(self, t0, t1):
        # sub-curve of a quadratic between t0..t1
        p0, p2 = self.at(t0), self.at(t1)
        # control point: derivative-based
        def d(t):
            u = 1 - t
            return (2 * u * (self.c[0] - self.a[0]) + 2 * t * (self.b[0] - self.c[0]),
                    2 * u * (self.c[1] - self.a[1]) + 2 * t * (self.b[1] - self.c[1]))
        dt = t1 - t0
        d0 = d(t0)
        p1 = (p0[0] + d0[0] * dt / 2, p0[1] + d0[1] * dt / 2)
        return f"M{f(p0[0])} {f(p0[1])}Q{f(p1[0])} {f(p1[1])} {f(p2[0])} {f(p2[1])}"


class Arc:
    """Circle arc, angles in degrees (0 = +x, clockwise on screen because y points down)."""
    def __init__(self, c, r, a0=0, a1=360):
        self.c, self.r, self.a0, self.a1 = c, r, a0, a1

    def ang(self, t):
        return math.radians(self.a0 + (self.a1 - self.a0) * t)

    def at(self, t):
        a = self.ang(t)
        return (self.c[0] + self.r * math.cos(a), self.c[1] + self.r * math.sin(a))

    def piece(self, t0, t1):
        span = abs(self.a1 - self.a0) * (t1 - t0)
        if span >= 359.99:
            cx, cy, r = self.c[0], self.c[1], self.r
            return (f"M{f(cx + r)} {f(cy)}A{f(r)} {f(r)} 0 1 1 {f(cx - r)} {f(cy)}"
                    f"A{f(r)} {f(r)} 0 1 1 {f(cx + r)} {f(cy)}")
        # split into pieces under 180 degrees so every SVG arc uses the small-arc flag
        sweep = 1 if self.a1 > self.a0 else 0
        n = max(1, int(span // 170) + 1)
        pts = [self.at(t0 + (t1 - t0) * k / n) for k in range(n + 1)]
        d = f"M{f(pts[0][0])} {f(pts[0][1])}"
        for k in range(1, n + 1):
            d += f"A{f(self.r)} {f(self.r)} 0 0 {sweep} {f(pts[k][0])} {f(pts[k][1])}"
        return d


# ---------- knockout regions (distance functions) --------------------------------------------
def dist_seg(p, a, b):
    ax, ay = a; bx, by = b; px, py = p
    dx, dy = bx - ax, by - ay
    L = dx * dx + dy * dy
    t = 0 if L == 0 else max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / L))
    return math.hypot(px - ax - t * dx, py - ay - t * dy)


class Disc:          # solid highlight disc
    def __init__(self, c, r):
        self.c, self.r = c, r

    def dist(self, p):
        return math.hypot(p[0] - self.c[0], p[1] - self.c[1]) - self.r

    def svg(self):
        cx, cy, r = self.c[0], self.c[1], self.r
        return (f"M{f(cx + r)} {f(cy)}A{f(r)} {f(r)} 0 1 1 {f(cx - r)} {f(cy)}"
                f"A{f(r)} {f(r)} 0 1 1 {f(cx + r)} {f(cy)}Z")


class Capsule:       # solid highlight bar with round ends (radius r)
    def __init__(self, a, b, r):
        self.a, self.b, self.r = a, b, r

    def dist(self, p):
        return dist_seg(p, self.a, self.b) - self.r

    def svg(self):
        (ax, ay), (bx, by), r = self.a, self.b, self.r
        ang = math.atan2(by - ay, bx - ax)
        nx, ny = -math.sin(ang) * r, math.cos(ang) * r
        return (f"M{f(ax + nx)} {f(ay + ny)}L{f(bx + nx)} {f(by + ny)}"
                f"A{f(r)} {f(r)} 0 0 0 {f(bx - nx)} {f(by - ny)}"
                f"L{f(ax - nx)} {f(ay - ny)}A{f(r)} {f(r)} 0 0 0 {f(ax + nx)} {f(ay + ny)}Z")


class Raw:           # solid raw path; distance from sample points (or an ellipse when rx/ry are given)
    def __init__(self, d, samples=(), r=0.0, evenodd=False, rx=None, ry=None):
        self.d, self.samples, self.r, self.evenodd, self.rx, self.ry = d, samples, r, evenodd, rx, ry

    def dist(self, p):
        if self.rx:
            c = self.samples[0]
            k = math.hypot((p[0] - c[0]) / self.rx, (p[1] - c[1]) / self.ry)
            return (k - 1) * min(self.rx, self.ry)
        if not self.samples:
            return 1e9
        best = 1e9
        for i in range(len(self.samples) - 1):
            best = min(best, dist_seg(p, self.samples[i], self.samples[i + 1]))
        return best - self.r

    def svg(self):
        return self.d


# ---------- clipping: cut strokes back around solid highlights ---------------------------------
def keep_intervals(prim, solids):
    """Parameter runs of `prim` that stay at least `solid.extra` away from every solid it does not ignore.
    Returns (t0, t1, cut_at_start, cut_at_end)."""
    regions = [s for s in solids if s not in getattr(prim, "ignore", ())]
    n = 800
    ok = [all(r.dist(prim.at(i / n)) >= r.extra for r in regions) for i in range(n + 1)]
    runs, start = [], None
    for i, v in enumerate(ok):
        if v and start is None:
            start = i
        if (not v or i == n) and start is not None:
            end = i if v else i - 1
            if end > start:
                runs.append((start / n, end / n, start != 0, end != n))
            start = None
    return runs


def svg_doc(strokes, solids, cut=()):
    """SVG text: strokes (cut back around `cut` regions, butt ends where cut) + solid shapes on top."""
    groups = {}            # (width, cap) -> path data
    caps = []
    for prim in strokes:
        sw = getattr(prim, "sw", SW)
        for t0, t1, cut0, cut1 in keep_intervals(prim, list(cut)):
            d = prim.piece(t0, t1)
            if cut0 or cut1:
                groups.setdefault((sw, "butt"), []).append(d)
                for was_cut, t in ((cut0, t0), (cut1, t1)):     # round cap only at the uncut ends
                    if not was_cut and not isinstance(prim, Arc):
                        caps.append(Disc(prim.at(t), sw / 2).svg())
            else:
                groups.setdefault((sw, "round"), []).append(d)
    parts = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">']
    for (sw, cap), ds in groups.items():
        parts.append(f'<path d="{"".join(ds)}" fill="none" stroke="#000000" stroke-width="{f(sw)}" '
                     f'stroke-linecap="{cap}" stroke-linejoin="round"/>')
    if caps:
        parts.append(f'<path d="{"".join(caps)}" fill="#000000"/>')
    for shape in solids:
        rule = ' fill-rule="evenodd"' if getattr(shape, "evenodd", False) else ""
        parts.append(f'<path d="{shape.svg()}" fill="#000000"{rule}/>')
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


class Ghost:
    """Knockout-only region along a sampled polyline (keeps strokes away from a stroked mark)."""
    def __init__(self, samples, r, extra):
        self.samples, self.r, self.extra = samples, r, extra

    def dist(self, p):
        return min(dist_seg(p, a, b) for a, b in zip(self.samples, self.samples[1:])) - self.r


class Glyph:
    """base: figure strokes + solids; mark: meaning strokes + solids; holes: where the base is cut away
    even in the layered version (under a hollow mark)."""
    def __init__(self, base, base_solids=(), mark=(), mark_solids=(), holes=()):
        self.base, self.base_solids = list(base), list(base_solids)
        self.mark, self.mark_solids, self.holes = list(mark), list(mark_solids), list(holes)

    @property
    def layered(self):
        return bool(self.mark or self.mark_solids)

    def flat_cut(self, gap):
        """Regions the single-colour version cuts the base around: every mark shape plus a gap."""
        regions = list(self.holes)
        for shape in self.mark_solids:
            regions.append(region(copy.copy(shape), gap))
        for prim in self.mark:
            pts = [prim.at(i / 60) for i in range(61)]
            regions.append(Ghost(pts, getattr(prim, "sw", SW) / 2, gap))
        return regions


# ---------- glyphs ----------------------------------------------------------------------------
FLAT_GAP = 10       # gap between base and mark in the single-colour fallback
FILL_HEAD_R = 32    # Phosphor Fill head


def region(shape, extra):
    shape.extra = extra
    return shape


def stroke(prim, width):
    prim.sw = width
    return prim


def head(fill, c, r=24):
    """Bold: Phosphor head ring (outer 36). Fill (selected): solid disc r 32 like Phosphor Fill."""
    return ([], [Disc(c, FILL_HEAD_R if r == 24 else r + 8)]) if fill else ([Arc(c, r)], [])


def ellipse(c, rx, ry):
    return Raw(f"M{f(c[0] + rx)} {f(c[1])}A{f(rx)} {f(ry)} 0 1 1 {f(c[0] - rx)} {f(c[1])}"
               f"A{f(rx)} {f(ry)} 0 1 1 {f(c[0] + rx)} {f(c[1])}Z", samples=[c, c], r=0, rx=rx, ry=ry)


# Front figure, the SoreSpots mock scaled to 256 (head, spine, arms down, legs apart).
HEAD = (128, 44)
SPINE = Line((128, 100), (128, 144))
ARM_L = Line((128, 108), (74, 140))
ARM_R = Line((128, 108), (182, 140))
HIP = (128, 144)
LEG_L = Line(HIP, (80, 238))
LEG_R = Line(HIP, (176, 238))


def figure(fill):
    hs, hd = head(fill, HEAD)
    return [SPINE, ARM_L, ARM_R, LEG_L, LEG_R] + hs, hd


GLYPHS = {}


def glyph(name):
    def deco(fn):
        GLYPHS[name] = fn
        return fn
    return deco


@glyph("body-knees")
def knees(fill):
    base, solids = figure(fill)
    return Glyph(base, solids, mark_solids=[Disc(LEG_L.at(0.52), 23), Disc(LEG_R.at(0.52), 23)])


@glyph("body-hips")
def hips(fill):
    base, solids = figure(fill)
    return Glyph(base, solids, mark_solids=[ellipse((128, 147), 46, 22)])


@glyph("body-shoulders")
def shoulders(fill):
    base, solids = figure(fill)
    return Glyph(base, solids, mark_solids=[Disc(ARM_L.at(0.4), 20), Disc(ARM_R.at(0.4), 20)])


@glyph("body-lower-back")
def lower_back(fill):
    # Side view facing right; the lower spine is a thick arc (the mock's 5/36 sienna stroke).
    hs, hd = head(fill, (140, 46))
    spine = Quad((136, 104), (110, 134), (124, 162))
    base = [spine, Line((134, 114), (162, 158)),                       # spine, arm hanging forward
            Line((124, 162), (106, 236)), Line((124, 162), (152, 236))] + hs
    arc = Quad(spine.at(0.42), (108, 146), (124, 166))
    return Glyph(base, hd, mark=[stroke(arc, 44)])


@glyph("body-joint-replacement")
def joint_replacement(fill):
    # Hollow sienna ring at the hip (base cut away inside it, like the mock's paper fill) + a dot at a knee.
    base, solids = figure(fill)
    ring = stroke(Arc(HIP, 22), 14)
    hole = region(Disc(HIP, 29), 0)
    return Glyph(base, solids, mark=[ring], mark_solids=[Disc(LEG_R.at(0.56), 14)], holes=[hole])


@glyph("limit-floor")
def floor(fill):
    # Kneeling: one knee down on the floor, the other foot flat in front. Mark = the floor.
    hs, hd = head(fill, (112, 48))
    base = [Line((114, 106), (120, 146)),          # torso
            Line((116, 114), (156, 140)),          # arm to the front knee
            Line((120, 146), (86, 182)),           # back thigh down to the knee on the floor
            Line((86, 182), (36, 182)),            # back shin flat along the floor
            Line((120, 146), (176, 140)),          # front thigh
            Line((176, 140), (180, 182))] + hs     # front shin to the foot
    return Glyph(base, hd, mark_solids=[Capsule((22, 222), (234, 222), 16)])


@glyph("limit-standing-long")
def standing_long(fill):
    hs, hd = head(fill, (76, 48))
    x = 76
    base = [Line((x, 108), (x, 150)), Line((x, 114), (x - 36, 160)), Line((x, 114), (x + 30, 156)),
            Line((x, 150), (x - 30, 226)), Line((x, 150), (x + 30, 226))] + hs
    c, r = (188, 132), 54
    d = (f"M{c[0] + r} {c[1]}A{r} {r} 0 1 1 {c[0] - r} {c[1]}A{r} {r} 0 1 1 {c[0] + r} {c[1]}Z"
         f"M{c[0] - 7} {c[1] + 7}L{c[0] - 7} {c[1] - 30}A7 7 0 0 1 {c[0] + 7} {c[1] - 30}"
         f"L{c[0] + 7} {c[1] - 7}L{c[0] + 24} {c[1] - 7}A7 7 0 0 1 {c[0] + 24} {c[1] + 7}Z")
    return Glyph(base, hd, mark_solids=[Raw(d, samples=[c, c], r=r, evenodd=True)])


class Spiral:
    """Archimedean spiral stroke, opening outward, clockwise on screen."""
    def __init__(self, c, r0, r1, turns, a0=0):
        self.c, self.r0, self.r1, self.turns, self.a0 = c, r0, r1, turns, a0

    def at(self, t):
        a = math.radians(self.a0) + t * self.turns * 2 * math.pi
        r = self.r0 + (self.r1 - self.r0) * t
        return (self.c[0] + r * math.cos(a), self.c[1] + r * math.sin(a))

    def piece(self, t0, t1):
        n = 48
        pts = [self.at(t0 + (t1 - t0) * k / n) for k in range(n + 1)]
        return "M" + "L".join(f"{f(x)} {f(y)}" for x, y in pts)


@glyph("limit-dizzy")
def dizzy(fill):
    # Figure with a swirl beside the head ("my head spins"). Mark = the swirl.
    hs, hd = head(fill, (96, 64))
    x = 96
    base = [Line((x, 124), (x, 164)), Line((x, 130), (x - 38, 172)), Line((x, 130), (x + 38, 172)),
            Line((x, 164), (x - 32, 236)), Line((x, 164), (x + 32, 236))] + hs
    return Glyph(base, hd, mark=[stroke(Spiral((196, 54), 5, 46, 1.1, a0=200), 26)])


@glyph("limit-unsteady")
def unsteady(fill):
    # Figure tipping to one side, arms out to catch her balance. Mark = wobble marks either side.
    hs, hd = head(fill, (112, 52))
    base = [Line((118, 110), (128, 152)), Line((120, 118), (66, 104)), Line((120, 118), (170, 140)),
            Line((128, 152), (100, 228)), Line((128, 152), (162, 224))] + hs
    marks = [stroke(Arc((128, 150), 108, 158, 198), 26), stroke(Arc((128, 150), 108, -18, 22), 26)]
    return Glyph(base, hd, mark=marks)


@glyph("limit-no-jumping")
def no_jumping(fill):
    # Jumping figure (arms up, knees tucked) above the floor. Mark = solid "no entry" badge.
    hs, hd = head(fill, (104, 62))
    x = 104
    base = [Line((x, 120), (x, 156)), Line((x, 126), (x - 40, 88)), Line((x, 126), (x + 40, 88)),
            Line((x, 156), (x - 32, 178)), Line((x - 32, 178), (x - 22, 206)),
            Line((x, 156), (x + 32, 178)), Line((x + 32, 178), (x + 22, 206)),
            Line((28, 236), (180, 236))] + hs
    c, r = (196, 64), 50
    d = (f"M{c[0] + r} {c[1]}A{r} {r} 0 1 1 {c[0] - r} {c[1]}A{r} {r} 0 1 1 {c[0] + r} {c[1]}Z"
         f"M{c[0] - 28} {c[1] - 10}L{c[0] + 28} {c[1] - 10}A10 10 0 0 1 {c[0] + 28} {c[1] + 10}"
         f"L{c[0] - 28} {c[1] + 10}A10 10 0 0 1 {c[0] - 28} {c[1] - 10}Z")
    return Glyph(base, hd, mark_solids=[Raw(d, samples=[c, c], r=r, evenodd=True)])


@glyph("stretch")
def stretch(fill):
    # Side bend: feet apart, body leaning right, one arm arching over the head, the other down.
    hs, hd = head(fill, (156, 64))
    base = [Line((142, 118), (122, 156)),           # torso, leaning
            Quad((138, 124), (74, 112), (108, 30)),  # arm over the head
            Line((136, 130), (186, 162)),           # arm down the side
            Line((122, 156), (78, 228)), Line((122, 156), (170, 228))] + hs
    return Glyph(base, hd)


@glyph("grandkids")
def grandkids(fill):
    # Adult (left) and a child (right) holding hands.
    hs, hd = head(fill, (84, 48))
    x, cx = 84, 184
    base = [Line((x, 108), (x, 150)), Line((x, 114), (x - 34, 158)), Line((x, 114), (146, 156)),
            Line((x, 150), (x - 28, 226)), Line((x, 150), (x + 28, 226)),
            Line((cx, 146), (cx, 184)), Line((cx, 152), (146, 156)), Line((cx, 152), (cx + 30, 180)),
            Line((cx, 184), (cx - 20, 226)), Line((cx, 184), (cx + 20, 226))] + hs
    return Glyph(base, hd + [Disc((cx, 106), 24 if fill else 21)])


def outputs():
    """File name -> SVG text for every glyph."""
    files = {}
    for name, draw in GLYPHS.items():
        for fill in (False, True):
            g = draw(fill)
            suffix = "-fill" if fill else ""
            files[f"{name}{suffix}.svg"] = svg_doc(g.base + g.mark, g.base_solids + g.mark_solids,
                                                   cut=g.flat_cut(FLAT_GAP) if g.layered else g.holes)
            if g.layered:
                files[f"{name}-base{suffix}.svg"] = svg_doc(g.base, g.base_solids, cut=g.holes)
                if not fill:
                    files[f"{name}-mark.svg"] = svg_doc(g.mark, g.mark_solids)
    return files


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    files = outputs()
    written = 0
    for name, svg in files.items():
        path = OUT / name
        if not path.exists() or path.read_text() != svg:
            path.write_text(svg)
            written += 1
    removed = [p for p in OUT.glob("*.svg") if p.name not in files]
    for p in removed:
        p.unlink()
    print(f"{len(GLYPHS)} glyphs, {len(files)} SVG files; {written} changed, {len(removed)} removed "
          f"in {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

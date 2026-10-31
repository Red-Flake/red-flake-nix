"""Build widgets/panel-background.svg for the Red Flake Noir Plasma style.

Usage: make-panel-svg.py <breeze panel-background.svg> <output> <fill opacity>

Starts from Breeze's file, so panels look like Breeze by default, and adds a
macOS-style dock frame:

  south-*         bottom panels ask for the "south" prefix first (the top
                  bar asks for "north", which falls back to Breeze): big
                  round corners, dark fill, thin light edge
  mask-south-*    the same shape as a solid mask, so blur behind the dock
                  gets the same round corners
  shadow corners  redrawn for the bigger radius. Only floating panels draw
                  shadow corners, so the top bar is not affected.

The input is Breeze's SVG from the Nix store (a trusted build input).
"""

import sys
import xml.etree.ElementTree as ET

SVG_NS = "http://www.w3.org/2000/svg"
for prefix, uri in {
    "": SVG_NS,
    "xlink": "http://www.w3.org/1999/xlink",
    "inkscape": "http://www.inkscape.org/namespaces/inkscape",
    "sodipodi": "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
}.items():
    ET.register_namespace(prefix, uri)

RADIUS = 16
EDGE_WIDTH = 1
# Plasma turns the mask into a pixel region, counting half-covered edge
# pixels as inside, so blur would leak past the round corners. Inset it.
MASK_INSET = 1
EDGE = ("ColorScheme-Text", 0.12)  # thin light outline, like the macOS dock
FILL_CLASS = "ColorScheme-Background"
CONTENT_MARGIN = 4  # same as Breeze
CENTER = 10  # size of the stretched middle pieces in the file

# Breeze's panel shadow: 10px wide, black, fading out with these stops.
# At the panel edge the side gradients are at this position (light from above:
# faint on top, strongest at the bottom).
SHADOW = 10
SHADOW_STOPS = [(0, 0.2), (1 / 3, 0.1), (0.5, 0.05), (7 / 12, 0.025), (1, 0)]
SHADOW_START = {"top": 0.4, "bottom": 0.0, "left": 0.2, "right": 0.2}

CORNERS = {  # name: (mirror x, mirror y)
    "topleft": (False, False),
    "topright": (True, False),
    "bottomleft": (False, True),
    "bottomright": (True, True),
}


def el(tag, **attrs):
    e = ET.Element("{%s}%s" % (SVG_NS, tag))
    for k, v in attrs.items():
        e.set(k.replace("_", "-"), str(v))
    return e


def fill(d, cls, opacity):
    return el("path", d=d, **{"class": cls}, fill="currentColor", opacity=opacity)


class Mirror:
    """Write paths in top-left corner coordinates, get them for any corner."""

    def __init__(self, x0, y0, w, h, mx, my):
        self.x0, self.y0, self.w, self.h, self.mx, self.my = x0, y0, w, h, mx, my

    def p(self, u, v):
        x = self.x0 + (self.w - u if self.mx else u)
        y = self.y0 + (self.h - v if self.my else v)
        return f"{x:g},{y:g}"

    def sweep(self, s):
        return s if self.mx == self.my else 1 - s


def group(name, x, y, w, h):
    g = el("g", id=name)
    # invisible rect: fixes the element's size (same trick as Breeze)
    g.append(el("rect", x=x, y=y, width=w, height=h, fill="none"))
    return g


def frame_pieces(prefix, x0, y0, solid):
    """Nine pieces of the dock frame (or its mask when solid) at x0, y0."""
    r, c, e = RADIUS, CENTER, EDGE_WIDTH
    i = MASK_INSET if solid else 0
    cols = [x0, x0 + r, x0 + r + c]
    rows = [y0, y0 + r, y0 + r + c]
    out = []

    def paint(g, d, edge_d):
        if solid:
            g.append(el("path", d=d, fill="#000000"))
        else:
            g.append(fill(d, FILL_CLASS, OPACITY))
            if edge_d:
                g.append(fill(edge_d, *EDGE))

    # corners: quarter disk + quarter ring as the edge
    for name, (mx, my) in CORNERS.items():
        x, y = cols[2 if mx else 0], rows[2 if my else 0]
        m = Mirror(x, y, r, r, mx, my)
        s1, s0 = m.sweep(1), m.sweep(0)
        ra = r - i  # arc radius, same center
        d = f"M{m.p(r, r)} L{m.p(i, r)} A{ra},{ra} 0 0 {s1} {m.p(r, i)} Z"
        ri = r - e
        edge_d = (
            f"M{m.p(0, r)} A{r},{r} 0 0 {s1} {m.p(r, 0)} L{m.p(r, e)} "
            f"A{ri},{ri} 0 0 {s0} {m.p(e, r)} Z"
        )
        g = group(f"{prefix}{name}", x, y, r, r)
        paint(g, d, edge_d)
        out.append(g)

    # sides: full rect + edge strip on the outer side
    sides = {
        "top": (cols[1], rows[0], c, r, (0, 0, c, e)),
        "bottom": (cols[1], rows[2], c, r, (0, r - e, c, e)),
        "left": (cols[0], rows[1], r, c, (0, 0, e, c)),
        "right": (cols[2], rows[1], r, c, (r - e, 0, e, c)),
        "center": (cols[1], rows[1], c, c, None),
    }
    for name, (x, y, w, h, strip) in sides.items():
        g = group(f"{prefix}{name}", x, y, w, h)
        # the mask leaves out the outer MASK_INSET
        left = x + (i if name == "left" else 0)
        top = y + (i if name == "top" else 0)
        right = x + w - (i if name == "right" else 0)
        bottom = y + h - (i if name == "bottom" else 0)
        d = f"M{left},{top} H{right} V{bottom} H{left} Z"
        edge_d = None
        if strip:
            sx, sy, sw, sh = strip
            edge_d = f"M{x + sx},{y + sy} h{sw} v{sh} h{-sw} Z"
        paint(g, d, edge_d)
        out.append(g)
    return out


def shadow_corner(name, mx, my, x0, y0, defs):
    """Shadow tile for one corner: SHADOW outside the panel + RADIUS inside,
    filled around the rounded corner with a radial version of Breeze's fade."""
    r, s = RADIUS, SHADOW + RADIUS
    m = Mirror(x0, y0, s, s, mx, my)

    vertical = "bottom" if my else "top"
    horizontal = "right" if mx else "left"
    start = (SHADOW_START[vertical] + SHADOW_START[horizontal]) / 2
    reach = SHADOW * (1 - start)  # where the fade ends, outside the edge

    def alpha_at(t):
        for (o1, a1), (o2, a2) in zip(SHADOW_STOPS, SHADOW_STOPS[1:]):
            if o1 <= t <= o2:
                return a1 + (a2 - a1) * (t - o1) / (o2 - o1)
        return 0

    gid = f"rf-shadow-{name}"
    cx, cy = m.p(s, s).split(",")
    grad = el("radialGradient", id=gid, gradientUnits="userSpaceOnUse", cx=cx, cy=cy, r=r + reach)
    stops = [(start, alpha_at(start))] + [(o, a) for o, a in SHADOW_STOPS if o > start]
    for t, a in stops:
        dist = SHADOW * (t - start)
        grad.append(el("stop", offset=f"{(r + dist) / (r + reach):.4f}", style=f"stop-color:#000;stop-opacity:{a:.4f}"))
    defs.append(grad)

    g = group(f"shadow-{name}", x0, y0, s, s)
    d = (
        f"M{m.p(0, 0)} L{m.p(s, 0)} L{m.p(s, s - r)} "
        f"A{r},{r} 0 0 {m.sweep(0)} {m.p(s - r, s)} L{m.p(0, s)} Z"
    )
    g.append(el("path", d=d, fill=f"url(#{gid})"))
    return g


def main(src, dst, opacity):
    global OPACITY
    OPACITY = float(opacity)

    tree = ET.parse(src)
    root = tree.getroot()
    defs = root.find("{%s}defs" % SVG_NS)
    if defs is None:
        defs = el("defs")
        root.insert(0, defs)

    # Replace Breeze's shadow corners (drawn for its 6px radius)
    for parent in root.iter():
        for child in list(parent):
            if child.get("id") in {f"shadow-{n}" for n in CORNERS}:
                parent.remove(child)

    # New elements go right of Breeze's drawing (which also uses the space
    # below its viewBox), so element boxes don't overlap
    vb = [float(v) for v in root.get("viewBox").split()]
    x0 = vb[0] + vb[2] + 20
    y = vb[1]
    width = 2 * RADIUS + CENTER
    shadow_tile = SHADOW + RADIUS

    for g in frame_pieces("south-", x0, y, solid=False):
        root.append(g)
    for g in frame_pieces("mask-south-", x0 + width + 10, y, solid=True):
        root.append(g)
    y += width + 10

    for i, (name, (mx, my)) in enumerate(CORNERS.items()):
        root.append(shadow_corner(name, mx, my, x0 + i * (shadow_tile + 10), y, defs))
    y += shadow_tile + 10

    # Content margins: a rect's height (top/bottom) or width (left/right)
    m = CONTENT_MARGIN
    root.append(el("rect", id="south-hint-top-margin", x=x0, y=y, width=4, height=m, fill="#f0f"))
    root.append(el("rect", id="south-hint-bottom-margin", x=x0 + 10, y=y, width=4, height=m, fill="#f0f"))
    root.append(el("rect", id="south-hint-left-margin", x=x0 + 20, y=y, width=m, height=4, fill="#f0f"))
    root.append(el("rect", id="south-hint-right-margin", x=x0 + 30, y=y, width=m, height=4, fill="#f0f"))
    y += 20

    total_w = x0 + max(2 * (width + 10), 4 * (shadow_tile + 10)) - vb[0]
    total_h = max(vb[3], y - vb[1])
    root.set("viewBox", f"{vb[0]:g} {vb[1]:g} {total_w:g} {total_h:g}")
    root.set("width", f"{total_w:g}")
    root.set("height", f"{total_h:g}")
    tree.write(dst, encoding="utf-8", xml_declaration=False)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])

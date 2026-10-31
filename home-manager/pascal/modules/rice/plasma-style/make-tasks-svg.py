"""Build widgets/tasks.svg for the Red Flake Noir Plasma style.

Usage: make-tasks-svg.py <breeze tasks.svg> <output tasks.svg> <accent color>

Keeps Breeze's progress overlay and replaces the task state frames (the
full-height blocks behind running/active apps) with macOS-style dots:

  running     small dot under the icon
  active      the dot in the accent color
  minimized   faint dot
  attention   gold dot on a faint gold tile
  hover       soft rounded tile behind the icon (keeps the state's dot)
  pinned app  nothing until it runs

Breeze's "+" badge for apps with several windows is hidden: it sits on top of
the dot (hovering still lists all windows).

The dot is made of two half circles at the inner edges of the bottom corner
pieces. Corner pieces are half a task wide, so the halves meet in the middle
and form a circle. A wider task stretches it into a short pill.
Colors come from the color scheme (ColorScheme-* classes) except the accent.
The input is Breeze's SVG from the Nix store (a trusted build input).
"""

import re
import sys
import xml.etree.ElementTree as ET

SVG_NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG_NS)

STATES = r"(normal|focus|hover|attention|minimized|launcher)"
REPLACED = re.compile(r"^((north|south|east|west)-)?" + STATES + r"(-.*)?$")

TASK_WIDTH = 72  # dock task width in px (panel height 56, iconSpacing 2)
CORNER_W = TASK_WIDTH / 2
TILE_INSET = 2  # hover tile distance from the task edges
TILE_RADIUS = 12
CORNER_H = TILE_INSET + TILE_RADIUS
DOT = 4  # dot diameter
DOT_GAP = 2  # space between dot and task bottom
CENTER = 10  # size of the stretched middle pieces in the file

TEXT, NEUTRAL, ACCENT = "ColorScheme-Text", "ColorScheme-NeutralText", "accent"

# (prefix, hover tile (color, opacity) or None, dot (color, opacity) or None)
FRAMES = [
    ("normal", None, (TEXT, 0.5)),
    ("normal-hover", (TEXT, 0.07), (TEXT, 0.7)),
    ("focus", None, (ACCENT, 1.0)),
    ("focus-hover", (TEXT, 0.07), (ACCENT, 1.0)),
    ("minimized", None, (TEXT, 0.3)),
    ("minimized-hover", (TEXT, 0.07), (TEXT, 0.45)),
    ("attention", (NEUTRAL, 0.12), (NEUTRAL, 1.0)),
    ("attention-hover", (NEUTRAL, 0.18), (NEUTRAL, 1.0)),
    ("launcher-hover", (TEXT, 0.07), None),
    ("hover", (TEXT, 0.07), None),
]

# Icon padding inside a task (only "normal" is used for layout). The bottom
# leaves room for the dot.
MARGINS = {"top": 3, "bottom": 8, "left": 4, "right": 4}

EXTRA_STYLE = """
        .ColorScheme-NeutralText {
            color:#f67400;
        }"""


def el(tag, **attrs):
    e = ET.Element("{%s}%s" % (SVG_NS, tag))
    for k, v in attrs.items():
        e.set(k.replace("_", "-"), str(v))
    return e


def shape(d, color, opacity):
    if color == ACCENT:
        return el("path", d=d, fill=ACCENT_COLOR, opacity=opacity)
    return el("path", d=d, **{"class": color}, fill="currentColor", opacity=opacity)


def tile_path(name, x0, y0, x1, y1):
    """Part of the inset rounded tile that falls into one piece."""
    i, r = TILE_INSET, TILE_RADIUS
    left = x0 + i if name.endswith("left") else x0
    right = x1 - i if name.endswith("right") else x1
    top = y0 + i if name.startswith("top") else y0
    bottom = y1 - i if name.startswith("bottom") else y1
    if name == "topleft":
        return f"M{left},{top + r} A{r},{r} 0 0 1 {left + r},{top} H{right} V{bottom} H{left} Z"
    if name == "topright":
        return f"M{left},{top} H{right - r} A{r},{r} 0 0 1 {right},{top + r} V{bottom} H{left} Z"
    if name == "bottomleft":
        return f"M{left},{top} H{right} V{bottom} H{left + r} A{r},{r} 0 0 1 {left},{bottom - r} Z"
    if name == "bottomright":
        return f"M{left},{top} H{right} V{bottom - r} A{r},{r} 0 0 1 {right - r},{bottom} H{left} Z"
    return f"M{left},{top} H{right} V{bottom} H{left} Z"


def frame(prefix, tile, dot, y0):
    """Nine pieces of one frame, laid out in a row band starting at y0."""
    cw, ch, c = CORNER_W, CORNER_H, CENTER
    xs = [0, cw, cw + c, 2 * cw + c]  # column edges
    ys = [y0, y0 + ch, y0 + ch + c, y0 + 2 * ch + c]  # row edges
    names = [
        ["topleft", "top", "topright"],
        ["left", "center", "right"],
        ["bottomleft", "bottom", "bottomright"],
    ]
    groups = []
    for row in range(3):
        for col in range(3):
            x0, x1 = xs[col], xs[col + 1]
            t, b = ys[row], ys[row + 1]
            name = names[row][col]
            g = el("g", id="%s-%s" % (prefix, name))
            # invisible rect: fixes the element's size (same trick as Breeze)
            g.append(el("rect", x=x0, y=t, width=x1 - x0, height=b - t, fill="none"))

            if tile:
                g.append(shape(tile_path(name, x0, t, x1, b), *tile))

            if dot and row == 2:
                h = DOT / 2
                yc = b - DOT_GAP - h
                if name == "bottom":  # only drawn when the task is wider
                    d = f"M{x0},{yc - h} H{x1} V{yc + h} H{x0} Z"
                elif name == "bottomleft":  # left half, at the inner edge
                    d = f"M{x1},{yc - h} A{h},{h} 0 0 0 {x1},{yc + h} Z"
                else:  # bottomright: right half
                    d = f"M{x0},{yc - h} A{h},{h} 0 0 1 {x0},{yc + h} Z"
                g.append(shape(d, *dot))

            groups.append(g)
    return groups


def main(src, dst, accent):
    global ACCENT_COLOR
    ACCENT_COLOR = accent

    tree = ET.parse(src)
    root = tree.getroot()

    # Drop Breeze's state frames (and its margin hints), keep everything else
    for parent in root.iter():
        for child in list(parent):
            cid = child.get("id", "")
            if REPLACED.match(cid):
                parent.remove(child)

    # Hide the group badges, keeping their outline as an invisible shape so the
    # element keeps its size
    for badge in root.iter("{%s}g" % SVG_NS):
        if badge.get("id", "").startswith("group-expander-"):
            outline = badge[0]
            for child in list(badge)[1:]:
                badge.remove(child)
            outline.attrib.pop("opacity", None)
            outline.attrib.pop("class", None)
            outline.set("fill", "none")

    style = root.find("{%s}style" % SVG_NS)
    if style is not None and "ColorScheme-NeutralText" not in (style.text or ""):
        style.text = (style.text or "") + EXTRA_STYLE

    # Put the new frames below Breeze's drawing so element boxes don't overlap
    vb = [float(v) for v in root.get("viewBox").split()]
    y = vb[1] + vb[3] + 10
    for prefix, tile, dot in FRAMES:
        for g in frame(prefix, tile, dot, y):
            root.append(g)
        y += 2 * CORNER_H + CENTER + 10

    # Margin hints for "normal": a rect's height (top/bottom) or width
    # (left/right) is the margin
    root.append(el("rect", id="normal-hint-top-margin", x=0, y=y, width=4, height=MARGINS["top"], fill="#f0f"))
    root.append(el("rect", id="normal-hint-bottom-margin", x=10, y=y, width=4, height=MARGINS["bottom"], fill="#f0f"))
    root.append(el("rect", id="normal-hint-left-margin", x=20, y=y, width=MARGINS["left"], height=4, fill="#f0f"))
    root.append(el("rect", id="normal-hint-right-margin", x=30, y=y, width=MARGINS["right"], height=4, fill="#f0f"))
    # Stretch (not tile) the borders: no seams at fractional scaling
    root.append(el("rect", id="hint-stretch-borders", x=40, y=y, width=4, height=4, fill="#f0f"))
    y += 20

    root.set("viewBox", f"{vb[0]:g} {vb[1]:g} {max(vb[2], 2 * CORNER_W + CENTER + 10):g} {y - vb[1]:g}")
    tree.write(dst, encoding="utf-8", xml_declaration=False)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])

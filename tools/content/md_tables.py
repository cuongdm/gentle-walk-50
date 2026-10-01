"""Markdown tables of the script documents (docs/scripts, docs/plans), read by header.

Every table is returned with the heading it sits under, its header cells and its rows, so the
builders pick columns by name ("Câu thoại", "Ghi chú") instead of by position.
Python 3.9, standard library only.
"""
import re
from pathlib import Path

SEPARATOR = re.compile(r"^\|\s*:?-{2,}")


def cells(row):
    """'| a | b |' -> ['a', 'b'] (inner pipes inside backticks are not used in the scripts)."""
    return [c.strip() for c in row.strip().strip("|").split("|")]


class Table:
    def __init__(self, heading, header, rows):
        self.heading = heading
        self.header = header
        self.rows = rows

    def column(self, *names):
        """Index of the first header cell equal to (or starting with) one of the names; None if absent."""
        for name in names:
            for i, h in enumerate(self.header):
                if h == name or h.startswith(name):
                    return i
        return None

    def __repr__(self):
        return "Table(%r, %r, %d rows)" % (self.heading, self.header, len(self.rows))


def tables(path):
    """All tables of a Markdown file, in order."""
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    out, heading, i = [], "", 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("#"):
            heading = line.lstrip("#").strip()
        if line.startswith("|") and i + 1 < len(lines) and SEPARATOR.match(lines[i + 1]):
            header = cells(line)
            rows, j = [], i + 2
            while j < len(lines) and lines[j].startswith("|"):
                rows.append(cells(lines[j]))
                j += 1
            out.append(Table(heading, header, rows))
            i = j
            continue
        i += 1
    return out


def section_tables(path, heading_prefix):
    """Tables under headings that start with heading_prefix (until the next heading of any level)."""
    return [t for t in tables(path) if t.heading.startswith(heading_prefix)]


def strip_marks(text):
    """'mv.side-leg **(mới)**' -> 'mv.side-leg'; drops bold, backticks and trailing notes in brackets."""
    text = re.sub(r"\*\*\(.*?\)\*\*", "", text)
    return text.replace("**", "").replace("`", "").strip()

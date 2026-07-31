#!/usr/bin/env python3
"""Parse CBSE video-class-list PDFs into register JSON + JS for course-data.js."""
from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "_pdf_extract"
PDF_DIR = ROOT / "public" / "assets" / "pdfs"
DL = Path(r"C:\Users\ASUS\Downloads")

SOURCES = {
    "grade8_pcmb": DL / "1716007295-6648317fb9fde.pdf",
    "grade10_pcmb": DL / "1716008042-6648346a2a058.pdf",
    "grade11_pcmc": DL / "Grade_11_PCMC.pdf",
    "grade12_pcmb": DL / "1716008366-664835ae8b171.pdf",
    "grade12_pcmc": DL / "Grade_12_PCMC.pdf",
    "grade11_commerce": DL / "1716008402-664835d2299b5.pdf",
    "grade12_commerce": DL / "1716008448-66483600b8b2a.pdf",
}

COPY_AS = {
    "grade8_pcmb": "grade-8-pcmb.pdf",
    "grade10_pcmb": "grade-10-pcmb.pdf",
    "grade11_pcmc": "grade-11-pcmc.pdf",
    "grade12_pcmb": "grade-12-pcmb.pdf",
    "grade12_pcmc": "grade-12-pcmc.pdf",
    "grade11_commerce": "grade-11-commerce.pdf",
    "grade12_commerce": "grade-12-commerce.pdf",
}


def normalize_subject(s: str) -> str | None:
    s = re.sub(r"\s+", "", s).strip().upper()
    s = s.replace("MATHAMATICS", "MATHEMATICS").replace("MATHMATICS", "MATHEMATICS")
    if "MATH" in s:
        return "maths"
    if "PHYS" in s:
        return "physics"
    if "CHEM" in s:
        return "chemistry"
    if "BIO" in s:
        return "biology"
    if "COMPUTER" in s:
        return "computer"
    if "ACCOUNT" in s:
        return "accountancy"
    if "ENGLISH" in s or "GRAMMAR" in s:
        return "english"
    return None


def page_items(page):
    items = []

    def visitor(text, cm, tm, fontDict, fontSize):
        if text and text.strip():
            items.append({"y": tm[5], "x": tm[4], "t": text})

    page.extract_text(visitor_text=visitor)
    return items


def cluster_rows(items, y_tol=3.0):
    items = sorted(items, key=lambda i: (-i["y"], i["x"]))
    rows = []
    for it in items:
        if not rows or abs(rows[-1]["y"] - it["y"]) > y_tol:
            rows.append({"y": it["y"], "parts": [it]})
        else:
            rows[-1]["parts"].append(it)
            rows[-1]["y"] = (rows[-1]["y"] + it["y"]) / 2
    out = []
    for r in rows:
        parts = sorted(r["parts"], key=lambda p: p["x"])
        left, right = [], []
        for p in parts:
            (left if p["x"] < 180 else right).append(p["t"])
        left_t = re.sub(r"\s+", " ", "".join(left)).strip()
        right_t = re.sub(r"\s+", " ", "".join(right)).strip()
        # Join fragmented single letters that appear as "M A T H"
        full = re.sub(r"\s+", " ", (left_t + " " + right_t).strip())
        # Also a denser form for header matching
        dense = re.sub(r"(?<=\b\w)\s+(?=\w\b)", "", full)
        dense = re.sub(r"\s+", " ", dense)
        out.append(
            {
                "y": r["y"],
                "left": left_t,
                "right": right_t,
                "full": full,
                "dense": dense,
            }
        )
    return out


def clean_title(s: str) -> str:
    s = re.sub(r"\s+", " ", s).strip()
    s = re.sub(r"\s*-\s*", " - ", s)
    s = re.sub(r"\s*,\s*", ", ", s)
    s = re.sub(r"\s*;\s*", "; ", s)
    if s and s[0].islower():
        s = s[0].upper() + s[1:]
    return s


SUBJECT_IN_HEADER = re.compile(
    r"\(([^)]+)\)",
    re.I,
)

SUBJECT_KEYS = {
    "MATHEMATICS": "maths",
    "MATHAMATICS": "maths",
    "PHYSICS": "physics",
    "CHEMISTRY": "chemistry",
    "BIOLOGY": "biology",
    "COMPUTERSCIENCE": "computer",
    "ACCOUNTANCY": "accountancy",
}


def subject_from_header(text: str) -> str | None:
    """Resolve subject from a TABLE header line despite glyph-spaced names."""
    up = text.upper()
    if "ENGLISH" in up and "GRAMMAR" in up:
        return "english"
    for m in SUBJECT_IN_HEADER.finditer(text):
        compact = re.sub(r"[^A-Za-z]", "", m.group(1)).upper()
        if compact in SUBJECT_KEYS:
            return SUBJECT_KEYS[compact]
        if compact.startswith("MATH"):
            return "maths"
        if compact.startswith("PHYS"):
            return "physics"
        if compact.startswith("CHEM"):
            return "chemistry"
        if compact.startswith("BIO"):
            return "biology"
        if compact.startswith("COMPUTER"):
            return "computer"
        if compact.startswith("ACCOUNT"):
            return "accountancy"
    return None


def is_table_header(probe: str) -> bool:
    """Headers often render as 'T ABLE OFVIDEO CLASSES' with a split T."""
    p = re.sub(r"\s+", "", probe.upper())
    return "TABLEOFVIDEO" in p


def parse_pdf(path: Path):
    reader = PdfReader(str(path))
    all_rows = []
    for page in reader.pages:
        all_rows.extend(cluster_rows(page_items(page)))

    subjects: dict[str, list] = {}
    expected: dict[str, int | None] = {}
    current = None
    chapter_buf: list[str] = []
    current_ch = None
    videos: list[str] = []

    def flush_chapter():
        nonlocal current_ch, videos
        if current and current_ch and videos:
            subjects.setdefault(current, []).append(
                {"c": clean_title(current_ch), "v": [clean_title(v) for v in videos]}
            )
        current_ch = None
        videos = []

    def flush_subject():
        nonlocal current, chapter_buf
        flush_chapter()
        current = None
        chapter_buf = []

    for row in all_rows:
        full = row["full"]
        dense = row["dense"]
        probe = dense.upper()

        if re.match(r"^(Page|age)\s*\d", full, re.I):
            continue
        if re.search(r"LIST OF VIDEO CLASSES|^PCMB|^PCMC|^COMMERCE", probe):
            # still allow subject summary lines later
            if "TABLE" not in probe and not re.match(
                r"^(MATHEMATICS|PHYSICS|CHEMISTRY|BIOLOGY|ENGLISH|COMPUTER|ACCOUNTANCY)",
                probe,
            ):
                continue
        if re.match(
            r"^(Subject|Chapter Name|CHAPTER NAME|Video Name|VIDEO NAME)\b",
            full,
            re.I,
        ):
            continue
        if "ENGLISH GRAMMAR IS" in probe:
            continue

        m = re.match(
            r"^(Mathematics|Physics|Chemistry|Biology|English(?:\s*Grammar)?|"
            r"Computer\s*Science|Accountancy)\s*(\d+|TBD)\s*$",
            dense,
            re.I,
        )
        if m:
            key = normalize_subject(m.group(1))
            if key:
                val = m.group(2)
                expected[key] = None if val.upper() == "TBD" else int(val)
            continue
        if re.match(r"^Total\s*", dense, re.I):
            continue

        # Subject section header — match on dense full line (headers often split)
        if is_table_header(probe):
            subj = subject_from_header(dense) or subject_from_header(full)
            if subj:
                flush_subject()
                current = subj
                chapter_buf = []
                continue
            if "ENGLISH" in probe and "GRAMMAR" in probe:
                flush_subject()
                current = "english"
                chapter_buf = []
                continue

        if not current:
            continue

        left, right = row["left"], row["right"]

        # Header leftovers sometimes land as right-only "ABLE OFVIDEO..."
        if right and re.match(r"^(ABLE|AMATICS|TABLE)\b", right, re.I) and not left:
            continue

        if left and not right:
            chapter_buf.append(left)
            continue

        if left and right:
            # If left looks like a subject header fragment, skip
            if "CBSE" in left.upper() and "GRADE" in left.upper():
                continue
            name = " ".join(chapter_buf + [left]).strip()
            flush_chapter()
            current_ch = name
            chapter_buf = []
            videos.append(right)
            continue

        if (not left) and right:
            if chapter_buf and not current_ch:
                current_ch = " ".join(chapter_buf).strip()
                chapter_buf = []
            if current_ch:
                videos.append(right)
            continue

    flush_subject()
    return subjects, expected


def count_v(reg):
    return {k: sum(len(ch["v"]) for ch in v) for k, v in reg.items()}


def js_escape(s: str) -> str:
    return (
        s.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", " ")
        .replace("\r", "")
    )


def emit_register_js(name: str, subjects: dict) -> str:
    order = ["maths", "physics", "chemistry", "biology", "computer", "accountancy", "english"]
    keys = [k for k in order if k in subjects] + [k for k in subjects if k not in order]
    parts = [f"const {name} = {{"]
    for k in keys:
        parts.append(f"  {k}: [")
        for ch in subjects[k]:
            vids = ",".join("'" + js_escape(v) + "'" for v in ch["v"])
            parts.append(f"    {{ c: '{js_escape(ch['c'])}', v: [{vids}] }},")
        parts.append("  ],")
    parts.append("};")
    return "\n".join(parts)


def main():
    OUT.mkdir(exist_ok=True)
    PDF_DIR.mkdir(parents=True, exist_ok=True)

    parsed = {}
    for key, path in SOURCES.items():
        if not path.exists():
            print("MISSING", path)
            continue
        subj, exp = parse_pdf(path)
        got = count_v(subj)
        print(f"=== {key} ===")
        print("  expected:", exp)
        print("  got     :", got)
        for k, chs in subj.items():
            print(f"  {k}: {len(chs)} chapters / {got[k]} videos")
        parsed[key] = {"subjects": subj, "expected": exp}
        dest = PDF_DIR / COPY_AS[key]
        shutil.copy2(path, dest)
        print("  copied ->", dest.name)

    # Build grade registers
    # Grade 8 / 10: flat PCMB+English
    reg8 = parsed["grade8_pcmb"]["subjects"]
    reg10 = parsed["grade10_pcmb"]["subjects"]

    # Grade 11 PCMC from PDF; PCMB = PCMC maths/physics/chemistry + empty biology
    g11_pcmc = parsed["grade11_pcmc"]["subjects"]
    g11_pcmb = {
        k: g11_pcmc[k]
        for k in ("maths", "physics", "chemistry", "english")
        if k in g11_pcmc
    }
    # Biology not in provided Grade 11 PDFs
    g11_commerce = parsed["grade11_commerce"]["subjects"]

    # Grade 12: PCMB PDF + CS from PCMC if any; Commerce separate
    g12_pcmb = parsed["grade12_pcmb"]["subjects"]
    g12_pcmc_src = parsed["grade12_pcmc"]["subjects"]
    g12_pcmc = {
        k: g12_pcmb[k]
        for k in ("maths", "physics", "chemistry", "english")
        if k in g12_pcmb
    }
    if g12_pcmc_src.get("computer"):
        g12_pcmc["computer"] = g12_pcmc_src["computer"]
    elif "computer" in g12_pcmc_src:
        g12_pcmc["computer"] = g12_pcmc_src["computer"]
    # Prefer CS from PCMC PDF even if empty list
    if "computer" not in g12_pcmc:
        g12_pcmc["computer"] = g12_pcmc_src.get("computer", [])
    g12_commerce = parsed["grade12_commerce"]["subjects"]

    payload = {
        "8": reg8,
        "10": reg10,
        "11": {"pcmb": g11_pcmb, "pcmc": g11_pcmc, "commerce": g11_commerce},
        "12": {"pcmb": g12_pcmb, "pcmc": g12_pcmc, "commerce": g12_commerce},
    }
    (OUT / "parsed_registers.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    js_chunks = [
        "/* AUTO-GENERATED by scripts/parse-syllabus-pdfs.py — do not hand-edit */",
        emit_register_js("REGISTER_8", reg8),
        emit_register_js("REGISTER_10", reg10),
        emit_register_js("REGISTER_11_PCMC", g11_pcmc),
        emit_register_js("REGISTER_11_PCMB", g11_pcmb),
        emit_register_js("REGISTER_11_COMMERCE", g11_commerce),
        emit_register_js("REGISTER_12_PCMB", g12_pcmb),
        emit_register_js("REGISTER_12_PCMC", g12_pcmc),
        emit_register_js("REGISTER_12_COMMERCE", g12_commerce),
    ]
    out_js = ROOT / "public" / "assets" / "js" / "registers-generated.js"
    out_js.write_text("\n\n".join(js_chunks) + "\n", encoding="utf-8")
    print("Wrote", out_js, "bytes", out_js.stat().st_size)


if __name__ == "__main__":
    main()

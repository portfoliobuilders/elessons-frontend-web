#!/usr/bin/env python3
"""Restructure Grade 11/12 Classes cards into subject + All subjects rows, and expand filters."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOMES = [
    ROOT / "public" / "index.html",
    ROOT / "public" / "homepage.html",
    ROOT / "elessons-homepage.html",
]

SUBJECTS = {
    "physics": {
        "name": "Physics",
        "banner": "sb-science",
        "colour": "#2C5E14",
        "tag": "Matter. Motion. Force.",
        "blurb": "Mechanics, waves, electricity and modern physics — built at the board, equation by equation.",
        "aria": "Physics",
    },
    "chemistry": {
        "name": "Chemistry",
        "banner": "sb-science",
        "colour": "#397417",
        "tag": "Atoms. Bonds. Reactions.",
        "blurb": "Physical, organic and inorganic chemistry with the numericals and mechanisms the paper rewards.",
        "aria": "Chemistry",
    },
    "maths": {
        "name": "Maths",
        "banner": "sb-maths",
        "colour": "#073790",
        "tag": "Think. Solve. Succeed.",
        "blurb": "Concept clarity first, then problem solving — worked at the board, step by step.",
        "aria": "Maths — Think. Solve. Succeed.",
    },
    "biology": {
        "name": "Biology",
        "banner": "sb-science",
        "colour": "#4A8C22",
        "tag": "Life. Systems. Clarity.",
        "blurb": "Cell biology, genetics, human physiology and ecology — diagrams and definitions that stick.",
        "aria": "Biology",
    },
    "computer": {
        "name": "Computer Science",
        "banner": "sb-science",
        "colour": "#0E7490",
        "tag": "Logic. Code. Design.",
        "blurb": "Programming, data structures and computer fundamentals for the CBSE computer science paper.",
        "aria": "Computer Science",
    },
    "accountancy": {
        "name": "Accountancy",
        "banner": "sb-english",
        "colour": "#92400E",
        "tag": "Books. Ledgers. Balance.",
        "blurb": "Journal entries, ledgers, final accounts and analysis — practised until the formats are automatic.",
        "aria": "Accountancy",
    },
}

STREAMS = {
    "pcmb": {
        "label": "PCMB",
        "colour": "#397417",
        "subjects": ["physics", "chemistry", "maths", "biology"],
        "tag_line": "Physics · Chemistry · Maths · Biology",
        "blurb_g": (
            "Physics, Chemistry, Maths and Biology together for grade {g} — every lesson and notes file, "
            "with English Grammar included free."
        ),
        "science_tag": True,
    },
    "pcmc": {
        "label": "PCMC",
        "colour": "#0E7490",
        "subjects": ["physics", "chemistry", "maths", "computer"],
        "tag_line": "Physics · Chemistry · Maths · Computer Science",
        "blurb_g": (
            "Physics, Chemistry, Maths and Computer Science together for grade {g} — every lesson and notes file, "
            "with English Grammar included free."
        ),
        "science_tag": True,
    },
    "commerce": {
        "label": "Commerce",
        "colour": "#92400E",
        "subjects": ["accountancy", "maths"],
        "tag_line": "Accountancy · Maths",
        "blurb_g": (
            "Accountancy and Maths together for grade {g} commerce — every lesson and notes file, "
            "with English Grammar included free."
        ),
        "science_tag": False,
    },
}


def subject_card(grade: int, stream_key: str, sub_key: str) -> str:
    stream = STREAMS[stream_key]
    sub = SUBJECTS[sub_key]
    tags = [f"Grade {grade}", stream["label"], sub["name"]]
    if stream["science_tag"]:
        tags.append("Science")
    tag_str = "|".join(tags)
    href = f"course-detail.html?grade={grade}&plan=full&stream={stream_key}"
    return f'''      <article class="course course-img card-hover" data-tags="{tag_str}" style="--banner:{sub['colour']}">
        <span class="sub-banner {sub['banner']}" role="img" aria-label="{sub['aria']}"></span>
        <div>
          <p class="mono card-kicker" style="color:{sub['colour']}">Grade {grade} &middot; {stream['label']} subject</p>
          <h3 class="h3" style="margin-top:.25rem">{sub['name']}</h3>
          <p class="mono subj-tagline" style="color:{sub['colour']}">{sub['tag']}</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">{sub['blurb']}</p>
        <div style="margin-top:auto">
          <p style="font-weight:800;font-size:1.05rem;color:var(--navy-900);letter-spacing:-.02em">Included in {stream['label']}</p>
          <p style="color:var(--slate-500);font-size:.75rem">This subject &middot; full academic year</p>
          <a href="{href}" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">View package</a>
        </div>
      </article>'''


def bundle_card(grade: int, stream_key: str) -> str:
    stream = STREAMS[stream_key]
    tags = [f"Grade {grade}", stream["label"]]
    if stream["science_tag"]:
        tags.append("Science")
    tag_str = "|".join(tags)
    names = ", ".join(SUBJECTS[s]["name"] for s in stream["subjects"])
    href = f"course-detail.html?grade={grade}&plan=full&stream={stream_key}"
    blurb = stream["blurb_g"].format(g=grade)
    return f'''      <article class="course course-bundle card-hover" data-tags="{tag_str}" style="--banner:var(--gold)">
        <span class="sub-banner sb-bundle" role="img" aria-label="{names}"></span>
        <span class="course-ghost" aria-hidden="true">{grade}</span>
        <p class="mono bundle-flag">Best value</p>
        <div class="flex g2" style="align-items:flex-start">
          <span class="course-num">{grade}</span>
          <span class="mono" style="color:var(--gold);font-size:.66rem;margin-top:.45rem">All subjects<br>{stream['label']}</span>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">{blurb}</p>
        <div style="margin-top:auto">
          <p class="price bundle-price" data-inr="&#8377;18,000" data-aed="AED 1,200">&#8377;18,000</p>
          <p class="bundle-save">Annual package &middot; English Grammar free</p>
          <a href="{href}" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>'''


def stream_row(grade: int, stream_key: str) -> str:
    stream = STREAMS[stream_key]
    tags = [f"Grade {grade}", stream["label"]]
    if stream["science_tag"]:
        tags.append("Science")
    for s in stream["subjects"]:
        name = SUBJECTS[s]["name"]
        if name not in tags:
            tags.append(name)
    tag_str = "|".join(tags)
    subjects_html = "\n".join(subject_card(grade, stream_key, s) for s in stream["subjects"])
    return f'''    <div class="course-stream-row" data-tags="{tag_str}" data-stream="{stream_key}" data-grade="{grade}">
      <p class="course-stream-label mono">Grade {grade} &middot; {stream['label']}<span>{stream['tag_line']}</span></p>
      <div class="course-stream-grid">
        <div class="course-stream-subjects">
{subjects_html}
        </div>
{bundle_card(grade, stream_key)}
      </div>
    </div>'''


def build_stream_section() -> str:
    parts: list[str] = []
    for grade in (11, 12):
        for key in ("pcmb", "pcmc", "commerce"):
            parts.append(stream_row(grade, key))
    return "\n".join(parts)


STREAM_CSS = """
/* Stream rows — subjects left, All subjects package right */
.course-stream-row{grid-column:1/-1;display:flex;flex-direction:column;gap:1rem}
.course-stream-label{font-size:.62rem;color:var(--slate-500);letter-spacing:.04em;text-transform:uppercase;
  display:flex;flex-wrap:wrap;align-items:baseline;gap:.55rem .9rem}
.course-stream-label span{color:var(--navy-700);font-weight:700;letter-spacing:.02em;text-transform:none;font-size:.72rem}
.course-stream-grid{display:grid;gap:1rem;align-items:stretch}
.course-stream-subjects{display:grid;gap:1rem;grid-template-columns:repeat(auto-fill,minmax(min(100%,220px),1fr))}
.course-stream-grid > .course-bundle{min-width:0}
@media (min-width:1100px){
  .course-stream-grid{grid-template-columns:minmax(0,1fr) minmax(280px,340px);gap:1.25rem}
}
.filter-group{display:flex;flex-wrap:wrap;gap:.55rem;align-items:center}
.filter-group + .filter-group{margin-top:.65rem}
.filter-group-label{font-size:.62rem;font-weight:700;letter-spacing:.06em;text-transform:uppercase;
  color:var(--slate-500);margin-right:.25rem;min-width:4.5rem}
"""

FILTER_HTML = """    <div class="mt4" id="course-filters">
      <div class="filter-group" role="group" aria-label="Filter by grade">
        <span class="filter-group-label mono">Grade</span>
        <button type="button" class="filter" aria-pressed="false">Grade 8</button>
        <button type="button" class="filter" aria-pressed="false">Grade 9</button>
        <button type="button" class="filter" aria-pressed="false">Grade 10</button>
        <button type="button" class="filter" aria-pressed="false">Grade 11</button>
        <button type="button" class="filter" aria-pressed="false">Grade 12</button>
      </div>
      <div class="filter-group" role="group" aria-label="Filter by stream">
        <span class="filter-group-label mono">Stream</span>
        <button type="button" class="filter" aria-pressed="false">PCMB</button>
        <button type="button" class="filter" aria-pressed="false">PCMC</button>
        <button type="button" class="filter" aria-pressed="false">Commerce</button>
      </div>
      <div class="filter-group" role="group" aria-label="Filter by subject">
        <span class="filter-group-label mono">Subject</span>
        <button type="button" class="filter" aria-pressed="false">Maths</button>
        <button type="button" class="filter" aria-pressed="false">Science</button>
        <button type="button" class="filter" aria-pressed="false">English</button>
        <button type="button" class="filter" aria-pressed="false">Physics</button>
        <button type="button" class="filter" aria-pressed="false">Chemistry</button>
        <button type="button" class="filter" aria-pressed="false">Biology</button>
        <button type="button" class="filter" aria-pressed="false">Computer Science</button>
        <button type="button" class="filter" aria-pressed="false">Accountancy</button>
      </div>
    </div>"""

FILTER_JS = r"""document.querySelectorAll('.filter').forEach(function(f){
  f.onclick=function(){
    // no 'All' chip: clicking the active filter again clears it
    var wasOn = f.getAttribute('aria-pressed')==='true';
    document.querySelectorAll('.filter').forEach(function(o){o.setAttribute('aria-pressed','false')});
    if(!wasOn) f.setAttribute('aria-pressed','true');
    var key = wasOn ? null : f.textContent.trim();
    var wholeRow = !key || key.indexOf('Grade ')===0 || key==='PCMB' || key==='PCMC'
      || key==='Commerce' || key==='Science';
    function hasTag(el, k){ return !k || (el.dataset.tags||'').split('|').indexOf(k)>-1; }
    document.querySelectorAll('#course-grid > .course').forEach(function(c){
      c.style.display = hasTag(c, key) ? '' : 'none';
    });
    document.querySelectorAll('#course-grid > .course-stream-row').forEach(function(row){
      var rowShow = hasTag(row, key);
      row.style.display = rowShow ? '' : 'none';
      if (!rowShow) return;
      row.querySelectorAll('.course').forEach(function(c){
        if (wholeRow) { c.style.display = ''; return; }
        /* Subject focus: keep matching subject cards + the All subjects bundle */
        var show = hasTag(c, key) || c.classList.contains('course-bundle');
        c.style.display = show ? '' : 'none';
      });
    });
  };
});"""


def replace_once(html: str, pattern: str, repl: str, flags: int = 0) -> str:
    new, n = re.subn(pattern, repl, html, count=1, flags=flags)
    if n != 1:
        raise RuntimeError(f"Expected 1 match for pattern, got {n}: {pattern[:80]!r}")
    return new


def apply(path: Path) -> None:
    html = path.read_text(encoding="utf-8")

    # CSS after bundle-save rule
    if ".course-stream-row{" not in html:
        html = replace_once(
            html,
            r"(\.bundle-save\{font-size:\.72rem;color:var\(--gold\);margin-top:\.25rem\})",
            r"\1\n" + STREAM_CSS.strip(),
        )

    # Filters
    html = replace_once(
        html,
        r'<div class="flex wrapf g1 mt4" role="group" aria-label="Filter classes">\s*'
        r'<button class="filter" aria-pressed="false">Grade 8</button>\s*'
        r'<button class="filter" aria-pressed="false">Grade 9</button>\s*'
        r'<button class="filter" aria-pressed="false">Grade 10</button>\s*'
        r'<button class="filter" aria-pressed="false">Grade 11</button>\s*'
        r'<button class="filter" aria-pressed="false">Grade 12</button>\s*'
        r"</div>",
        FILTER_HTML,
        flags=re.S,
    )

    # Replace Grade 11/12 cards (from first Grade 11 card through last Grade 12 Commerce card)
    stream_html = build_stream_section()
    html = replace_once(
        html,
        r'      <article class="course course-img card-hover" data-tags="Grade 11\|PCMB\|Science".*?'
        r'      <article class="course course-img card-hover" data-tags="Grade 12\|Commerce".*?</article>\n',
        stream_html + "\n",
        flags=re.S,
    )

    # Filter JS
    html = replace_once(
        html,
        r"document\.querySelectorAll\('\.filter'\)\.forEach\(function\(f\)\{.*?\n\}\);",
        FILTER_JS,
        flags=re.S,
    )

    path.write_text(html, encoding="utf-8")
    print(f"Updated {path.relative_to(ROOT)}")


def main() -> None:
    for path in HOMES:
        if not path.exists():
            print(f"Skip missing {path}")
            continue
        apply(path)


if __name__ == "__main__":
    main()

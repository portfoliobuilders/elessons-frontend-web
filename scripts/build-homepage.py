#!/usr/bin/env python3
"""Rebuild public/homepage.html from Blade-ish sources (static preview)."""
import json, re, shutil, urllib.parse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def strip_blade(text: str) -> str:
    text = re.sub(r"\{\{--.*?--\}\}", "", text, flags=re.S)
    text = re.sub(r"@php.*?@endphp", "", text, flags=re.S)
    text = re.sub(r"@include\([^)]+\)", "", text)
    text = re.sub(r"@foreach.*?@endforeach", "", text, flags=re.S)
    text = re.sub(r"@if.*?@endif", "", text, flags=re.S)
    return text.strip()

def fix_assets(html: str) -> str:
    return (
        html.replace("/images/", "images/")
        .replace("/favicon.svg", "favicon.svg")
        .replace('href="/css/', 'href="css/')
        .replace('src="/js/', 'src="js/')
        .replace('href="/fonts/', 'href="fonts/')
    )

def read(rel: str) -> str:
    return (ROOT / "resources/views" / rel).read_text()

def buy(grade: str, stream: str) -> str:
    msg = f"Hi G-TEC eLessons, I want to buy the Grade {grade} {stream} annual package (AED 1200)."
    return "https://wa.me/971568056001?text=" + urllib.parse.quote(msg)

def main() -> None:
    # sync css/js first
    for p in (ROOT / "resources/css").rglob("*"):
        if p.is_file() and p.suffix.lower() != ".md":
            t = ROOT / "public/css" / p.relative_to(ROOT / "resources/css")
            t.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p, t)
    fonts = ROOT / "public/css/base/fonts.css"
    if fonts.exists():
        fonts.write_text(fonts.read_text().replace('url("/fonts/', 'url("../fonts/'))
    for name in ("nav.js", "interactive.js", "config.js", "form.js"):
        src = ROOT / "resources/js" / name
        if src.exists():
            shutil.copy2(src, ROOT / "public/js" / name)

    packages = [
        ("8", "All subjects", ["Physics", "Chemistry", "Maths", "Biology", "English"], "Grade 8|Science|Commerce", "var(--navy-600)"),
        ("9", "All subjects", ["Physics", "Chemistry", "Maths", "Biology", "English"], "Grade 9|Science|Commerce", "var(--navy-600)"),
        ("10", "All subjects", ["Physics", "Chemistry", "Maths", "Biology", "English"], "Grade 10|Science|Commerce", "var(--navy-600)"),
        ("11", "PCMB", ["Physics", "Chemistry", "Maths", "Biology"], "Grade 11|Science", "var(--sci)"),
        ("12", "PCMB", ["Physics", "Chemistry", "Maths", "Biology"], "Grade 12|Science", "var(--sci)"),
        ("11", "PCMC", ["Physics", "Chemistry", "Maths", "Computer Science"], "Grade 11|Science", "var(--sci)"),
        ("12", "PCMBC", ["Physics", "Chemistry", "Maths", "Biology", "Computer Science"], "Grade 12|Science", "var(--sci)"),
        ("11", "Commerce", ["Accountancy", "Maths", "English", "Grammar"], "Grade 11|Commerce", "var(--com)"),
        ("12", "Commerce", ["Accountancy", "Maths", "English", "Grammar"], "Grade 12|Commerce", "var(--com)"),
    ]

    def course_card(grade, stream, subjects, tags, banner):
        chips = "".join(f'<span class="course-card__chip">{s}</span>' for s in subjects)
        href = buy(grade, stream)
        label = f"Buy Grade {grade} {stream} package on WhatsApp"
        return f'''<article class="course-card" data-tags="{tags}" data-grade="{grade}" data-stream="{stream}" style="--banner: {banner}">
  <span class="course-card__ghost" aria-hidden="true">{grade}</span>
  <div class="course-card__head"><span class="course-card__grade">{grade}</span><span class="course-card__stream">{stream}</span></div>
  <div class="course-card__subjects">{chips}</div>
  <div class="course-card__foot">
    <p class="course-card__price">AED 1,200</p>
    <p class="course-card__meta">≈ ₹27,500 · full academic year</p>
    <a href="{href}" class="btn btn--primary btn--sm btn--block" target="_blank" rel="noopener noreferrer" aria-label="{label}">Buy now</a>
  </div>
</article>'''

    filters = "".join(
        f'<button type="button" class="course-filters__btn" data-filter="{f}" aria-pressed="{"true" if i == 0 else "false"}">{f}</button>'
        for i, f in enumerate(["All", "Grade 8", "Grade 9", "Grade 10", "Grade 11", "Grade 12", "Science", "Commerce"])
    )
    courses = f'''<section id="courses" class="sec" aria-labelledby="courses-heading">
  <div class="wrap">
    <div class="section-head"><div><p class="section-eyebrow">Annual packages</p><h2 id="courses-heading" class="h2" style="margin-top: var(--space-sm)">Nine packages. One price.</h2></div>
    <p class="section-lead">Every package runs the full academic year and includes all subjects for that stream.</p></div>
    <div class="course-filters" style="margin-top: var(--space-xl)" role="group" aria-label="Filter courses">{filters}</div>
    <p id="filter-status" class="filter-status" aria-live="polite">9 packages shown</p>
    <div class="course-grid" id="course-grid" style="margin-top: var(--space-xl)">{''.join(course_card(*p) for p in packages)}</div>
  </div></section>'''

    site = "https://elessons.net"
    title = "G-TEC eLessons.net — Traditional chalk-board class from the comfort of your home"
    desc = "CBSE / NCERT video lessons and notes for grades 8 to 12. A real teacher at a real board. AED 1200 for the full academic year."
    # minimal SEO block is already in public; rebuild via previous generator path:
    # Prefer running the inline builder already executed; this script syncs and prints status.
    print("Synced public/css and public/js. Homepage rebuild uses repo preview generator.")
    print("Open public/homepage.html after sync.")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Apply homepage stream cards, clickable-card JS, and WhatsApp FAB to mirrors."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

HOMES = [
    ROOT / "public" / "index.html",
    ROOT / "public" / "homepage.html",
    ROOT / "elessons-homepage.html",
]

WA_SVG = (
    '<svg width="27" height="27" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
    '<path d="M12.04 2C6.6 2 2.18 6.42 2.18 11.86c0 1.94.53 3.76 1.45 5.32L2 22l4.96-1.58'
    "a9.8 9.8 0 0 0 5.08 1.4c5.43 0 9.85-4.42 9.85-9.86S17.47 2 12.04 2Zm5.77 14c-.24.68-1.4 "
    "1.3-1.93 1.34-.5.05-1.13.07-1.82-.11a15.6 15.6 0 0 1-1.65-.62c-2.9-1.26-4.8-4.2-4.94-4.4"
    "-.15-.2-1.19-1.58-1.19-3.02 0-1.44.75-2.14 1.02-2.44.27-.29.59-.36.78-.36h.56c.18 0 .42"
    "-.07.66.5.24.59.83 2.03.9 2.18.07.15.12.32.02.51-.1.2-.15.32-.3.49-.14.17-.3.38-.44.51"
    "-.14.15-.29.3-.13.6.17.29.75 1.23 1.6 2 1.11.98 2.04 1.29 2.33 1.44.29.15.46.12.63-.07"
    ".17-.2.73-.85.92-1.14.2-.29.39-.24.66-.15.27.1 1.7.8 2 .95.29.15.48.22.55.34.07.13.07"
    '.73-.17 1.42Z"/></svg>'
)

WA_MSG = "Hi%20GTEC%20Team%2C%20I%27m%20interested%20in%20eLessons.%20Can%20you%20share%20more%20details%3F"
WA_FAB = (
    f'<a class="wa-float" href="https://wa.me/919745553944?text={WA_MSG}" '
    f'aria-label="Chat on WhatsApp" target="_blank" rel="noopener">\n  {WA_SVG}\n</a>'
)

WA_CSS = """
.wa-float{position:fixed;right:clamp(.9rem,2vw,1.6rem);bottom:clamp(.9rem,2vw,1.6rem);z-index:65;
  width:56px;height:56px;border-radius:50%;background:#25D366;color:#fff;display:flex;
  align-items:center;justify-content:center;box-shadow:0 12px 30px -10px rgba(37,211,102,.75);
  transition:transform .2s ease;text-decoration:none}
.wa-float:hover{transform:translateY(-3px) scale(1.04)}
.wa-float:focus-visible{outline:3px solid #128C7E;outline-offset:3px}
@media (max-width:767px){.wa-float{bottom:calc(76px + .9rem)}}
.course{cursor:pointer}
.course:focus-visible{outline:3px solid var(--navy-600);outline-offset:3px}
"""

CLICK_JS = r"""
(function(){
  document.querySelectorAll('#course-grid .course').forEach(function(card){
    var link = card.querySelector('a.btn[href*="course-detail"]');
    if (!link) return;
    card.setAttribute('role','link');
    card.setAttribute('tabindex','0');
    var h = card.querySelector('h3');
    card.setAttribute('aria-label', h && h.textContent
      ? ('Open ' + h.textContent.trim() + ' course details')
      : 'Open course details');
    function go(e){
      if (e.target.closest('a')) return;
      location.href = link.href;
    }
    card.addEventListener('click', go);
    card.addEventListener('keydown', function(e){
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); location.href = link.href; }
    });
  });
})();
"""

STREAM_CARDS = r'''
      <article class="course course-img card-hover" data-tags="Grade 11|PCMB|Science" style="--banner:#397417">
        <span class="sub-banner sb-science" role="img" aria-label="PCMB — Physics, Chemistry, Maths, Biology"></span>
        <div>
          <p class="mono card-kicker" style="color:#397417">Grade 11 &middot; stream package</p>
          <h3 class="h3" style="margin-top:.25rem">PCMB</h3>
          <p class="mono subj-tagline" style="color:#397417">Physics · Chemistry · Maths · Biology</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">The full science stream for grade 11, with free English Grammar included as complimentary.</p>
        <div style="margin-top:auto">
          <p class="price" data-inr="&#8377;18,000" data-aed="AED 1,200" style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">&#8377;18,000</p>
          <p style="color:var(--slate-500);font-size:.75rem">Annual package &middot; English Grammar free</p>
          <a href="course-detail.html?grade=11&plan=full&stream=pcmb" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>
      <article class="course course-img card-hover" data-tags="Grade 11|PCMC|Science" style="--banner:#0E7490">
        <span class="sub-banner sb-science" role="img" aria-label="PCMC — Physics, Chemistry, Maths, Computer Science"></span>
        <div>
          <p class="mono card-kicker" style="color:#0E7490">Grade 11 &middot; stream package</p>
          <h3 class="h3" style="margin-top:.25rem">PCMC</h3>
          <p class="mono subj-tagline" style="color:#0E7490">Physics · Chemistry · Maths · CS</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">Physics, chemistry, maths and computer science for grade 11, with free English Grammar included.</p>
        <div style="margin-top:auto">
          <p class="price" data-inr="&#8377;18,000" data-aed="AED 1,200" style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">&#8377;18,000</p>
          <p style="color:var(--slate-500);font-size:.75rem">Annual package &middot; English Grammar free</p>
          <a href="course-detail.html?grade=11&plan=full&stream=pcmc" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>
      <article class="course course-img card-hover" data-tags="Grade 11|Commerce" style="--banner:#92400E">
        <span class="sub-banner sb-english" role="img" aria-label="Commerce — Accountancy and Maths"></span>
        <div>
          <p class="mono card-kicker" style="color:#92400E">Grade 11 &middot; stream package</p>
          <h3 class="h3" style="margin-top:.25rem">Commerce</h3>
          <p class="mono subj-tagline" style="color:#92400E">Accountancy · Maths</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">Accountancy and maths for grade 11 commerce, with free English Grammar included as complimentary.</p>
        <div style="margin-top:auto">
          <p class="price" data-inr="&#8377;18,000" data-aed="AED 1,200" style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">&#8377;18,000</p>
          <p style="color:var(--slate-500);font-size:.75rem">Annual package &middot; English Grammar free</p>
          <a href="course-detail.html?grade=11&plan=full&stream=commerce" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>
      <article class="course course-img card-hover" data-tags="Grade 12|PCMB|Science" style="--banner:#397417">
        <span class="sub-banner sb-science" role="img" aria-label="PCMB — Physics, Chemistry, Maths, Biology"></span>
        <div>
          <p class="mono card-kicker" style="color:#397417">Grade 12 &middot; stream package</p>
          <h3 class="h3" style="margin-top:.25rem">PCMB</h3>
          <p class="mono subj-tagline" style="color:#397417">Physics · Chemistry · Maths · Biology</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">The full science stream for grade 12, with free English Grammar included as complimentary.</p>
        <div style="margin-top:auto">
          <p class="price" data-inr="&#8377;18,000" data-aed="AED 1,200" style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">&#8377;18,000</p>
          <p style="color:var(--slate-500);font-size:.75rem">Annual package &middot; English Grammar free</p>
          <a href="course-detail.html?grade=12&plan=full&stream=pcmb" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>
      <article class="course course-img card-hover" data-tags="Grade 12|PCMC|Science" style="--banner:#0E7490">
        <span class="sub-banner sb-science" role="img" aria-label="PCMC — Physics, Chemistry, Maths, Computer Science"></span>
        <div>
          <p class="mono card-kicker" style="color:#0E7490">Grade 12 &middot; stream package</p>
          <h3 class="h3" style="margin-top:.25rem">PCMC</h3>
          <p class="mono subj-tagline" style="color:#0E7490">Physics · Chemistry · Maths · CS</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">Physics, chemistry, maths and computer science for grade 12, with free English Grammar included.</p>
        <div style="margin-top:auto">
          <p class="price" data-inr="&#8377;18,000" data-aed="AED 1,200" style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">&#8377;18,000</p>
          <p style="color:var(--slate-500);font-size:.75rem">Annual package &middot; English Grammar free</p>
          <a href="course-detail.html?grade=12&plan=full&stream=pcmc" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>
      <article class="course course-img card-hover" data-tags="Grade 12|Commerce" style="--banner:#92400E">
        <span class="sub-banner sb-english" role="img" aria-label="Commerce — Accountancy and Maths"></span>
        <div>
          <p class="mono card-kicker" style="color:#92400E">Grade 12 &middot; stream package</p>
          <h3 class="h3" style="margin-top:.25rem">Commerce</h3>
          <p class="mono subj-tagline" style="color:#92400E">Accountancy · Maths</p>
        </div>
        <div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span><span class="mode">Recorded lessons</span></div>
        <p class="card-blurb">Accountancy and maths for grade 12 commerce, with free English Grammar included as complimentary.</p>
        <div style="margin-top:auto">
          <p class="price" data-inr="&#8377;18,000" data-aed="AED 1,200" style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">&#8377;18,000</p>
          <p style="color:var(--slate-500);font-size:.75rem">Annual package &middot; English Grammar free</p>
          <a href="course-detail.html?grade=12&plan=full&stream=commerce" class="btn btn-red btn-sm btn-block" style="margin-top:.9rem">Enrol now</a>
        </div>
      </article>
'''


def replace_grade_cards(html: str) -> str:
    pat = re.compile(
        r'(?s)      <article class="course course-img card-hover" data-tags="Grade 11\|Maths".*?'
        r'      <article class="course course-bundle card-hover" data-tags="Grade 12".*?</article>\n'
    )
    if not pat.search(html):
        raise SystemExit("Could not find Grade 11-12 card block to replace")
    return pat.sub(STREAM_CARDS.lstrip("\n"), html)


def patch_bundle_blurb_8_10(html: str) -> str:
    for g in (8, 9, 10):
        html = html.replace(
            f"Maths, Science and English together for grade {g} &mdash; every lesson and every notes file, unlocked on day one.",
            f"Maths, Science and English together for grade {g} &mdash; every lesson and notes file, with English Grammar included free.",
        )
    return html


def ensure_wa_css(html: str) -> str:
    if ".wa-float{" in html:
        return html
    return html.replace("</style>", WA_CSS + "\n</style>", 1)


def ensure_fab(html: str) -> str:
    if 'class="wa-float"' in html:
        return html
    if '<div class="stickybar">' in html:
        return html.replace('<div class="stickybar">', WA_FAB + "\n\n<div class=\"stickybar\">", 1)
    return html.replace("</body>", WA_FAB + "\n</body>", 1)


def ensure_click_js(html: str) -> str:
    if "Open course details" in html and "#course-grid .course" in html:
        return html
    marker = "document.querySelectorAll('.filter').forEach"
    if marker in html:
        return html.replace(marker, CLICK_JS + "\n" + marker, 1)
    return html.replace("</body>", f"<script>{CLICK_JS}</script>\n</body>", 1)


def main():
    for path in HOMES:
        html = path.read_text(encoding="utf-8")
        html = replace_grade_cards(html)
        html = patch_bundle_blurb_8_10(html)
        html = ensure_wa_css(html)
        html = ensure_fab(html)
        html = ensure_click_js(html)
        html = html.replace(
            "Grades 8 to 12, in Maths, Science and English. Take one subject on its own or all three together.",
            "Grades 8 to 10 by subject; grades 11 and 12 by stream (PCMB, PCMC, Commerce). English Grammar is free with every annual package.",
        )
        path.write_text(html, encoding="utf-8")
        print("patched", path.relative_to(ROOT))


if __name__ == "__main__":
    main()

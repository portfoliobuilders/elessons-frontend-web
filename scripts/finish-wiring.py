#!/usr/bin/env python3
"""Finish stream-aware register wiring + CLASSLIST PDFs + sync download button."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
detail = ROOT / "public/assets/js/detail.js"
cdata = ROOT / "public/assets/js/course-data.js"

t = detail.read_text(encoding="utf-8")
reps = [
    ("var streams = registerStreams(g);", "var streams = registerStreams(g, S.stream);"),
    (
        "var meta = STREAM_META[k], chs = streamChapters(g, k);",
        "var meta = STREAM_META[k], chs = streamChapters(g, k, S.stream);",
    ),
    (
        "streamsForPlan(S.grade, S.plan, S.subject);",
        "streamsForPlan(S.grade, S.plan, S.subject, S.stream);",
    ),
    (
        "return n + streamChapters(grade, k).length;",
        "return n + streamChapters(grade, k, S.stream).length;",
    ),
    (
        "hasRegister(g) ? registerTotal(g) + ' video lessons across ' + chapterTotal(g) + ' chapters'",
        "hasRegister(g, S.stream) ? registerTotal(g, null, S.stream) + ' video lessons across ' + chapterTotal(g, S.stream) + ' chapters'",
    ),
    (
        "var count = planLessonCount(g, 'subject', sub);",
        "var count = planLessonCount(g, 'subject', sub, S.stream);",
    ),
    (
        "inc: [m.tag, hasRegister(g) ? count + ' video lessons'",
        "inc: [m.tag, hasRegister(g, S.stream) ? count + ' video lessons'",
    ),
]
for a, b in reps:
    n = t.count(a)
    t = t.replace(a, b)
    print(f"{n}: {a[:60]}")

old_lede = """    $('course-lede').textContent = S.plan === 'subject'
      ? SUBJECT_META[S.subject].blurb
      : S.plan === 'module'
        ? 'Pick only the chapters you need. Every module is priced on its own and lands in your library the moment you buy it.'
        : 'Maths, Science and English together for grade ' + S.grade +
          ' \\u2014 every lesson and every notes file, unlocked on day one.';"""
new_lede = """    $('course-lede').textContent = (isStreamGrade(S.grade) && S.stream && PACKAGE_META[S.stream])
      ? PACKAGE_META[S.stream].blurb
      : S.plan === 'subject'
      ? SUBJECT_META[S.subject].blurb
      : S.plan === 'module'
        ? 'Pick only the chapters you need. Every module is priced on its own and lands in your library the moment you buy it.'
        : 'Maths, Science and English together for grade ' + S.grade +
          ' \\u2014 every lesson and every notes file, unlocked on day one.';"""
if old_lede in t:
    t = t.replace(old_lede, new_lede)
    print("lede patched")
else:
    print("lede NOT found")

# Sync PDF download button at start of paintRegister
if "classListPdfFor" not in t:
    needle = "  function paintRegister() {\n    /* No published class list"
    insert = """  function paintRegister() {
    var dl = $('download-pdf');
    if (dl && typeof classListPdfFor === 'function') {
      var href = classListPdfFor(S.grade, S.stream || 'pcmb');
      if (href) {
        dl.hidden = false;
        dl.href = href;
        if (/\\.pdf($|\\?)/i.test(href)) dl.setAttribute('download', '');
        else dl.removeAttribute('download');
      }
    }
    /* No published class list"""
    if needle in t:
        t = t.replace(needle, insert)
        print("download sync patched")
    else:
        print("paintRegister needle missing")

detail.write_text(t, encoding="utf-8")
print("wrote detail.js")

ct = cdata.read_text(encoding="utf-8")
if "CLASSLIST_PDFS" not in ct:
    block = """
/* Published class-list PDFs (under /assets/pdfs/). */
const CLASSLIST_PDFS = {
  8:  { pcmb: '/assets/pdfs/grade-8-pcmb.pdf' },
  9:  { pcmb: '/video-list.html' },
  10: { pcmb: '/assets/pdfs/grade-10-pcmb.pdf' },
  11: { pcmc: '/assets/pdfs/grade-11-pcmc.pdf', commerce: '/assets/pdfs/grade-11-commerce.pdf' },
  12: {
    pcmb: '/assets/pdfs/grade-12-pcmb.pdf',
    pcmc: '/assets/pdfs/grade-12-pcmc.pdf',
    commerce: '/assets/pdfs/grade-12-commerce.pdf'
  }
};
function classListPdfFor(grade, streamKey) {
  var map = CLASSLIST_PDFS[grade];
  if (!map) return ELESSONS.classListPdf;
  if (streamKey && map[streamKey]) return map[streamKey];
  var order = ['pcmb', 'pcmc', 'commerce'];
  for (var i = 0; i < order.length; i++) {
    if (map[order[i]]) return map[order[i]];
  }
  return ELESSONS.classListPdf;
}

"""
    ct = ct.replace(
        "  defaultCurrency: 'inr'\n};",
        "  defaultCurrency: 'inr'\n};" + block,
        1,
    )
    cdata.write_text(ct, encoding="utf-8")
    print("CLASSLIST added")
else:
    print("CLASSLIST already present")

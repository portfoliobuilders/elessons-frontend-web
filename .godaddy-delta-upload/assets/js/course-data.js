/* ==========================================================================
   G-TEC eLessons — catalog data
   Ported to match indexnew.html. In Next.js this file becomes
   GET /api/courses + GET /api/courses/:grade. Pure data, no DOM.
   ========================================================================== */

/* ---------- CONFIG ---------- */
const ELESSONS = {
  /* India admissions line (homepage schema + nav). Gulf enquiry uses whatsappAed. */
  whatsapp: '919745553944',
  whatsappInr: '919745553944',
  whatsappAed: '971568056001',   /* same Gulf number as homepage config.js */
  phoneDisplay: '+91 97455 53944',
  phoneDisplayAed: '+971 568056001',
  lmsUrl: 'https://lms.elessons.net',        // TODO confirm the real LMS origin
  classListPdf: '/video-list.html',
  checkoutUrl: '/checkout.html',

  // Durations are NOT in the source syllabus PDF. Leaving this false hides the
  // column rather than shipping invented numbers.
  showDurations: false,
  defaultCurrency: 'inr',
  /* Rest-of-world fallback when IP country is not India or GCC. */
  supportedCurrencies: ['inr', 'aed', 'usd']
};

/** Source PDF (or printable HTML list) for a grade / stream package. */
const CLASS_LIST_PDF = {
  8:  '/assets/pdfs/grade-8-pcmb.pdf',
  9:  '/assets/pdfs/grade-9-pcmb.pdf',
  10: '/assets/pdfs/grade-10-pcmb.pdf',
  11: {
    pcmb: '/assets/pdfs/grade-11-pcmb.pdf',
    pcmc: '/assets/pdfs/grade-11-pcmc.pdf',
    commerce: '/assets/pdfs/grade-11-commerce.pdf'
  },
  12: {
    pcmb: '/assets/pdfs/grade-12-pcmb.pdf',
    pcmc: '/assets/pdfs/grade-12-pcmc.pdf',
    commerce: '/assets/pdfs/grade-12-commerce.pdf'
  }
};
function classListPdfFor(grade, pkg) {
  var entry = CLASS_LIST_PDF[grade];
  if (!entry) return ELESSONS.classListPdf + '?grade=' + grade;
  if (typeof entry === 'string') return entry;
  return entry[pkg] || entry.pcmb || (ELESSONS.classListPdf + '?grade=' + grade);
}
/** Active WhatsApp digits for the shopper's currency (INR → India, AED → Gulf, else India). */
function elWhatsAppNumber(currency) {
  var c = currency || (typeof document !== 'undefined' &&
    document.documentElement.getAttribute('data-currency')) || ELESSONS.defaultCurrency;
  return c === 'aed' ? (ELESSONS.whatsappAed || ELESSONS.whatsapp)
                     : (ELESSONS.whatsappInr || ELESSONS.whatsapp);
}

function elWhatsAppHref(message, currency) {
  return 'https://wa.me/' + elWhatsAppNumber(currency) +
    '?text=' + encodeURIComponent(message || '');
}

/* eLessons demo clips from the shared Drive folder (not third-party YouTube).
   player uses driveId with HTML5 / Drive preview — see gtec-ui.js. */
const PREVIEWS = {
  _default: { driveId: '1rRTXrlm2e3n0-Tnllyn0p0WYAc-Ejhqo', cap: 90, title: 'Watch a free demo class' },
  maths:      { driveId: '11F9JZjmJvTH4G81s_7R_5FPv9MtpucWd', cap: 90, title: 'Watch a maths lesson' },
  physics:    { driveId: '1He7btriFnWAg6csY0fsyfbC-txdE2ql4', cap: 90, title: 'Watch a physics lesson' },
  chemistry:  { driveId: '1w80LusfqXn7I3rhkseImc0CHzjIbuHWZ', cap: 90, title: 'Watch a chemistry lesson' },
  biology:    { driveId: '1T3jAz35H-bcuPYGL4hdMbkBCotHX0t5R', cap: 90, title: 'Watch a biology lesson' },
  science:    { driveId: '1He7btriFnWAg6csY0fsyfbC-txdE2ql4', cap: 90, title: 'Watch a science lesson' },
  english:    { driveId: '1rRTXrlm2e3n0-Tnllyn0p0WYAc-Ejhqo', cap: 90, title: 'Watch a sample lesson' }
};

function previewFor(grade, plan, subject) {
  var key = plan === 'subject' ? subject : null;
  var p = (key && PREVIEWS[key] && (PREVIEWS[key].driveId || PREVIEWS[key].vid))
    ? PREVIEWS[key] : PREVIEWS._default;
  return {
    driveId: p.driveId || PREVIEWS._default.driveId || null,
    vid: p.vid || null,
    cap: p.cap || 90,
    title: p.title || PREVIEWS._default.title
  };
}

/* Social proof — PLACEHOLDER — DO NOT SHIP. Replace with real values before launch. */
const TRUST = { rating: 4.8, reviewCount: 412, enrolled: 6800 };

/* ---------- SUBJECTS ----------
   Copy, banner classes and --banner colours lifted verbatim from indexnew.html
   so a detail page and a home card describe the same product identically. */
const SUBJECT_META = {
  maths:   { name: 'Maths',   code: 'MAT', banner: 'sb-maths',   colour: '#073790',
             tag: 'Think. Solve. Succeed.',
             blurb: 'Concept clarity first, then problem solving — worked at the board, step by step.' },
  science: { name: 'Science', code: 'SCI', banner: 'sb-science', colour: '#397417',
             tag: 'Physics, Chemistry & Biology.',
             blurb: 'Physics, chemistry and biology together — with the experiments that make each idea stick.' },
  english: { name: 'English', code: 'ENG', banner: 'sb-english', colour: '#47207C',
             tag: 'Read. Write. Communicate.',
             blurb: 'Grammar, vocabulary, writing and literature — the four strands the paper tests.' },
  /* Grades 11–12 sell these as individual subjects inside a stream package. */
  physics:     { name: 'Physics',          code: 'PHY', banner: 'sb-science', colour: '#2C5E14',
                 tag: 'Matter. Motion. Force.',
                 blurb: 'Mechanics, waves, electricity and modern physics — built at the board, equation by equation.' },
  chemistry:   { name: 'Chemistry',        code: 'CHE', banner: 'sb-science', colour: '#397417',
                 tag: 'Atoms to equations.',
                 blurb: 'Physical, organic and inorganic chemistry with the NCERT exercise sequence.' },
  biology:     { name: 'Biology',          code: 'BIO', banner: 'sb-science', colour: '#4A8C22',
                 tag: 'Life, explained.',
                 blurb: 'Cell biology, genetics, physiology and ecology — diagram-led and exam-ready.' },
  computer:    { name: 'Computer Science', code: 'CSC', banner: 'sb-science', colour: '#0E7490',
                 tag: 'Code. Logic. Systems.',
                 blurb: 'Programming, data structures and computer systems for the CBSE paper.' },
  accountancy: { name: 'Accountancy',      code: 'ACC', banner: 'sb-english', colour: '#92400E',
                 tag: 'Books that balance.',
                 blurb: 'Partnership, companies and financial statements — worked ledger by ledger.' }
};
const SUBJECT_ORDER = ['maths', 'science', 'english'];

/* ---------- PRICING ----------
   TRANSCRIBED FROM indexnew.html, not estimated. Every grade balances across
   currencies: the three subjects sum to the MRP, and MRP − bundle = the stated
   saving. Checked for all five grades in INR and AED.

   INR, AED and USD are INDEPENDENT authored lists — nothing is converted at
   runtime. USD is the rest-of-world fallback (≈ AED at the peg, rounded).
   Note the Gulf/USD lists deliberately charge the same for English as for
   Maths; that is their pricing, not a rounding artefact.

   Homepage cards sell live + recorded together at one authored price.
   Keep uplift at 0 so the enroll page matches the homepage (e.g. Grade 12
   package stays ₹18,000, not ₹23,000).                                      */
const LIVE_UPLIFT = {
  8:  { inr: 0, aed: 0, usd: 0 },
  9:  { inr: 0, aed: 0, usd: 0 },
  10: { inr: 0, aed: 0, usd: 0 },
  11: { inr: 0, aed: 0, usd: 0 },
  12: { inr: 0, aed: 0, usd: 0 }
};

const PRICING = {
  8:  { subjects: { maths: { inr: 8000,  aed: 400, usd: 109 }, science: { inr: 8000,  aed: 400, usd: 109 }, english: { inr: 4000, aed: 400, usd: 109 } },
        bundle: { inr: 12000, aed: 800,  usd: 218 }, modulePrice: { inr: 699, aed: 35, usd: 10 } },
  9:  { subjects: { maths: { inr: 8000,  aed: 400, usd: 109 }, science: { inr: 8000,  aed: 400, usd: 109 }, english: { inr: 4000, aed: 400, usd: 109 } },
        bundle: { inr: 12000, aed: 800,  usd: 218 }, modulePrice: { inr: 699, aed: 35, usd: 10 } },
  10: { subjects: { maths: { inr: 8000,  aed: 400, usd: 109 }, science: { inr: 8000,  aed: 400, usd: 109 }, english: { inr: 4000, aed: 400, usd: 109 } },
        bundle: { inr: 15000, aed: 1000, usd: 272 }, modulePrice: { inr: 699, aed: 35, usd: 10 } },
  /* Grades 11–12 sell stream packages (PCMB / PCMC / Commerce), with optional
     single-subject and per-module buys from the same syllabus PDFs. */
  11: { subjects: {
          maths: { inr: 8000, aed: 400, usd: 109 }, physics: { inr: 8000, aed: 400, usd: 109 },
          chemistry: { inr: 8000, aed: 400, usd: 109 }, biology: { inr: 8000, aed: 400, usd: 109 },
          computer: { inr: 8000, aed: 400, usd: 109 }, accountancy: { inr: 8000, aed: 400, usd: 109 }
        },
        streams: { pcmb: { inr: 18000, aed: 1200, usd: 327 }, pcmc: { inr: 18000, aed: 1200, usd: 327 }, commerce: { inr: 18000, aed: 1200, usd: 327 } },
        bundle: { inr: 18000, aed: 1200, usd: 327 }, modulePrice: { inr: 799, aed: 40, usd: 11 } },
  12: { subjects: {
          maths: { inr: 8000, aed: 400, usd: 109 }, physics: { inr: 8000, aed: 400, usd: 109 },
          chemistry: { inr: 8000, aed: 400, usd: 109 }, biology: { inr: 8000, aed: 400, usd: 109 },
          computer: { inr: 8000, aed: 400, usd: 109 }, accountancy: { inr: 8000, aed: 400, usd: 109 }
        },
        streams: { pcmb: { inr: 18000, aed: 1200, usd: 327 }, pcmc: { inr: 18000, aed: 1200, usd: 327 }, commerce: { inr: 18000, aed: 1200, usd: 327 } },
        bundle: { inr: 18000, aed: 1200, usd: 327 }, modulePrice: { inr: 799, aed: 40, usd: 11 } }
};

/* Senior secondary stream packages. English Grammar is complimentary on every annual package. */
const PACKAGE_META = {
  pcmb: {
    name: 'PCMB', code: 'PCMB', colour: '#397417', banner: 'sb-science',
    subjects: ['physics', 'chemistry', 'maths', 'biology'],
    tag: 'Physics · Chemistry · Maths · Biology',
    blurb: 'The full science stream — physics, chemistry, maths and biology — with free English Grammar included.'
  },
  pcmc: {
    name: 'PCMC', code: 'PCMC', colour: '#0E7490', banner: 'sb-science',
    subjects: ['physics', 'chemistry', 'maths', 'computer'],
    tag: 'Physics · Chemistry · Maths · Computer Science',
    blurb: 'Physics, chemistry, maths and computer science, with free English Grammar included.'
  },
  commerce: {
    name: 'Commerce', code: 'COM', colour: '#92400E', banner: 'sb-english',
    subjects: ['accountancy', 'maths'],
    tag: 'Accountancy · Maths',
    blurb: 'Accountancy and maths for the commerce stream, with free English Grammar included.'
  }
};
const PACKAGE_ORDER = ['pcmb', 'pcmc', 'commerce'];
function isStreamGrade(grade) {
  return !!(PRICING[grade] && PRICING[grade].streams);
}
function packagesForGrade(grade) {
  var p = PRICING[grade];
  if (!p || !p.streams) return [];
  return PACKAGE_ORDER.filter(function (k) { return !!p.streams[k]; });
}

/* ---------- REGISTER STREAMS ----------
   Colours anchored to the --banner values used by the subject cards.
   English Grammar is complimentary with every Annual Package (all grades). */
const STREAM_META = {
  maths:        { label: 'Mathematics',      code: 'MAT', colour: '#073790', parent: 'maths' },
  physics:      { label: 'Physics',          code: 'PHY', colour: '#2C5E14', parent: 'science' },
  chemistry:    { label: 'Chemistry',        code: 'CHE', colour: '#397417', parent: 'science' },
  biology:      { label: 'Biology',          code: 'BIO', colour: '#4A8C22', parent: 'science' },
  computer:     { label: 'Computer Science', code: 'CSC', colour: '#0E7490', parent: 'computer' },
  accountancy:  { label: 'Accountancy',      code: 'ACC', colour: '#92400E', parent: 'commerce' },
  english:      { label: 'English Grammar',  code: 'ENG', colour: '#47207C', parent: 'english', complimentary: true }
};

/* ---------- REGISTERS BY GRADE ----------
   Flat registers for grades 8–10. Grades 11–12 are keyed by stream package
   (pcmb / pcmc / commerce). Generated lists live in registers-generated.js. */
const REGISTERS = {
  8:  (typeof REGISTER_8  !== 'undefined') ? REGISTER_8  : null,
  9:  (typeof REGISTER_9  !== 'undefined') ? REGISTER_9  : null,
  10: (typeof REGISTER_10 !== 'undefined') ? REGISTER_10 : null,
  11: {
    pcmb:     (typeof REGISTER_11_PCMB     !== 'undefined') ? REGISTER_11_PCMB     : null,
    pcmc:     (typeof REGISTER_11_PCMC     !== 'undefined') ? REGISTER_11_PCMC     : null,
    commerce: (typeof REGISTER_11_COMMERCE !== 'undefined') ? REGISTER_11_COMMERCE : null
  },
  12: {
    pcmb:     (typeof REGISTER_12_PCMB     !== 'undefined') ? REGISTER_12_PCMB     : null,
    pcmc:     (typeof REGISTER_12_PCMC     !== 'undefined') ? REGISTER_12_PCMC     : null,
    commerce: (typeof REGISTER_12_COMMERCE !== 'undefined') ? REGISTER_12_COMMERCE : null
  }
};

function registerFor(grade, pkg) {
  var R = REGISTERS[grade];
  if (!R) return null;
  if (isStreamGrade(grade)) {
    var key = pkg || 'pcmb';
    return R[key] || null;
  }
  return R;
}
function hasRegister(grade, pkg) {
  var R = registerFor(grade, pkg);
  return !!(R && Object.keys(R).length);
}

/* ---------- HELPERS ---------- */
/** Repair PDF-extracted glued titles: "inOne" → "in One", "ofaNumber" → "of a Number". */
function elHumanizeTitle(s) {
  if (!s) return '';
  var t = String(s).replace(/\s+/g, ' ').trim();
  t = t.replace(/([a-z])([A-Z])/g, '$1 $2');
  t = t.replace(/ofalgebraic/gi, 'of algebraic')
       .replace(/andalgebraic/gi, 'and algebraic')
       .replace(/andincluded/gi, 'and included')
       .replace(/aformula/gi, 'a formula')
       .replace(/aforce/gi, 'a force')
       .replace(/Due toan/gi, 'Due to an')
       .replace(/ANecessary/gi, 'A Necessary')
       .replace(/andinaudible/gi, 'and inaudible')
       .replace(/anglesofa/gi, 'angles of a')
       .replace(/Diagonalsofa/gi, 'Diagonals of a')
       .replace(/ARectangle/gi, 'A Rectangle')
       .replace(/ABar Graph/gi, 'A Bar Graph')
       .replace(/andarea/gi, 'and area')
       .replace(/OFPolygons/g, 'of Polygons');
  t = t.replace(/\bofa\b/gi, 'of a').replace(/\bona\b/gi, 'on a').replace(/\banda\b/gi, 'and a');
  t = t.replace(/\btoa\b/gi, 'to a').replace(/\bbya\b/gi, 'by a').replace(/\bina\b/gi, 'in a');
  t = t.replace(/\bOF\b/g, 'of');
  return t.replace(/\s+/g, ' ').trim();
}
function lessonTitle(l)  {
  var raw = typeof l === 'string' ? l : (l && l.t) || '';
  return elHumanizeTitle(raw);
}
function lessonStatus(l) { return typeof l === 'string' ? 'ok' : (l.s || 'ok'); }

/* A lesson the source marks "Rejected" must never reach a learner. */
function publishedLessons(ch) {
  return (ch.v || []).filter(function (l) { return lessonStatus(l) !== 'rejected'; });
}
function streamChapters(grade, key, pkg) {
  var R = registerFor(grade, pkg);
  return (R && R[key]) || [];
}
function streamCount(grade, key, opts, pkg) {
  return streamChapters(grade, key, pkg).reduce(function (n, ch) {
    if (isRegisterHeaderChapter(ch)) return n;
    return n + (opts && opts.includeRejected ? (ch.v || []).length : publishedLessons(ch).length);
  }, 0);
}
function registerStreams(grade, pkg) {
  var R = registerFor(grade, pkg);
  return R ? Object.keys(R) : [];
}
function registerTotal(grade, opts, pkg) {
  return registerStreams(grade, pkg).reduce(function (n, k) { return n + streamCount(grade, k, opts, pkg); }, 0);
}
function chapterTotal(grade, pkg) {
  return registerStreams(grade, pkg).reduce(function (n, k) {
    return n + streamChapters(grade, k, pkg).filter(function (ch) {
      return !isRegisterHeaderChapter(ch) && publishedLessons(ch).length > 0;
    }).length;
  }, 0);
}
function streamsForSubject(subject) {
  return Object.keys(STREAM_META).filter(function (k) { return STREAM_META[k].parent === subject; });
}
function subjectsForGrade(grade, pkg) {
  if (isStreamGrade(grade)) {
    var meta = PACKAGE_META[pkg || 'pcmb'];
    if (!meta || !meta.subjects) return [];
    return meta.subjects.filter(function (s) {
      return streamChapters(grade, s, pkg).some(function (ch) {
        return publishedLessons(ch).length > 0 && !isRegisterHeaderChapter(ch);
      });
    });
  }
  return SUBJECT_ORDER.filter(function (s) { return PRICING[grade] && PRICING[grade].subjects && PRICING[grade].subjects[s]; });
}

/* PDF extracts sometimes keep the table header row as a fake chapter. */
function isRegisterHeaderChapter(ch) {
  var c = String((ch && ch.c) || '').toLowerCase().replace(/\s+/g, ' ').trim();
  if (c === 'chapter names' || c === 'chapter name' || c.indexOf('chapter names') === 0) return true;
  var lessons = publishedLessons(ch);
  if (lessons.length === 1 && String(lessonTitle(lessons[0])).toLowerCase().replace(/\s+/g, ' ').trim() === 'video names') {
    return true;
  }
  return false;
}

/* Streams a given plan actually unlocks — a Science purchase must not be
   described using the whole catalog's lesson count. For stream grades, the
   package key (pcmb/pcmc/commerce) selects the register. */
function streamsForPlan(grade, plan, subject, pkg) {
  var all = registerStreams(grade, pkg).filter(function (k) {
    return streamChapters(grade, k, pkg).some(function (ch) {
      return publishedLessons(ch).length > 0 && !isRegisterHeaderChapter(ch);
    });
  });
  if (isStreamGrade(grade)) {
    if (plan === 'subject' && subject) {
      return all.filter(function (k) { return k === subject; });
    }
    var meta = PACKAGE_META[pkg || 'pcmb'];
    var allowed = (meta && meta.subjects ? meta.subjects.slice() : []).concat(['english']);
    return all.filter(function (k) { return allowed.indexOf(k) > -1; });
  }
  if (plan !== 'subject') return all;
  var mine = streamsForSubject(subject);
  return all.filter(function (k) { return mine.indexOf(k) > -1; });
}
function planLessonCount(grade, plan, subject, pkg) {
  return streamsForPlan(grade, plan, subject, pkg).reduce(function (n, k) { return n + streamCount(grade, k, null, pkg); }, 0);
}
function planChapterCount(grade, plan, subject, pkg) {
  return streamsForPlan(grade, plan, subject, pkg).reduce(function (n, k) {
    return n + streamChapters(grade, k, pkg).filter(function (ch) {
      return !isRegisterHeaderChapter(ch) && publishedLessons(ch).length > 0;
    }).length;
  }, 0);
}

/* Returns { inr, aed, usd } so a price element can carry every authored
   figure, which is what location-based pricing reads. Never converts. */
function planPrice(grade, planType, mode, subjectKey, pkg) {
  var p = PRICING[grade];
  if (!p) return { inr: 0, aed: 0, usd: 0 };
  var base;
  if (isStreamGrade(grade) && (planType === 'full' || planType === 'stream')) {
    base = (pkg && p.streams && p.streams[pkg]) || p.bundle;
  } else if (planType === 'full') {
    base = p.bundle;
  } else if (planType === 'subject') {
    base = (p.subjects && p.subjects[subjectKey]) || { inr: 0, aed: 0, usd: 0 };
  } else {
    base = p.modulePrice;
  }
  if (mode !== 'live') return { inr: base.inr, aed: base.aed, usd: base.usd || 0 };

  var up = LIVE_UPLIFT[grade] || { inr: 0, aed: 0, usd: 0 };
  if (planType === 'full' || planType === 'stream') {
    return { inr: base.inr + up.inr, aed: base.aed + up.aed, usd: (base.usd || 0) + (up.usd || 0) };
  }
  if (planType === 'subject') {
    return {
      inr: base.inr + Math.round(up.inr / 2),
      aed: base.aed + Math.round(up.aed / 2),
      usd: (base.usd || 0) + Math.round((up.usd || 0) / 2)
    };
  }
  return { inr: base.inr + 300, aed: base.aed + 15, usd: (base.usd || 0) + 4 };
}

// What the Annual Package adds over the plan being viewed. Returns null when
// the current plan IS the full package, or when the upgrade is not cheaper.
function upgradeOffer(grade, plan, mode, subject, pkg) {
  if (plan !== 'subject') return null;
  var now  = planPrice(grade, 'subject', mode, subject, pkg);
  var full = planPrice(grade, 'full', mode, null, pkg);
  var diff = { inr: full.inr - now.inr, aed: full.aed - now.aed, usd: (full.usd || 0) - (now.usd || 0) };
  if (diff.inr <= 0) return null;
  var extra = hasRegister(grade, pkg)
    ? planLessonCount(grade, 'full', null, pkg) - planLessonCount(grade, 'subject', subject, pkg) : null;
  return { price: full, diff: diff, extraLessons: extra };
}

// The cheaper unit once N modules are selected, or null while modules still win.
// Grade 9 example: 12 modules beat a subject, 18 beat the whole package.
function betterThanModules(grade, count, subject, pkg) {
  if (!count) return null;
  var mp = PRICING[grade].modulePrice;
  var spend = mp.inr * count;
  var full = isStreamGrade(grade)
    ? ((pkg && PRICING[grade].streams && PRICING[grade].streams[pkg]) || PRICING[grade].bundle)
    : PRICING[grade].bundle;
  if (spend >= full.inr) {
    return { type: 'full', label: isStreamGrade(grade) && PACKAGE_META[pkg] ? PACKAGE_META[pkg].name : 'Annual Package', price: full };
  }
  if (subject && PRICING[grade].subjects && PRICING[grade].subjects[subject]) {
    var sub = PRICING[grade].subjects[subject];
    if (sub && spend >= sub.inr) {
      return { type: 'subject', subject: subject, label: SUBJECT_META[subject].name, price: sub };
    }
  }
  return null;
}
function fullMrp(grade, pkg) {
  return subjectsForGrade(grade, pkg).reduce(function (t, s) {
    var v = PRICING[grade].subjects[s];
    if (!v) return t;
    return { inr: t.inr + v.inr, aed: t.aed + v.aed, usd: t.usd + (v.usd || 0) };
  }, { inr: 0, aed: 0, usd: 0 });
}
function addMoney(a, b) {
  return { inr: a.inr + b.inr, aed: a.aed + b.aed, usd: (a.usd || 0) + (b.usd || 0) };
}
function mulMoney(a, n) {
  return { inr: a.inr * n, aed: a.aed * n, usd: (a.usd || 0) * n };
}

/* Formatting: rupee glyph + Indian grouping, "AED "/"$" with US grouping. */
function fmtMoney(v, cur) {
  var n = Math.round(v);
  if (cur === 'aed') return 'AED ' + n.toLocaleString('en-US');
  if (cur === 'usd') return '$' + n.toLocaleString('en-US');
  return '\u20B9' + n.toLocaleString('en-IN');
}
function priceAttrs(m) {
  return {
    inr: fmtMoney(m.inr, 'inr'),
    aed: fmtMoney(m.aed, 'aed'),
    usd: fmtMoney(m.usd || 0, 'usd')
  };
}


/* ---------- PLAN CATALOG ---------- */
function buildPlans() {
  var out = [];
  Object.keys(PRICING).forEach(function (g) {
    var grade = Number(g);
    if (isStreamGrade(grade)) {
      packagesForGrade(grade).forEach(function (pkg) {
        var meta = PACKAGE_META[pkg];
        out.push({
          id: 'g' + grade + '-' + pkg, grade: grade, type: 'full', subject: null, stream: pkg,
          title: 'Grade ' + grade + ' \u2014 ' + meta.name,
          blurb: meta.blurb,
          price: { recorded: planPrice(grade, 'full', 'recorded', null, pkg),
                   live:     planPrice(grade, 'full', 'live',     null, pkg) },
          featured: pkg === 'pcmb'
        });
      });
      return;
    }
    subjectsForGrade(grade).forEach(function (sub) {
      out.push({
        id: 'g' + grade + '-' + sub, grade: grade, type: 'subject', subject: sub,
        title: 'Grade ' + grade + ' \u2014 ' + SUBJECT_META[sub].name,
        blurb: SUBJECT_META[sub].blurb,
        price: { recorded: planPrice(grade, 'subject', 'recorded', sub),
                 live:     planPrice(grade, 'subject', 'live',     sub) }
      });
    });
    out.push({
      id: 'g' + grade + '-full', grade: grade, type: 'full', subject: null,
      title: 'Grade ' + grade + ' \u2014 Annual Package',
      blurb: 'Maths, Science and English together for grade ' + grade +
             ' \u2014 every lesson and notes file, with English Grammar included free.',
      price: { recorded: planPrice(grade, 'full', 'recorded'), live: planPrice(grade, 'full', 'live') },
      mrp: fullMrp(grade), featured: true
    });
    out.push({
      id: 'g' + grade + '-module', grade: grade, type: 'module', subject: null,
      title: 'Grade ' + grade + ' \u2014 Build your own',
      blurb: 'Pick only the chapters you need. Priced per module, added to your library instantly.',
      price: { recorded: planPrice(grade, 'module', 'recorded'), live: planPrice(grade, 'module', 'live') },
      perModule: true
    });
  });
  return out;
}
const PLANS = buildPlans();

const FAQS = [
  { q: 'What is the difference between Recorded and Live + Recorded?', a: 'Recorded gives you the full year of chalkboard video lessons plus notes, available the day you enrol, watched at your own pace. Live + Recorded adds weekly scheduled sessions with a mentor where you can ask questions in real time — and every live session is recorded and added to your library.' },
  { q: 'How long do I keep access?', a: 'Access runs for the full academic year from the date of purchase. Lessons stay unlocked for that entire period, so you can revise a chapter as many times as you need before an exam.' },
  { q: 'Can I buy just one subject or one chapter?', a: 'Yes — choose By Subject for a single subject, or By Module for individual chapters. Grades 11 and 12 also offer full stream packages (PCMB, PCMC or Commerce) when you want every subject in the stream.' },
  { q: 'What do grades 11 and 12 include?', a: 'Each grade offers three annual stream packages: PCMB (Physics, Chemistry, Maths, Biology), PCMC (Physics, Chemistry, Maths, Computer Science), and Commerce (Accountancy, Maths). English Grammar is complimentary with every package.' },
  { q: 'Is English Grammar included?', a: 'Yes. English Grammar is complimentary — included free — with every Annual Package for grades 8 to 12.' },
  { q: 'Is the syllabus aligned to the latest CBSE/NCERT pattern?', a: 'Yes. Every chapter follows the current NCERT textbook order, including the numbered exercises, so a lesson maps directly to the exercise you are working through at school.' },
  { q: 'Do I get notes as well as videos?', a: 'Every subject includes downloadable PDF notes covering the same chapters as the videos. Notes are included at no extra cost in all plans.' },
  { q: 'What device do I need?', a: 'Any modern browser on a phone, tablet, laptop or smart TV. There is nothing to install. The LMS remembers where you stopped on one device and resumes there on the next.' },
  { q: 'How do refunds work?', a: 'Refund eligibility is set out in the Terms of Service linked in the footer. Read those terms before purchasing, and message the team on WhatsApp if anything is unclear.' }
];

/**
 * Prompt 2: schema + on-page semantics for public/ static site.
 * Also syncs index.html → homepage.html and writes Prompt 3 DEPLOY.md.
 */
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const pub = path.join(root, 'public');
const indexPath = path.join(pub, 'index.html');

let html = fs.readFileSync(indexPath, 'utf8');
const nl = html.includes('\r\n') ? '\r\n' : '\n';

// ─── STEP 1: H1 — pull pill + hero-sub inside h1 (same classes) ───
const heroRe = /[ \t]*<span class="pill rv"><span class="dot"><\/span> CBSE \/ NCERT &middot; Grades 8&ndash;12 &middot; Live \+ recorded<\/span>\s*<h1 class="hero-title rv">\s*<span class="t-light">Traditional<\/span>\s*<span class="t-strong">Chalk-Board Class<\/span>\s*<\/h1>\s*<span class="gold-rule rv" aria-hidden="true"><\/span>\s*<p class="hero-sub rv">from <strong>The comfort of your home!<\/strong><\/p>/;

const newHero = [
  '      <h1 class="hero-title rv">',
  '        <span class="pill"><span class="dot"></span> CBSE / NCERT &middot; Grades 8&ndash;12 &middot; Live + recorded</span>',
  '        <span class="t-light">Traditional</span>',
  '        <span class="t-strong">Chalk-Board Class</span>',
  '        <span class="gold-rule" aria-hidden="true"></span>',
  '        <span class="hero-sub">from <strong>The comfort of your home!</strong></span>',
  '      </h1>',
].join(nl);

if (!heroRe.test(html)) {
  console.error('Hero block not found — aborting H1 patch');
  process.exit(1);
}
html = html.replace(heroRe, newHero);

// CSS so nested pill / hero-sub / gold-rule keep prior layout
const cssRe = /\.hero-copy \.pill\{margin-top:clamp\(\.9rem,1\.8vw,1\.35rem\)\}\s*\/\* display type[^*]*\*\/\s*\.hero-title\{margin-top:clamp\(\.8rem,1\.5vw,1\.3rem\)\}/;

const newHeroCss = [
  '.hero-copy .pill,.hero-title .pill{margin-top:clamp(.9rem,1.8vw,1.35rem)}',
  '',
  '/* display type — editorial serif against the heavy sans */',
  '.hero-title{margin:0;font-size:inherit;font-weight:inherit;line-height:inherit;color:inherit}',
  '.hero-title .t-light{margin-top:clamp(.8rem,1.5vw,1.3rem)}',
  '.hero-title .gold-rule{margin:clamp(1rem,1.7vw,1.5rem) 0 clamp(.85rem,1.5vw,1.15rem)}',
  '.hero-title .hero-sub{display:block}',
].join(nl);

if (!cssRe.test(html)) {
  console.error('Hero CSS block not found');
  process.exit(1);
}
html = html.replace(cssRe, newHeroCss);

// ─── STEP 2: Course card ids ───
const courseIds = [
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 8" style="--banner:var(--gold)">', id: 'course-8-all' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 8|Maths"', id: 'course-8-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 8|Science"', id: 'course-8-science' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 8|English"', id: 'course-8-english' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 9" style="--banner:var(--gold)">', id: 'course-9-all' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 9|Maths"', id: 'course-9-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 9|Science"', id: 'course-9-science' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 9|English"', id: 'course-9-english' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 10" style="--banner:var(--gold)">', id: 'course-10-all' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 10|Maths"', id: 'course-10-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 10|Science"', id: 'course-10-science' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 10|English"', id: 'course-10-english' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 11|PCMB|Science" style="--banner:var(--gold)">', id: 'course-11-pcmb' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMB|Physics|Science"', id: 'course-11-pcmb-physics' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMB|Chemistry|Science"', id: 'course-11-pcmb-chemistry' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMB|Maths|Science"', id: 'course-11-pcmb-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMB|Biology|Science"', id: 'course-11-pcmb-biology' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 11|PCMC|Science" style="--banner:var(--gold)">', id: 'course-11-pcmc' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMC|Physics|Science"', id: 'course-11-pcmc-physics' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMC|Chemistry|Science"', id: 'course-11-pcmc-chemistry' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMC|Maths|Science"', id: 'course-11-pcmc-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|PCMC|Computer Science|Science"', id: 'course-11-pcmc-cs' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 11|Commerce" style="--banner:var(--gold)">', id: 'course-11-commerce' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|Commerce|Accountancy"', id: 'course-11-accountancy' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 11|Commerce|Maths"', id: 'course-11-commerce-maths' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 12|PCMB|Science" style="--banner:var(--gold)">', id: 'course-12-pcmb' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMB|Physics|Science"', id: 'course-12-pcmb-physics' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMB|Chemistry|Science"', id: 'course-12-pcmb-chemistry' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMB|Maths|Science"', id: 'course-12-pcmb-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMB|Biology|Science"', id: 'course-12-pcmb-biology' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 12|PCMC|Science" style="--banner:var(--gold)">', id: 'course-12-pcmc' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMC|Physics|Science"', id: 'course-12-pcmc-physics' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMC|Chemistry|Science"', id: 'course-12-pcmc-chemistry' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMC|Maths|Science"', id: 'course-12-pcmc-maths' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|PCMC|Computer Science|Science"', id: 'course-12-pcmc-cs' },
  { match: '<article class="course course-bundle card-hover" data-tags="Grade 12|Commerce" style="--banner:var(--gold)">', id: 'course-12-commerce' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|Commerce|Accountancy"', id: 'course-12-accountancy' },
  { match: '<article class="course course-img card-hover" data-tags="Grade 12|Commerce|Maths"', id: 'course-12-commerce-maths' },
];

for (const { match, id } of courseIds) {
  if (html.includes(`id="${id}"`)) continue;
  if (!html.includes(match)) {
    console.warn('Course match missing:', id, match.slice(0, 60));
    continue;
  }
  html = html.replace(match, match.replace('<article ', `<article id="${id}" `));
}

// ─── STEP 3: Image alts ───
html = html.replace(
  '<img src="images/v25/hero-photo.webp" alt="" width="1957" height="802" fetchpriority="high" decoding="async">',
  '<img src="images/v25/hero-photo.webp" alt="Teacher writing on a chalk board during a G-TEC eLessons CBSE class" width="1957" height="802" fetchpriority="high" decoding="async">'
);
// hero-photo is decorative backdrop in a span aria-hidden — if parent is aria-hidden, alt won't be read.
// Prompt wants content alt; remove aria-hidden from the photo span so alt is available, keep scrim decorative.
html = html.replace(
  '<span class="hero-photo" aria-hidden="true">',
  '<span class="hero-photo">'
);

html = html.replace(
  '<img src="images/v25/board-model.webp" alt="" aria-hidden="true" width="560" height="700" loading="lazy">',
  '<img src="images/v25/board-model.webp" alt="Chalk-board lesson as it appears to a student watching on a phone" width="560" height="700" loading="lazy" decoding="async">'
);

html = html.replace(
  `src="images/v25/brand-lockup.webp" onerror="this.onerror=null;this.src='images/v23/brand-lockup.webp'" alt="" aria-hidden="true" width="1400" height="350" loading="lazy">`,
  `src="images/v25/brand-lockup.webp" onerror="this.onerror=null;this.src='images/v23/brand-lockup.webp'" alt="G-TEC eLessons" width="1400" height="350" loading="lazy" decoding="async">`
);

html = html.replace(
  'alt="G-TEC Education" width="484" height="300">',
  'alt="G-TEC Education" width="484" height="300" decoding="async">'
);

html = html.replace(
  'alt="G-TEC eLessons.net — Hybrid School" width="760" height="191">',
  'alt="G-TEC eLessons.net — Hybrid School" width="760" height="191" loading="lazy" decoding="async">'
);

html = html.replace(
  'alt="Portfolix.Tech" width="760" height="428" loading="lazy">',
  'alt="Portfolix.Tech" width="760" height="428" loading="lazy" decoding="async">'
);

// ─── STEP 4: JSON-LD @graph ───
const faqPairs = [
  {
    q: 'What exactly do I get for the annual fee?',
    a: 'Every video lesson and every notes file for one class, for the full academic year. Bundles run from ₹12,000, and single subjects start at ₹4,000. Grades 8 and 9 are ₹12,000, grade 10 is ₹15,000, and grades 11 and 12 are ₹18,000. There is nothing else to buy and no chapter is held back.',
  },
  {
    q: 'Are the classes live or recorded?',
    a: 'Both, and you do not choose between them. Every class has scheduled live sessions you can attend and ask questions in, and every session is recorded so it can be rewatched at any time until the academic year ends.',
  },
  {
    q: 'How long do I have access?',
    a: 'Until the end of the academic year you enrolled for. The whole year unlocks the day you pay, so you can revise or run ahead at any point.',
  },
  {
    q: 'Do you follow NCERT?',
    a: 'Yes. Lessons and notes are mapped chapter by chapter to the NCERT textbooks for the CBSE curriculum, grades 8 to 12.',
  },
  {
    q: 'How do I pay?',
    a: 'Prices are listed and charged in Indian rupees. UPI, net banking, and Indian debit and credit cards all work at checkout.',
  },
  {
    q: 'Is there a free demo?',
    a: 'Yes. A full sample lesson and a sample notes page are available above, with more in the demo section. No sign-up needed to watch.',
  },
  {
    q: 'What if my child falls behind?',
    a: 'Nothing expires mid-year. Any lesson can be rewatched as often as needed, and the notes for that chapter stay downloadable throughout.',
  },
];

function courseNode({ id, name, description, level, price, offerUrl }) {
  return {
    '@type': 'Course',
    '@id': `https://elessons.net/#${id}`,
    url: `https://elessons.net/#${id}`,
    name,
    description,
    provider: { '@id': 'https://elessons.net/#organization' },
    educationalLevel: level,
    inLanguage: 'en',
    offers: {
      '@type': 'Offer',
      category: 'Paid',
      price: String(price),
      priceCurrency: 'INR',
      availability: 'https://schema.org/InStock',
      url: `https://elessons.net/${offerUrl}`,
    },
    hasCourseInstance: {
      '@type': 'CourseInstance',
      courseMode: 'Online',
    },
  };
}

const courses = [
  courseNode({ id: 'course-8-all', name: 'CBSE Class 8 — All Subjects', description: 'Maths, Science and English for CBSE Class 8, full year.', level: 'CBSE Class 8', price: 12000, offerUrl: 'course-detail.html?grade=8&plan=full' }),
  courseNode({ id: 'course-9-all', name: 'CBSE Class 9 — All Subjects', description: 'Maths, Science and English for CBSE Class 9, full year.', level: 'CBSE Class 9', price: 12000, offerUrl: 'course-detail.html?grade=9&plan=full' }),
  courseNode({ id: 'course-10-all', name: 'CBSE Class 10 — All Subjects', description: 'Maths, Science and English for CBSE Class 10, full year.', level: 'CBSE Class 10', price: 15000, offerUrl: 'course-detail.html?grade=10&plan=full' }),
  courseNode({ id: 'course-11-pcmb', name: 'CBSE Class 11 — Physics, Chemistry, Maths, Biology', description: 'PCMB lessons and notes for CBSE Class 11, full year.', level: 'CBSE Class 11', price: 18000, offerUrl: 'course-detail.html?grade=11&plan=full&stream=pcmb' }),
  courseNode({ id: 'course-11-pcmc', name: 'CBSE Class 11 — Physics, Chemistry, Maths, Computer Science', description: 'PCMC lessons and notes for CBSE Class 11, full year.', level: 'CBSE Class 11', price: 18000, offerUrl: 'course-detail.html?grade=11&plan=full&stream=pcmc' }),
  courseNode({ id: 'course-11-commerce', name: 'CBSE Class 11 — Commerce', description: 'Accountancy and Maths for CBSE Class 11 commerce.', level: 'CBSE Class 11', price: 18000, offerUrl: 'course-detail.html?grade=11&plan=full&stream=commerce' }),
  courseNode({ id: 'course-12-pcmb', name: 'CBSE Class 12 — Physics, Chemistry, Maths, Biology', description: 'PCMB lessons and notes for CBSE Class 12, full year.', level: 'CBSE Class 12', price: 18000, offerUrl: 'course-detail.html?grade=12&plan=full&stream=pcmb' }),
  courseNode({ id: 'course-12-pcmc', name: 'CBSE Class 12 — Physics, Chemistry, Maths, Computer Science', description: 'PCMC lessons and notes for CBSE Class 12, full year.', level: 'CBSE Class 12', price: 18000, offerUrl: 'course-detail.html?grade=12&plan=full&stream=pcmc' }),
  courseNode({ id: 'course-12-commerce', name: 'CBSE Class 12 — Commerce', description: 'Accountancy and Maths for CBSE Class 12 commerce.', level: 'CBSE Class 12', price: 18000, offerUrl: 'course-detail.html?grade=12&plan=full&stream=commerce' }),
];

const graph = {
  '@context': 'https://schema.org',
  '@graph': [
    {
      '@type': 'EducationalOrganization',
      '@id': 'https://elessons.net/#organization',
      name: 'G-TEC eLessons.net',
      alternateName: 'G-TEC eLessons',
      url: 'https://elessons.net/',
      logo: 'https://elessons.net/images/v25/footer-logo.webp',
      image: 'https://elessons.net/og-cover.jpg',
      description: 'CBSE and NCERT live and recorded video lessons with printable notes for grades 8 to 12.',
      email: 'contact@elessons.net',
      telephone: '+91-97455-53944',
      address: {
        '@type': 'PostalAddress',
        streetAddress: 'Villa-19, Behind Al Twar Centre, Al Qusais 2',
        addressLocality: 'Dubai',
        addressCountry: 'AE',
      },
      location: [
        {
          '@type': 'Place',
          name: 'Registered office',
          address: {
            '@type': 'PostalAddress',
            streetAddress: '302, B-Wing, 3rd Floor, Pinnacle Corporate Park, Bandra Kurla Complex, Bandra East',
            addressLocality: 'Mumbai',
            postalCode: '400051',
            addressCountry: 'IN',
          },
        },
        {
          '@type': 'Place',
          name: 'Administrative office',
          address: {
            '@type': 'PostalAddress',
            streetAddress: 'House of G-TEC, Indus Avenue',
            addressLocality: 'Kozhikode',
            postalCode: '673002',
            addressCountry: 'IN',
          },
        },
      ],
      contactPoint: [
        {
          '@type': 'ContactPoint',
          telephone: '+91-97455-53944',
          contactType: 'customer service',
          areaServed: 'IN',
          availableLanguage: ['en'],
        },
        {
          '@type': 'ContactPoint',
          telephone: '+971-4-2665884',
          contactType: 'customer service',
          areaServed: 'AE',
        },
      ],
      areaServed: ['IN', 'AE', 'BH', 'SA', 'QA', 'KW', 'OM'],
    },
    {
      '@type': 'WebSite',
      '@id': 'https://elessons.net/#website',
      name: 'G-TEC eLessons.net',
      url: 'https://elessons.net/',
      publisher: { '@id': 'https://elessons.net/#organization' },
      inLanguage: 'en-IN',
    },
    {
      '@type': 'WebPage',
      '@id': 'https://elessons.net/#webpage',
      url: 'https://elessons.net/',
      name: 'CBSE Online Tuition for Classes 8–12 | Live + Recorded | G-TEC eLessons',
      description: 'CBSE and NCERT online tuition for classes 8 to 12. Live classes plus recorded lessons and printable notes, from ₹12,000 for the full academic year. Watch a free sample class.',
      isPartOf: { '@id': 'https://elessons.net/#website' },
      about: { '@id': 'https://elessons.net/#organization' },
      primaryImageOfPage: { '@type': 'ImageObject', url: 'https://elessons.net/og-cover.jpg' },
      inLanguage: 'en-IN',
    },
    {
      '@type': 'ItemList',
      '@id': 'https://elessons.net/#course-list',
      name: 'CBSE online courses — Grades 8 to 12',
      numberOfItems: courses.length,
      itemListElement: courses.map((c, i) => ({
        '@type': 'ListItem',
        position: i + 1,
        item: { '@id': c['@id'] },
      })),
    },
    ...courses,
    {
      '@type': 'VideoObject',
      '@id': 'https://elessons.net/#sample-lesson',
      name: 'G-TEC eLessons sample class — 90 second preview',
      description: 'A 90-second preview of a full chalk-board lesson, taught the same way as every chapter in the course.',
      duration: 'PT1M30S',
      contentUrl: 'https://www.youtube.com/watch?v=OY1JSCKysz0',
      embedUrl: 'https://www.youtube.com/embed/OY1JSCKysz0',
      thumbnailUrl: 'https://i.ytimg.com/vi/OY1JSCKysz0/hqdefault.jpg',
      isFamilyFriendly: true,
      publisher: { '@id': 'https://elessons.net/#organization' },
    },
    {
      '@type': 'FAQPage',
      '@id': 'https://elessons.net/#faq',
      mainEntity: faqPairs.map(({ q, a }) => ({
        '@type': 'Question',
        name: q,
        acceptedAnswer: { '@type': 'Answer', text: a },
      })),
    },
  ],
};

// Validate JSON
JSON.parse(JSON.stringify(graph));

const ldComment = `<!-- FAQPage: Google retired FAQ rich results on 7 May 2026. This markup is retained
     for Bing and AI/answer-engine parsing only. No Google rich result is expected. -->
<!-- parentOrganization: confirm legal relationship with G-TEC Education (gteceducation.com) before enabling -->
<script type="application/ld+json">
${JSON.stringify(graph)}
</script>`;

const oldLd = html.match(/<script type="application\/ld\+json">[\s\S]*?<\/script>/);
if (!oldLd) {
  console.error('Existing JSON-LD not found');
  process.exit(1);
}
html = html.replace(oldLd[0], ldComment);

fs.writeFileSync(indexPath, html);
fs.writeFileSync(path.join(pub, 'homepage.html'), html);
console.log('Updated index.html + homepage.html');

// Verify course ids exist
const missing = courses.filter((c) => !html.includes(`id="${c['@id'].split('#')[1]}"`));
if (missing.length) {
  console.error('Missing HTML ids for schema courses:', missing.map((c) => c['@id']));
  process.exit(1);
}
console.log('All 9 schema course ids present in HTML');

// ─── Other pages JSON-LD ───
function upsertLd(file, block) {
  const p = path.join(pub, file);
  let h = fs.readFileSync(p, 'utf8');
  h = h.replace(/<!-- FAQPage:[\s\S]*?<script type="application\/ld\+json"[^>]*>[\s\S]*?<\/script>\r?\n?/g, '');
  h = h.replace(/<script type="application\/ld\+json"[^>]*>[\s\S]*?<\/script>\r?\n?/g, '');
  if (!h.includes('</head>')) throw new Error(`No </head> in ${file}`);
  h = h.replace('</head>', `${block}\n</head>`);
  fs.writeFileSync(p, h);
  console.log('JSON-LD →', file);
}

const orgRef = { '@id': 'https://elessons.net/#organization' };

upsertLd(
  'about.html',
  `<script type="application/ld+json">
${JSON.stringify({
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'WebPage',
        '@id': 'https://elessons.net/about.html#webpage',
        url: 'https://elessons.net/about.html',
        name: 'About G-TEC eLessons | CBSE Online Classes for Grades 8–12',
        description: 'Who we are, how our chalk-board classes are recorded, and how G-TEC eLessons teaches the CBSE and NCERT syllabus for grades 8 to 12.',
        isPartOf: { '@id': 'https://elessons.net/#website' },
        about: orgRef,
        inLanguage: 'en-IN',
      },
      {
        '@type': 'BreadcrumbList',
        itemListElement: [
          { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://elessons.net/' },
          { '@type': 'ListItem', position: 2, name: 'About', item: 'https://elessons.net/about.html' },
        ],
      },
    ],
  })}
</script>`
);

upsertLd(
  'course-detail.html',
  `<script type="application/ld+json">
${JSON.stringify({
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'WebPage',
        '@id': 'https://elessons.net/course-detail.html#webpage',
        url: 'https://elessons.net/course-detail.html',
        name: 'Course Details | CBSE Online Classes Grades 8–12 | G-TEC eLessons',
        description: 'Full syllabus, subject list, and annual fee for this CBSE online course from G-TEC eLessons — live classes, recorded lessons, and printable notes.',
        isPartOf: { '@id': 'https://elessons.net/#website' },
        about: orgRef,
        inLanguage: 'en-IN',
      },
      {
        '@type': 'BreadcrumbList',
        itemListElement: [
          { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://elessons.net/' },
          { '@type': 'ListItem', position: 2, name: 'Courses', item: 'https://elessons.net/course-detail.html' },
        ],
      },
    ],
  })}
</script>`
);

// Body JSON-LD already removed by upsertLd (matches scripts with attributes)


upsertLd(
  'terms.html',
  `<script type="application/ld+json">
${JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://elessons.net/' },
      { '@type': 'ListItem', position: 2, name: 'Terms', item: 'https://elessons.net/terms.html' },
    ],
  })}
</script>`
);

upsertLd(
  'privacy.html',
  `<script type="application/ld+json">
${JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://elessons.net/' },
      { '@type': 'ListItem', position: 2, name: 'Privacy', item: 'https://elessons.net/privacy.html' },
    ],
  })}
</script>`
);

// Validate all JSON-LD blocks
for (const file of ['index.html', 'about.html', 'course-detail.html', 'terms.html', 'privacy.html']) {
  const h = fs.readFileSync(path.join(pub, file), 'utf8');
  const blocks = [...h.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)];
  for (const [, body] of blocks) {
    try {
      JSON.parse(body);
    } catch (e) {
      console.error('JSON-LD parse fail in', file, e.message);
      process.exit(1);
    }
  }
  console.log('Valid JSON-LD ×', blocks.length, 'in', file);
}

console.log('Prompt 2 script done');

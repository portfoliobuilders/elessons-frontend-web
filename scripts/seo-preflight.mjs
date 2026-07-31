/**
 * Prompt 3 pre-flight checks for public/ → GoDaddy public_html
 */
import fs from 'node:fs';
import path from 'node:path';

const pub = path.join(process.cwd(), 'public');
const htmlFiles = fs.readdirSync(pub).filter((f) => f.endsWith('.html'));

const fails = [];
const warns = [];
const rows = [];

function existsRel(href, fromFile) {
  if (!href || href.startsWith('data:') || href.startsWith('mailto:') || href.startsWith('tel:') || href.startsWith('https://') || href.startsWith('http://') || href.startsWith('//') || href.startsWith('#')) {
    return true;
  }
  const clean = href.split('?')[0].split('#')[0];
  if (!clean) return true;
  const target = clean.startsWith('/')
    ? path.join(pub, clean.slice(1))
    : path.join(pub, path.dirname(fromFile), clean);
  return fs.existsSync(target);
}

for (const file of htmlFiles) {
  const h = fs.readFileSync(path.join(pub, file), 'utf8');
  const title = (h.match(/<title>([^<]*)<\/title>/i) || [])[1] || '';
  const desc = (h.match(/<meta name="description" content="([^"]*)"/i) || [])[1] || '';
  const canon = (h.match(/<link rel="canonical" href="([^"]*)"/i) || [])[1] || '';
  const h1 = (h.match(/<h1[\s>]/gi) || []).length;
  const fav = h.includes('rel="icon"') && h.includes('/favicon.ico');
  const lang = /<html[^>]*lang="en-IN"/i.test(h);

  rows.push({ file, title, desc: desc.slice(0, 60), canon, h1, fav, lang });

  // Asset refs
  const refs = [
    ...[...h.matchAll(/<(?:img|script)[^>]+src="([^"]+)"/gi)].map((m) => m[1]),
    ...[...h.matchAll(/<link[^>]+href="([^"]+)"/gi)].map((m) => m[1]),
  ];
  for (const href of refs) {
    if (/localhost|127\.0\.0\.1|staging/i.test(href)) {
      fails.push(`${file}: absolute staging/local URL ${href}`);
    }
    if (!existsRel(href, file)) {
      fails.push(`${file}: missing asset ${href}`);
    }
  }

  // Internal <a href>
  for (const m of h.matchAll(/<a[^>]+href="([^"]+)"/gi)) {
    const href = m[1];
    if (href.startsWith('../')) warns.push(`${file}: relative ../ link ${href}`);
    if (!existsRel(href, file) && !href.startsWith('https://wa.me') && !href.startsWith('https://lms.') && !href.startsWith('https://portfolix') && !href.startsWith('https://www.youtube') && !href.startsWith('https://fonts') && !href.startsWith('https://elessons')) {
      if (!href.startsWith('http') && !href.startsWith('mailto') && !href.startsWith('tel') && !href.startsWith('#')) {
        fails.push(`${file}: broken link ${href}`);
      }
    }
  }
}

// Required root files
const required = [
  'favicon.ico', 'favicon.svg', 'apple-touch-icon.png', 'icon-192.png', 'icon-512.png',
  'icon-512-maskable.png', 'site.webmanifest', 'robots.txt', 'sitemap.xml', '404.html',
  '.htaccess', 'og-cover.jpg', 'index.html',
];
for (const f of required) {
  if (!fs.existsSync(path.join(pub, f))) fails.push(`missing root file: ${f}`);
}

// JS debug leftovers in shipped public js
for (const dir of ['js', 'assets/js']) {
  const d = path.join(pub, dir);
  if (!fs.existsSync(d)) continue;
  for (const f of fs.readdirSync(d).filter((x) => x.endsWith('.js'))) {
    const t = fs.readFileSync(path.join(d, f), 'utf8');
    if (/\bconsole\.log\(/.test(t)) warns.push(`${dir}/${f}: contains console.log`);
    if (/\bTODO\b/.test(t)) warns.push(`${dir}/${f}: contains TODO`);
  }
}

console.log('\n=== Per-page meta table ===');
console.log(
  ['file', 'h1', 'fav', 'lang', 'title', 'canonical'].map((c) => c.padEnd(c === 'title' ? 40 : 18)).join(' | ')
);
for (const r of rows) {
  console.log(
    [r.file.padEnd(18), String(r.h1).padEnd(18), String(r.fav).padEnd(18), String(r.lang).padEnd(18), r.title.slice(0, 40).padEnd(40), r.canon].join(' | ')
  );
}

// homepage.html is a deploy twin of index.html — exclude from uniqueness
const titles = rows
  .filter((r) => !['404.html', 'video-list.html', 'homepage.html'].includes(r.file))
  .map((r) => r.title);
const uniqTitles = new Set(titles);
if (uniqTitles.size !== titles.length) fails.push('Duplicate <title> values among indexable pages');

console.log('\n=== FAIL ===');
fails.forEach((f) => console.log('FAIL:', f));
console.log('\n=== WARN ===');
warns.forEach((w) => console.log('WARN:', w));
console.log('\nGO/NO-GO:', fails.length ? 'NO-GO' : 'GO');
process.exit(fails.length ? 1 : 0);

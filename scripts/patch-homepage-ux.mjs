import fs from 'fs';

const p = 'public/index.html';
let h = fs.readFileSync(p, 'utf8');

h = h.replace(/Academic year 2025&ndash;26 enrolment is open/g, 'Academic year 2026&ndash;27 enrolment is open');
h = h.replace(/2025&ndash;26/g, '2026&ndash;27');
h = h.replace(/2025–26/g, '2026–27');

h = h.replace(
  '<a href="#course-grid">Syllabus</a><a href="#">About us</a><a href="#">Terms</a>',
  '<a href="#course-grid">Syllabus</a><a href="about.html">About us</a><a href="terms.html">Terms</a>'
);
h = h.replace(
  '<a href="#">Privacy</a><a href="#faq">FAQ</a><a href="#contact">Contact us</a>',
  '<a href="privacy.html">Privacy</a><a href="#faq">FAQ</a><a href="#contact">Contact us</a>'
);

const waIn = 'https://wa.me/919745553944?text=' + encodeURIComponent("Hi GTEC Team, I'm interested in eLessons. Can you share more details?");
const waAe = 'https://wa.me/971503980768?text=' + encodeURIComponent("Hi GTEC Team, I'm interested in eLessons (UAE). Can you share more details?");

// Primary CTAs → India WhatsApp; keep Gulf number as dedicated Gulf WhatsApp in footer
h = h.replaceAll('https://wa.me/971503980768', waIn);
// Restore footer Gulf link specifically (last wa link that shows +971)
h = h.replace(
  new RegExp(`(<a href=")${waIn.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\$&')}(">\\+971 503980768</a>)`),
  `$1${waAe}$2`
);

h = h.replace(/>Buy now</g, '>Enroll Now<');
h = h.replace(/>Enrol now</g, '>Enroll Now<');
h = h.replace(/>Enrol</g, '>Enroll Now<');
h = h.replace(/>View package</g, '>Enroll Now<');

h = h.replace(
  '<button type="button" class="filter" aria-pressed="false">Grade 10</button>',
  '<button type="button" class="filter" aria-pressed="true" id="filter-default">Grade 10</button>'
);

h = h.replace('<option value="aed|BH">Bahrain · AED</option>', '<option value="aed|BH">Bahrain · priced in AED</option>');
h = h.replace('<option value="aed|SA">Saudi Arabia · AED</option>', '<option value="aed|SA">Saudi Arabia · priced in AED</option>');
h = h.replace('<option value="aed|QA">Qatar · AED</option>', '<option value="aed|QA">Qatar · priced in AED</option>');
h = h.replace('<option value="aed|KW">Kuwait · AED</option>', '<option value="aed|KW">Kuwait · priced in AED</option>');
h = h.replace('<option value="aed|OM">Oman · AED</option>', '<option value="aed|OM">Oman · priced in AED</option>');

h = h.replace(
  'src="images/v25/brand-lockup.webp"',
  'src="images/v25/brand-lockup.webp" onerror="this.onerror=null;this.src=\'images/v23/brand-lockup.webp\'"'
);
/* Keep the yellow-stripe thumbs-up model in the board band (v25/board-model.webp). */

h = h.replace(
  'id="announce-x" aria-label="Dismiss" style="cursor:pointer;opacity:.8;font-size:1.1rem;line-height:1"',
  'id="announce-x" aria-label="Dismiss" style="cursor:pointer;opacity:.8;font-size:1.1rem;line-height:1;min-width:44px;min-height:44px"'
);

h = h.replace(
  'font-size:.58rem;color:var(--gold)">iOS &amp; Android apps',
  'font-size:.7rem;color:var(--gold)">iOS &amp; Android apps'
);

// Science naming clarity on subject cards (Grade 8–10 science blurbs)
h = h.replace(
  /Explore\. Understand\. Excel\./g,
  'Physics, Chemistry &amp; Biology.'
);

fs.writeFileSync(p, h);
console.log('Patched', p);

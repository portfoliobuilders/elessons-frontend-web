# Course detail page — built on the indexnew.html design system

One new page. Nothing about your home page changes.

## This revision — seven defects found in the rendered page

Reviewing the built page turned up real bugs, not polish items. Ranked by damage:

1. **`.price-note` is a reserved class and I had used it.** Your currency
   switcher rewrites the text of *every* `.price-note` on the page. So the buy
   panel's "This subject · full academic year" and the syllabus caption were both
   being replaced at load with "India pricing, charged in Indian rupees at
   checkout." The buyer had no on-page statement of what they were buying. My
   captions now use `.note-sm` / `.buy-unit`, and exactly one deliberate
   `.price-note` remains — the currency line, where it belongs.

2. **A Grade 8 page was showing Grade 9's syllabus.** Only Grade 9 has a
   published class list, but the register rendered it for every grade — including
   the hero's "360 video lessons / 54 chapters" and the tier bullet "360 video
   lessons across 54 chapters". A Grade 8 parent was reading another grade's
   chapter list as if it were the product. The register is now keyed by grade;
   a grade with no data gets an honest "class list is being published" state with
   a WhatsApp route, and the invented counts are suppressed rather than guessed.

3. **Counts described the whole catalog, not the purchase.** A Grade 9 Science
   page claimed 360 lessons. Science is 143 (50 + 40 + 53). Every count is now
   scoped to the plan.

4. **The page contradicted itself on load.** `?plan=subject` set the heading to
   Science while the "Full package" tab stayed selected and its panel stayed
   open. Same for `?mode=live`. The controls now sync to state before
   `gtec-ui.js` reads them.

5. **The syllabus opened on Mathematics on a Science page,** and showed all five
   subjects regardless of what was being bought. It now shows the streams the
   plan actually unlocks, and adds a line quantifying what the full package would
   add — an upsell that is also just accurate.

6. **The Full package panel put one card in a three-column grid,** stranded at a
   third width against dead space. It now has its own two-column layout.

7. **Related products were four identical bundle cards.** A Science shopper now
   sees Science in other grades, which is both better merchandising and fixes the
   repeated artwork.

Fixing (5) introduced a further bug that the tests caught: re-rendering the
subject tabs destroyed the click and arrow-key handlers `gtec-ui.js` binds at
load, leaving the tabs dead after any plan change. `gtecInitTablist` is now
exposed so a re-rendered tablist can be re-bound, with a per-tab stamp so
re-running cannot double-bind.

---

Drop the folder in and open `course-detail.html`. It reads
`?grade=&plan=&subject=&mode=` from the URL, so a card on the home page links
straight into the right state:

```html
<a href="course-detail.html?grade=9&plan=full">…</a>
<a href="course-detail.html?grade=11&plan=subject&subject=maths&mode=live">…</a>
```

---

## What I took from your file rather than inventing

Everything visual now comes from `indexnew.html` itself, not from a screenshot:

- **`assets/css/gtec.css`** is your `<style>` block, extracted unchanged. Same
  tokens (`--navy-700`, `--gold`, `--hero-grad`, `--asym`, `--card-line`), same
  `.btn` / `.card` / `.mode` / `.faq` / `.tab` / `.pill` / `.gold-rule`
  components, same breakpoints.
- **`assets/js/gtec-ui.js`** is your nav drawer, `--nav-h` measurement, currency
  switcher, scroll-reveal and tab pattern, lifted verbatim.
- **The nav, announce bar and footer** are your markup, so the page sits under
  the same header it always did.
- **Fonts** are Plus Jakarta Sans + Instrument Serif + JetBrains Mono. My earlier
  guess had the display face right and the mono face wrong.
- **Primary CTA is `.btn-red`.** I had previously used gold; gold is your accent
  (the rule, the price in the hero, the "Best value" flag), not your buy button.

The 10 images that were inline base64 are now real files in `assets/img/`
(337 KB total). That was the only structural change I made to your assets, and
it's a straight win: they were being re-downloaded as part of the HTML on every
page load and could never be cached. `gtec.css` points at them by path.

### Three things I changed in your shared code, all marked in the file

1. **`[SCOPED]` / `[RE-INIT]`** — your tab script selected every `.tab` on the
   page as one roving tablist. This page has two independent tab groups
   (purchase options, and subject tabs in the syllabus), so the same logic now
   runs once per `[role="tablist"]`, and is exposed as `window.gtecInitTablist`
   so a tablist whose buttons get re-rendered can be re-bound. Your home page has
   one static tablist, so its behaviour is unchanged.
2. **`[HARDENED]`** — this one matters. The scroll-reveal ran
   `window.matchMedia(...)` and `new IntersectionObserver(...)` unguarded. If
   either is unavailable, the throw takes down **every script below it** — the
   currency switcher and the mobile drawer — and leaves every `.rv` element at
   `opacity:0`. The failure mode is a blank page with a dead menu, not a missing
   animation. It now fails in the safe direction: no observer, show everything.
   Worth patching on the home page too.
3. `announce-x` is wired up (it was commented out).

---

## Your price table, transcribed — and it corrects my earlier guesses

I had extrapolated grades 10–12 and invented a Social Science subject. Both were
wrong. The real table, read out of `indexnew.html`:

| Grade | Maths | Science | English | MRP | Bundle | Saving |
|---|---|---|---|---|---|---|
| 8 | ₹8,000 / AED 400 | ₹8,000 / AED 400 | ₹4,000 / AED 400 | ₹20,000 / AED 1,200 | ₹12,000 / AED 800 | ₹8,000 / AED 400 |
| 9 | ₹8,000 / AED 400 | ₹8,000 / AED 400 | ₹4,000 / AED 400 | ₹20,000 / AED 1,200 | ₹12,000 / AED 800 | ₹8,000 / AED 400 |
| 10 | ₹8,000 / AED 400 | ₹8,000 / AED 400 | ₹4,000 / AED 400 | ₹20,000 / AED 1,200 | ₹15,000 / AED 1,000 | ₹5,000 / AED 200 |
| 11 | ₹10,000 / AED 500 | ₹10,000 / AED 500 | ₹4,000 / AED 500 | ₹24,000 / AED 1,500 | ₹18,000 / AED 1,200 | ₹6,000 / AED 300 |
| 12 | ₹10,000 / AED 500 | ₹10,000 / AED 500 | ₹4,000 / AED 500 | ₹24,000 / AED 1,500 | ₹18,000 / AED 1,200 | ₹6,000 / AED 300 |

**There is no Social Science.** Grades 8–12 are Maths, Science, English only.

I checked every row both ways: the three subjects sum to the MRP, and
MRP − bundle equals the stated saving, in **both** currencies, for **all five**
grades. Your fee schedule is internally consistent.

I nearly reported a bug here and was wrong. Pooling the AED figures across
grades makes them look erratic (₹4,000 maps to both AED 400 and AED 500, and
₹8,000 also maps to AED 400). Read per grade they're coherent: the Gulf list
deliberately prices English the same as Maths. That's a pricing decision, not a
rounding error — worth knowing it's deliberate, because it means a Gulf parent
buying English alone pays proportionally much more than an Indian one.

### Currency is not converted, and now isn't on this page either

Your switcher comment is explicit: *nothing is converted at runtime — each price
element carries both authored figures.* My earlier build used a 0.044 multiplier,
which was the wrong architecture for your site. Every `.price` element this page
generates now carries both `data-inr` and `data-aed`, and your existing switcher
decides which shows. Changing a price re-dispatches `change` on your picker, so
there is still exactly one code path deciding the currency.

---

## The one number I invented

`LIVE_UPLIFT` in `course-data.js`. Your cards sell live and recorded together at
a single price; the brief asks for a mode selector that moves the price. So:

| Grade | Recorded | Live uplift | Live total |
|---|---|---|---|
| 8, 9 | ₹12,000 | +₹4,000 | ₹16,000 |
| 10 | ₹15,000 | +₹4,000 | ₹19,000 |
| 11, 12 | ₹18,000 | +₹5,000 | ₹23,000 |

Sign these off or **set them to 0**, which restores your current single-price
behaviour and leaves the toggle as a description of what's included. It's one
table at the top of `course-data.js`. Nothing else needs touching.

Per-subject live is uplift ÷ 2 and per-module live is +₹300; both are
interpolations from the same invented number.

---

## The syllabus data is real

All 361 Grade 9 lesson titles are transcribed from your PDF. Every subject total
was re-derived from the chapter lists and matched against the PDF's own summary:
135 / 50 / 41 / 53 / 82 = 361 across 54 chapters.

**Two problems in that PDF, both still outstanding:**

1. Chemistry → *Is Matter Around Us Pure* contains a row reading
   `Elements and Compounds------ Rejected`. That internal note is in a document
   you hand to prospects. It is tagged `s:'rejected'` and filtered from every
   public view, so **360 publish, not 361**. Re-shoot it or restate the number.
2. English → *Noun Number* lists `Singular - Plural Rules 1,2,3,4` twice, then
   jumps to `Rules 11,12`. Rules 5–10 look missing.

Durations aren't in the PDF, so none are shown. Add a `d` field per lesson and
set `ELESSONS.showDurations = true`.

Grades 8, 10, 11 and 12 have prices but no register — only the Grade 9 syllabus
was supplied. The syllabus section will be empty for them until that data exists.

---

## Files

```
course-detail.html          the page
video-list.html             printable class list (matches your sample PDF layout)
assets/css/gtec.css         your stylesheet, extracted
assets/css/detail.css       only the components your system didn't have
assets/js/course-data.js    catalog + real prices + the Grade 9 register
assets/js/detail.js         page logic
assets/js/gtec-ui.js        your shared behaviours
assets/img/*.webp           the 10 images, un-inlined
```

`detail.css` adds nothing to your brand: breadcrumb, buy panel, segmented mode
control, tier cards, module rows, the lesson register, and print rules. Every
value in it references a `gtec.css` token.

**Script order is load-bearing:** `course-data.js` → `detail.js` → `gtec-ui.js`.
`detail.js` renders synchronously so that everything `gtec-ui.js` binds to
already exists. If you reorder them the tabs and currency stop working.

**`.price-note` is reserved.** The currency switcher rewrites the text of every
element carrying that class. Use `.note-sm` for your own captions.

**Re-rendering a tablist needs `window.gtecInitTablist(el)` afterwards,** or the
new buttons have no handlers.

**Don't put `.rv` on anything generated by JS.** The reveal observer collects
`.rv` elements once at load, so dynamic content would stay invisible. No
generated markup on this page uses it.

---

## WhatsApp, LMS, analytics

`data-wa` builds the link and tracks the click. `data-wa-course` keeps the
message in sync with whatever the shopper is currently looking at:

```
https://wa.me/919745553944?text=Hi%20GTEC%20Team%2C%20I'm%20interested%20in%20Grade%209%20-%20Annual%20Package.%20Can%20you%20share%20more%20details%3F
```

Your site shows `+91 97455 53944`, but your schema block also lists two UAE
numbers (+971 4 2665884, +971 50 3980768) and a Dubai office. Right now every
WhatsApp lead lands on the Indian number. Given you run a separate AED price
list, you probably want to route Gulf visitors to a Gulf number —
`document.documentElement.dataset.currency` already tells you which they're on.

`data-lms` → `https://lms.elessons.net?redirect=<page>&course=g9-full`. Set the
real origin in `ELESSONS.lmsUrl`.

Analytics go through one function, `elTrack(event, params)`, which pushes to
`dataLayer` and calls `gtag` if present: `page_view`, `mode_change`,
`tier_tab`, `plan_select`, `add_to_cart`, `remove_from_cart`, `begin_checkout`,
`whatsapp_lead`, `lms_login_click`, `register_search`, `register_stream`,
`preview_click`, `pdf_download`, `plan_click`.

`begin_checkout` fires and then shows a toast — **the cart route is still a
TODO** in `detail.js`.

---

## Before this takes money

- **Recompute the price server-side.** `planPrice()` runs in the browser. Take
  `grade + plan + mode + modules` from the client, recompute, ignore the number
  they send.
- **The rating and enrolment figures in the hero are invented** (4.8, 412
  reviews, 6,800+ enrolled), as they were in my previous build. Replace them or
  delete the block.
- Contrast wasn't measured, only eyeballed. Run axe. The two I'd check are
  `.btn-red` white-on-#EF4444 and `--slate-400` on white.

---

## Verified by running it

A headless suite drives the built page: prices reproduce `indexnew.html` in both
currencies (₹12,000 / AED 800 bundle, ₹20,000 / AED 1,200 MRP, ₹8,000 / AED 400
saving); switching currency swaps to the authored AED figures rather than
converting; the mode toggle moves the panel price, the sticky bar and the
`Course` JSON-LD together; your tab pattern drives the purchase panels and the
H1 and price follow it; the module cart computes 3 × ₹699 = ₹2,097; arrow keys
switch subject tabs and re-render the register; and the printable list emits 360
rows across 54 rowspan-merged chapters.

The suite also covers the seven fixes above: Science reports 143 lessons not 360,
a Grade 8 page renders the empty state instead of Grade 9's chapters, `?plan=` and
`?mode=` sync the controls, subject tabs survive a plan change with arrow keys
intact and fire exactly one analytics event per click, module selections survive
switching tabs away and back, and all 15 grade × plan combinations render clean.

Two bugs found this way in the previous build are still fixed here: lesson
numbering used `indexOf` so repeated titles ("Solved Problems" appears three
times in *Force and Laws of Motion*) collided, and switching subject kept a stale
search term so a tab could open on an empty list.

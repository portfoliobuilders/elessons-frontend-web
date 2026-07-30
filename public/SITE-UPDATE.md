# G-TEC eLessons — home page update + course detail page

Open `index.html` in a browser. No build step, no server, no dependencies.

| File | What it is |
|---|---|
| `index.html` | Updated home page — breadcrumb, four-axis filter bar, rebuilt card grid |
| `course-detail.html` | New course detail page (Grade 9 – Annual Package) |
| `video-list.html` | Print-ready video class list → **Download as PDF** button |
| `elessons.css` | Design tokens + all components. Single source of truth |
| `elessons.js` | Behaviour: filters, mode toggle, syllabus, cart, analytics, WhatsApp, LMS |
| `course-data.js` | Course data. **Swap this for an API call and nothing else changes** |

---

## What was verified, and how

| Claim | How it was checked |
|---|---|
| Syllabus matches your PDF | All 361 rows transcribed, then machine-counted per subject against the PDF's own totals. Maths 135, Physics 50, Chemistry 41, Biology 53, English 82 — all match |
| No horizontal scroll | Measured `scrollWidth` in headless Chromium at 320 / 390 / 1024 / 1440px. Zero overflow |
| WCAG 2.1 AA | axe-core audit, both pages: **0 violations**. Seven contrast failures were found and each replacement colour re-derived by hand before applying |
| Behaviour works | 25 end-to-end tests in headless Chromium — pricing, tabs, keyboard arrows, filters, cart, link building, analytics events. All pass |
| PDF fits A4 | Every generated sheet measured against 297mm. No page spills |

---

## Three things to fix before this goes live

1. **The trust numbers are placeholders.** "4.9", "312 reviews", "7 countries", and the reviewer names and cities are not verified figures. The `aggregateRating` in the JSON-LD is flagged in the file — Google penalises invented review data, so replace it with your real count or delete the property.
2. **Pricing is assumed for grades 9–12.** Grade 8's prices are read off your live build and applied unchanged to every grade. Senior grades are almost certainly priced higher. `MODULE_PRICE` (₹699) and the ₹4,000 live uplift come from the mockups, not a live price list.
3. **Your PDF has an internal note in it.** Chemistry → *Is Matter Around Us Pure* contains a row reading `Elements and Compounds------ Rejected`. That is shipping to customers. It's flagged `status:"rejected"` in the data and filtered out of the public render, so the site correctly says **360** lessons, not 361. Regenerate the handout.

Two smaller data issues in the same PDF: English Grammar lists `Noun Number - Singular - Plural Rules 1,2,3,4` twice identically, and has duplicate chapter headings (Pronouns, Articles, Nouns, Verbs each appear twice). `Proposition - 1` is a typo for `Preposition`. These were kept verbatim so the page matches the handout — clean both together.

---

## Lesson runtimes are deliberately blank

The PDF has no durations and inventing them would be worse than showing a gap, so every row renders `—`. Fill the `d` field in `course-data.js` from the video host and the UI picks it up with no other change.

---

## Porting to your Next.js frontend

Everything is framework-free on purpose. Paste this into a fresh Cursor agent chat with the five files attached:

> Port this static build into the existing Next.js app at `elessons-frontend-web`.
>
> 1. Move the `:root` block from `elessons.css` into the global stylesheet as CSS custom properties. Do not convert them to Tailwind config — the rest of the CSS reads them directly.
> 2. Split `course-detail.html` into components: `<CourseHero>`, `<BuyBox>`, `<PurchaseTabs>`, `<SyllabusExplorer>`, `<FeatureGrid>`, `<TrustSection>`, `<FaqAccordion>`, `<RelatedCourses>`. Keep the class names exactly as they are so the stylesheet keeps working.
> 3. Replace `course-data.js` with a server component fetch to the NestJS catalogue endpoint. Keep the returned shape identical: `{ syllabus: { [subject]: [{ name, videos: [{ t, d, status, free }] }] } }`.
> 4. Keep every `data-track`, `data-wa` and `data-lms` attribute. The analytics, WhatsApp and LMS logic is attribute-driven and will keep working unchanged.
> 5. `elessons.js` is vanilla and idempotent. Convert each `init*()` function into a `useEffect` in the component that owns that markup. Do not merge them.
>
> Do not restyle anything. Do not add dependencies. Report which files you changed and stop.

---

## The two deliverables I could not produce

- **Figma mockups.** I can't create Figma files. These HTML files are the design source of truth — import them with the *html.to.design* plugin if you need them on a canvas, or point me at the tokens you want documented and I'll write the spec.
- **Exact stack match.** `indexnew.html` did not upload — the folder arrived empty. The visual system here is derived from a screenshot of your live Vercel build plus the two approved mockups, so it should sit consistently alongside what you have, but I could not diff it against your actual markup. Re-upload that file and I'll reconcile the class names.

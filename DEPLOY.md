# Deploy — G-TEC eLessons.net

**Production:** GoDaddy cPanel (Linux/Apache) → `public_html/`  
**Preview only:** Vercel (this repo’s `vercel.json`)

---

## What to upload

Upload the **contents** of `public/` into GoDaddy `public_html/` (not the `public` folder itself).

There is no required build step for GoDaddy. Optional local preview:

```bash
npm run build   # copies public/ → .vercel-out (Vercel test only)
npm run dev     # serves public/ on :3000
```

### Must sit at the ROOT of `public_html/`

| File | Notes |
|------|--------|
| `favicon.ico` | Multi-size ICO |
| `favicon.svg` | SVG icon |
| `apple-touch-icon.png` | 180×180 |
| `icon-192.png` | PWA |
| `icon-512.png` | PWA |
| `icon-512-maskable.png` | Android safe-zone |
| `favicon-32.png` | Legacy |
| `site.webmanifest` | Web app manifest |
| `robots.txt` | Crawler rules + sitemap link |
| `sitemap.xml` | `/`, `about.html`, `course-detail.html` |
| `404.html` | Custom error page |
| `.htaccess` | **Hidden file** — see below |
| `og-cover.jpg` | 1200×630 Open Graph image |
| `index.html` | Homepage |

Plus the rest of `public/` (`about.html`, `terms.html`, `privacy.html`, `course-detail.html`, `assets/`, `images/`, `css/`, `js/`, `pdfs/`, etc.).

### Do NOT upload

- `.git/`, `node_modules/`, `.env*`, `.vercel/`, `.cursor/`
- Repo root Flutter/Dart files (`lib/`, `android/`, `pubspec.yaml`, …)
- `*.md` (including this file), `scripts/`, `resources/`, `test/`
- `elessons-homepage.html` at repo root (use `public/index.html`)

### `.htaccess` (critical)

1. cPanel File Manager → **Settings** → enable **Show Hidden Files (dotfiles)**.
2. Confirm `.htaccess` lands in `public_html/`, not one level up.
3. If the site returns **500** after upload: rename `.htaccess` → `.htaccess.bak`, then re-add rules block by block.

### After upload — quick checks

1. `https://elessons.net/` looks unchanged (except favicon in the tab).
2. `https://elessons.net/favicon.ico` and `/robots.txt` and `/sitemap.xml` load.
3. `https://elessons.net/thispagedoesnotexist` → styled 404 (status 404).
4. `http://` and `www.` redirect to `https://elessons.net/`.
5. Paste homepage URL into [Rich Results Test](https://search.google.com/test/rich-results) → expect **Course list** with 9 items.
6. Search Console: add property, submit `sitemap.xml`, request indexing.

**Vercel is test/preview only.** Live traffic stays on GoDaddy.

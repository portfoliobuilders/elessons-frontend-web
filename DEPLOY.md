# Deploy G-TEC eLessons.net

## GoDaddy (production)

Upload **only** the contents of the `public/` folder into `public_html`.

1. Download the ready zip `elessons-godaddy-public-html.zip` from the agent artifacts, **or** build it yourself:

   ```bash
   npm run package:godaddy
   # → dist/elessons-godaddy-public-html.zip
   ```

   The zip must have site files at the **archive root** (not nested under a `public/` folder).
2. In cPanel → File Manager → `public_html`, **delete everything** from any previous upload (`android/`, `lib/`, nested `public/`, `pubspec.yaml`, old HTML, etc.).
3. Upload and extract the zip **inside** `public_html` (so `index.html` lands directly in `public_html/`).
4. Confirm `public_html/index.html`, `public_html/course-detail.html`, and `public_html/.htaccess` exist (enable “Show Hidden Files” for `.htaccess`).
5. Delete the uploaded zip from `public_html`, then hard-refresh the browser (Ctrl+F5).

See `public/UPLOAD-TO-GODADDY.txt` for a longer checklist.

### Correct layout

```
public_html/
  .htaccess
  index.html
  course-detail.html
  about.html
  assets/
  css/
  js/
  images/
  ...
```

### Wrong layout (causes 404s)

```
public_html/
  public/course-detail.html   ← nested — browsers request /course-detail.html and get 404
  lib/
  android/
  pubspec.yaml
```

## Vercel

`vercel.json` at the repo root is for Vercel deploys. GoDaddy ignores it and uses `.htaccess` instead.

## Demo video

Homepage demo uses a Google Drive preview (`data-drive` on `#lesson-player`), not a third-party YouTube lecture.

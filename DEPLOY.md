# Deploy G-TEC eLessons.net

## GoDaddy (production)

Upload **only** the contents of the `public/` folder into `public_html`.

1. Download / build the GoDaddy zip (`elessons-godaddy-public-html.zip`), or zip the `public/` folder yourself so files sit at the archive root.
2. In cPanel → File Manager → `public_html`, remove any previous **source-code** upload (`android/`, `lib/`, nested `public/`, `pubspec.yaml`, etc.).
3. Upload and extract the zip **inside** `public_html`.
4. Confirm `public_html/index.html`, `public_html/course-detail.html`, and `public_html/.htaccess` exist (show hidden files for `.htaccess`).
5. Soft-refresh the browser.

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

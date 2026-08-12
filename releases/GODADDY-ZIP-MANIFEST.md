# GoDaddy deploy zip — live site mirror

Built from `public/` which is byte-identical to the live Vercel site:

- Live: https://elessons-frontend-web.vercel.app/
- Canonical: https://elessons.net/

## Artifact

**File:** `elessons-godaddy-public-html.zip` (agent artifact / `dist/` after `npm run package:godaddy`)

| Check | Value |
|-------|--------|
| Zip SHA-256 | `32d6c5b4a2b51346d3f9341331429c6d1cacbd6d61192362604a49470f9386ee` |
| Entries | 223 |
| Approx size | 9.2 MB |
| `index.html` SHA-256 | `11db27178d50332cf96fd8b2b2edde6c65401787fcabdee9d67ffa238c43a8de` (matches live) |
| `course-detail.html` SHA-256 | `0ab21aa4ee41950963602e0772cbef83a79ea79910b37bbe34b42aa057fe28f9` (matches live) |

## Rebuild

```bash
npm run package:godaddy
# → dist/elessons-godaddy-public-html.zip
```

## Upload (GoDaddy cPanel)

1. Empty `public_html` of any previous wrong upload (Flutter source, nested `public/`, etc.).
2. Upload the zip into `public_html` and extract **at the top level**.
3. Confirm `public_html/index.html`, `public_html/course-detail.html`, and `public_html/.htaccess` exist.
4. Delete the zip from `public_html`, then hard-refresh.

See `public/UPLOAD-TO-GODADDY.txt` and `DEPLOY.md`.

# Contrast verification — WCAG AA (Phase 1.3)

Computed relative luminance ratios for token pairs. Target: **≥ 4.5:1** normal text, **≥ 3:1** UI / large text.

| Combination | Approx. ratio | Result | Token usage |
|---|---:|---|---|
| Navy-900 `#0F172A` on white | 16.6:1 | Pass AAA | `--text-primary` on `--bg-primary` |
| Red CTA `#DC2626` text on white | 4.8:1 | Pass AA | `--cta-accent` as text link |
| Slate-500 `#64748B` on white | 4.6:1 | Pass AA | `--text-secondary` body |
| White on Navy-900 `#0F172A` | 16.6:1 | Pass AAA | `--text-inverse` on hero |
| White on brand red `#EF4444` | 3.76:1 | Large/UI only — **fail** normal text | Do **not** use for button labels |
| White on CTA red `#DC2626` | 4.83:1 | Pass AA | `--cta-accent` button fills |
| Slate-300 `#CBD5E1` on Navy-900 | 12.0:1 | Pass AAA | Subtle copy on hero |
| Gold `#FACC15` on Navy-900 | 11.7:1 | Pass AAA | Accent italic on hero |
| Slate-400 `#94A3B8` on white | 2.56:1 | **Fail AA** | Do not use for body/caption on light |
| Slate-400 on Navy-900 | ≥ AA | Pass | `--text-on-dark-muted` |

## Adjustments made in `tokens.css`

1. **`--red-cta: #DC2626`** — button fills with white labels (4.83:1).
2. **`--cta-accent`** points at `--red-cta`, not raw `--red`.
3. **`--red: #EF4444`** kept for non-text brand accents (dots, underlines, icon strokes).
4. **`--text-tertiary`** uses slate-500 (not slate-400) so captions pass AA on white.
5. **`--text-on-dark-muted`** = slate-400 for muted copy on navy surfaces.
6. Marketing pages should set `data-color-scheme="light"` on `<html>` so OS dark mode does not invert the light brochure surface unexpectedly.

## Do not rely on colour alone

Pair status/stream colour with text labels (Science / Commerce) and patterns — see Phase 3 checklist.

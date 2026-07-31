# G-TEC Education — Flutter Mobile App

A production-structured Flutter implementation of the **G-TEC Education** student
app: a Class 8–12 CBSE tuition platform (course store, learning, live classes,
assignments, and progress). The UI is a faithful, pixel-conscious translation of
the supplied design — same palette, type scale, spacing, radii, shadows, and
motion language — not a redesign.

---

## Quick start

```bash
flutter pub get
flutter run
```

Requires **Flutter ≥ 3.27** (Dart ≥ 3.6). No API keys, secrets, or backend are
needed — the app is a self-contained, navigable front end with representative
sample data.

---

## What's in this build

The **mobile app flow** from the design — **38 screens** plus the full design
system and a reusable widget library:

- **Get started (1–6):** Welcome, Login, Create Account, OTP, Forgot Password,
  Reset Password.
- **Personalize (7–8):** Onboarding board picker, class picker.
- **Home & shell (9–13, 26, 28):** First-time home, Home, bottom-nav shell
  (Home · Store · Learnings · Profile), Notifications, Search.
- **Discover & purchase (13–19):** Store, Course Detail, Buy by Module, Cart,
  Checkout, Order Confirmed, Complete-profile (KYC).
- **Learn & live (20–25, 27):** Curriculum, Video Player, PDF/Notes viewer,
  Ask a Doubt, Live Classes, Live Room, Downloads (offline).
- **Account & support (29–34):** Edit Profile, Purchase History, Order Detail,
  Help & Support, plus Empty Cart / Empty Library states.
- **Assessment (35–38):** Assignments, Test attempt (exam mode with question
  palette + timer), Test Result (score ring + topic breakdown), Progress
  dashboard (weekly study chart + per-subject bars).

Every screen is wired through a single named-route table, so the whole app is
tappable end to end.

---

## Architecture

Clean, layered structure under `lib/`:

```
lib/
├── core/
│   ├── constants/      # app-wide constants, asset path registry
│   ├── theme/          # design tokens: colors, text styles, radii, shadows, ThemeData
│   ├── utils/          # HatchPainter (placeholder art), page transitions
│   └── services/       # reserved for data/services
├── models/             # plain data models
├── widgets/
│   ├── common/         # AppScaffold and shared scaffolding
│   ├── cards/          # stat/subject/course cards
│   ├── inputs/         # buttons, fields
│   ├── navigation/     # bottom nav
│   └── feedback/       # EmptyState, etc.
├── screens/            # 38 screens grouped by domain (auth, onboarding, home,
│                       #   store, course, cart, learning, profile, assessment, common)
├── routes/             # AppRoutes (names) + AppRouter (onGenerateRoute)
└── main.dart           # app entry, theme, system-UI overlay, scroll behavior
```

**Design system.** All visual values come from token files
(`core/theme/colors.dart`, `text_styles.dart`, `app_radius.dart`,
`app_shadows.dart`) — extracted directly from the design (navy `#16244A`,
signal-red `#E63946`, the 8-pt spacing rhythm, card/hero/button shadows, etc.).
Screens reference tokens rather than hard-coded values, so the look is
consistent and easy to retheme.

**Routing.** `AppRoutes` holds every route name; `AppRouter.onGenerateRoute`
maps each to a screen. Root/tab swaps use a fade; forward navigation uses the
design's fade-and-slide-up transition. The `home` and `store` routes resolve to
the bottom-nav shell with the right tab pre-selected.

**Responsiveness & polish.** Layouts use flexible widgets and `SafeArea`, text
scaling is clamped to a sane band, and scrolling uses iOS-style bouncing physics
to match the prototype's feel — so it holds up across phones and tablets on both
Android and iOS.

---

## Notes & decisions

- **Scope — mobile app built here.** The source archive contained three
  products: this **mobile app (Store Flow)**, plus a **Web Portal** (1440px
  desktop) and an **Admin Console** (1440×900 desktop). This deliverable is the
  mobile app. The two desktop products are a natural **follow-up Flutter Web
  target** and were intentionally not bundled into the phone app.

- **No fake device chrome.** The design mockups show a phone bezel and a painted
  `9:41` status bar — those are presentation scaffolding. The real app reproduces
  screen **content only** and relies on the device's own status bar via
  `SafeArea` + a transparent system overlay, which is the correct behavior on
  real hardware.

- **Fonts.** Plus Jakarta Sans (and JetBrains Mono for mono accents) load via the
  `google_fonts` package, which fetches and caches them on first run. If the
  device is offline at first launch, the layout falls back gracefully to the
  platform sans/mono face without breaking.

- **Placeholders.** Where the design used image placeholders, the app draws the
  same hatched fill procedurally (`HatchPainter` / `HatchTile`). Asset slots are
  reserved under `assets/` (`images/`, `icons/`, `lottie/`); drop real artwork in
  and wire it through the asset registry when available.

- **Sample data.** Commerce/learning content (courses, prices, cart totals, order
  numbers, the demo student profile) mirrors the values shown in the design and
  is presentational — ready to be swapped for a live data layer in
  `core/services`.

---

## Next steps

1. Add a data/service layer (`core/services`) and models, then bind screens to a
   real backend.
2. Introduce state management (e.g. Riverpod/Bloc) where flows need shared state
   (cart, auth/session, enrolment).
3. Drop in real assets and wire them through the asset registry.
4. Build the **Web Portal** and **Admin Console** as a Flutter Web target,
   reusing this design-token layer.

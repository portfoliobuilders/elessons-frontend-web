# AGENTS.md

## Cursor Cloud specific instructions

This repo contains **two products**:

1. **G-TEC Education — Flutter mobile app** (primary product). Root `pubspec.yaml`, entry `lib/main.dart`. Targets Android/iOS and Flutter Web.
2. **elessons-homepage — static marketing website** (`G-TEC eLessons.net`). Node package at root `package.json`, static files in `public/`, deployed to Vercel.

The VM snapshot already has the toolchains installed (see below); the startup update script only refreshes dependencies. Standard commands live in `README.md` and `package.json` — prefer those. The notes below are the non-obvious caveats.

### Flutter app (root)

- **Pin the Flutter version to 3.27.x.** The SDK is installed at `/opt/flutter` (symlinked into `/usr/local/bin`), checked out at tag **3.27.4** (Dart 3.6.2). Do **not** upgrade to the latest stable: on Flutter ≥ ~3.29 the build fails because `CupertinoPageTransitionsBuilder` was moved out of `package:flutter/material.dart` into `package:flutter/cupertino.dart`, and `lib/core/theme/app_theme.dart` only imports `material.dart`. `pubspec.yaml` declares `flutter >=3.27.0` / `dart >=3.6.0`.
- Web is enabled and `CHROME_EXECUTABLE=/opt/google/chrome/chrome`. Analytics are disabled.
- Commands: `flutter pub get`, lint `flutter analyze` (currently ~42 info/warnings, **0 errors**), test `flutter test`, run dev on web `flutter run -d web-server --web-port 8090 --web-hostname 0.0.0.0` (debug/dev compiler). Build web: `flutter build web`.
- **The app requires an external backend and there is no offline/mock mode.** `lib/core/config/app_config.dart` defaults `apiBase` to a hard-coded ngrok URL that is typically dead. Only client-side screens render without it (Welcome/landing incl. the class selector). Dynamic flows (login, Store catalog, Cart, Live, Learnings) show "Something went wrong / Server unavailable" until a reachable backend is provided. The backend ("G-TEC e-Lessons API", NestJS — see `swagger.json`) is **not in this repo**.
- To point the app at a running backend, pass it at build/run time: `flutter run --dart-define=BASE_URL=http://<host>:<port>` (the getter auto-appends `/api`). It is a compile-time define, not a runtime env var.
- The README's "no backend needed" note is outdated relative to the current code.

### Marketing site (root `package.json` / `public/`)

- Fully self-contained (no backend). Run dev: `npm run dev` (serves `public/` on **port 3000** via `npx --yes serve`). Build for Vercel: `npm run build` (`scripts/prepare-vercel.mjs`). No lint/test configured.
- To regenerate `public/` from the `resources/` sources: `python3 scripts/build-homepage.py` (Python 3 only; no extra deps).

import 'package:flutter/material.dart';

/// G-TEC Design System — Color tokens.
///
/// Extracted verbatim from the design's codified palette:
/// Navy primary + Signal-red accent, on a light surface system.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF16244A); // Primary
  static const Color navyDeep = Color(0xFF0E1A38); // Gradient end
  static const Color navyLight = Color(0xFF21356B); // Gradient start
  static const Color navyDarkest = Color(0xFF0A1228);
  static const Color signalRed = Color(0xFFE63946); // Accent

  // ── Ink / Text ─────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF141A2A); // Primary text
  static const Color bodyText = Color(0xFF3B4252); // Body copy
  static const Color slate = Color(0xFF7A8294); // Secondary text
  static const Color muted = Color(0xFF9AA2B1); // Tertiary / placeholder
  static const Color mutedAlt = Color(0xFF6B7486);
  static const Color iconMuted = Color(0xFFA6AEBD); // Inactive nav icon
  static const Color labelMuted = Color(0xFF8A92A3);
  static const Color monoText = Color(0xFF9AA6BE); // Avatar monogram text

  // ── Surfaces ───────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F9FC); // App background
  static const Color surfaceAlt = Color(0xFFF4F6FA); // Filled tiles
  static const Color surfaceSoft = Color(0xFFFAFBFE);
  static const Color deviceBg = Color(0xFF0A0E17); // Status bar pill

  // ── Borders / Dividers ───────────────────────────────────────────────────
  static const Color border = Color(0xFFE0E4EC); // Input border (default)
  static const Color borderSoft = Color(0xFFEDF0F5); // Card border
  static const Color borderSofter = Color(0xFFEEF1F6);
  static const Color divider = Color(0xFFEAEDF2);
  static const Color trackBg = Color(0xFFEDF0F5); // Progress track

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1F8A5B);
  static const Color successBg = Color(0xFFE9F4EF);
  static const Color successDeep = Color(0xFF14633F);
  static const Color redBg = Color(0xFFFDF3F4);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color amber = Color(0xFFFBBC05);
  static const Color star = Color(0xFFFFC53D);

  // ── On-navy text (light) ─────────────────────────────────────────────────
  static const Color onNavy = Color(0xFFFFFFFF);
  static const Color onNavySubtle = Color(0xFFC3CDE6);
  static const Color onNavyAccent = Color(0xFF9FB2E0);

  // ── Brand (3rd-party auth) ───────────────────────────────────────────────
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEA4335);
}

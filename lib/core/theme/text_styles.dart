import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// G-TEC Design System — Typography.
///
/// Family: Plus Jakarta Sans (mono accents: JetBrains Mono).
/// Fonts are sourced via `google_fonts`, which fetches them on first run and
/// caches them locally; if the device is offline on first launch it falls back
/// to the platform sans/mono face without breaking the layout.
/// Type scale codified in the design:
///   Display 25/800 (-0.6) · Title 19/800 (-0.4) · Heading 15/700
///   Body 13.5/500 · Caption 11.5/600 (uppercase, +0.5)
class AppTextStyles {
  AppTextStyles._();

  /// Resolved family names registered by `google_fonts`.
  static final String? fontFamily = GoogleFonts.plusJakartaSans().fontFamily;
  static final String? monoFamily = GoogleFonts.jetBrainsMono().fontFamily;

  static final TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.ink,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // ── Display / Headlines ──────────────────────────────────────────────────
  static final TextStyle display = _base.copyWith(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    height: 1.15,
  );

  static final TextStyle headlineHero = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    height: 1.18,
  );

  static final TextStyle title = _base.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
  );

  static final TextStyle titleSm = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static final TextStyle sectionTitle = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static final TextStyle heading = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle cardTitle = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static final TextStyle body = _base.copyWith(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.bodyText,
    height: 1.55,
  );

  static final TextStyle bodyLg = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slate,
    height: 1.55,
  );

  static final TextStyle bodyMuted = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedAlt,
  );

  // ── Buttons / CTAs ───────────────────────────────────────────────────────
  static final TextStyle button = _base.copyWith(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static final TextStyle buttonSm = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // ── Labels / Captions ────────────────────────────────────────────────────
  static final TextStyle label = _base.copyWith(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.mutedAlt,
  );

  static final TextStyle caption = _base.copyWith(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
    letterSpacing: 0.5,
  );

  static final TextStyle overline = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.muted,
  );

  static final TextStyle chip = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle navActive = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static final TextStyle navInactive = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.iconMuted,
  );

  static final TextStyle price = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.navy,
  );

  static final TextStyle mono = _base.copyWith(
    fontFamily: monoFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.monoText,
  );
}

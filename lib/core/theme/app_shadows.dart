import 'package:flutter/material.dart';

/// G-TEC Design System — Elevation / shadow tokens.
/// Translated from the design's `box-shadow` values.
class AppShadows {
  AppShadows._();

  /// Primary navy button — `0 12px 24px -8px rgba(22,36,74,0.5)`
  static List<BoxShadow> primaryButton = const [
    BoxShadow(
      color: Color(0x8016244A),
      blurRadius: 24,
      spreadRadius: -8,
      offset: Offset(0, 12),
    ),
  ];

  /// Focused input — `0 4px 14px -8px rgba(22,36,74,0.4)`
  static List<BoxShadow> focusedInput = const [
    BoxShadow(
      color: Color(0x6616244A),
      blurRadius: 14,
      spreadRadius: -8,
      offset: Offset(0, 4),
    ),
  ];

  /// Content card — `0 8px 18px -14px rgba(20,26,42,0.25)`
  static List<BoxShadow> card = const [
    BoxShadow(
      color: Color(0x40141A2A),
      blurRadius: 18,
      spreadRadius: -14,
      offset: Offset(0, 8),
    ),
  ];

  /// Hero card — `0 18px 30px -16px rgba(22,36,74,0.6)`
  static List<BoxShadow> hero = const [
    BoxShadow(
      color: Color(0x9916244A),
      blurRadius: 30,
      spreadRadius: -16,
      offset: Offset(0, 18),
    ),
  ];

  /// Floating chip / mentor — `0 18px 30px -14px rgba(0,0,0,0.5)`
  static List<BoxShadow> floating = const [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 30,
      spreadRadius: -14,
      offset: Offset(0, 18),
    ),
  ];

  /// Big presentation card — `0 40px 80px -30px rgba(15,23,42,0.45)`
  static List<BoxShadow> elevated = const [
    BoxShadow(
      color: Color(0x730F172A),
      blurRadius: 80,
      spreadRadius: -30,
      offset: Offset(0, 40),
    ),
  ];

  /// Bottom bar / app bar drop — subtle top shadow.
  static List<BoxShadow> bar = const [
    BoxShadow(
      color: Color(0x0A141A2A),
      blurRadius: 16,
      offset: Offset(0, -2),
    ),
  ];

  static BoxShadow soft(Color base, {double opacity = 0.12}) => BoxShadow(
        color: base.withValues(alpha: opacity),
        blurRadius: 22,
        spreadRadius: -8,
        offset: const Offset(0, 10),
      );
}

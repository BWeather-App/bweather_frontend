// lib/constants/app_colors.dart
//
// Semua warna yang digunakan di seluruh aplikasi BWeather.
// Sebelumnya warna-warna ini tersebar di:
//   - weather_home.dart
//   - weather_detail_sheet.dart
//   - weather_header.dart
//   - main.dart (ThemeData)
//
// Cara pakai:
//   final textColor = AppColors.textPrimary(context);
//   final cardBg   = AppColors.cardBackground(context);
//
// Untuk warna yang tidak bergantung tema, akses langsung:
//   AppColors.darkBackground  → Color(0xFF232B3E)

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Tidak bisa di-instantiate

  // ─────────────────────────────────────────────
  // Static Brand Colors (tidak bergantung tema)
  // ─────────────────────────────────────────────

  /// Warna background gelap utama (Dark scaffold / Light text primary)
  static const Color darkBackground = Color(0xFF232B3E);

  /// Warna background terang utama (Light scaffold)
  static const Color lightBackground = Color(0xFFFCFAF6);

  /// Warna aksen biru untuk border kompas & elemen aksen
  static const Color accentBlue = Color(0xFF4A9EFF);

  // ─────────────────────────────────────────────
  // UV Index Gradient Colors
  // ─────────────────────────────────────────────

  static const List<Color> uvGradient = [
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.purple,
  ];

  // ─────────────────────────────────────────────
  // Theme-aware Colors
  // Gunakan method ini agar widget tidak perlu
  // tulis logika isDark berulang-ulang.
  // ─────────────────────────────────────────────

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Warna teks utama
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? Colors.white : darkBackground;

  /// Warna teks sekunder / subtitle / hint
  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? Colors.white70 : Colors.black54;

  /// Warna hint (lebih pudar dari secondary)
  static Color textHint(BuildContext context) =>
      _isDark(context) ? Colors.white38 : Colors.black38;

  /// Warna ikon utama
  static Color icon(BuildContext context) =>
      _isDark(context) ? Colors.white70 : Colors.black54;

  /// Background kartu (UV, kelembaban, dll)
  static Color cardBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03);

  /// Background card di home (opaque di light, transparan di dark)
  static Color cardBackgroundHome(BuildContext context) =>
      _isDark(context) ? Colors.white.withValues(alpha: 0.05) : Colors.white;

  /// Border kartu
  static Color cardBorder(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.1);

  /// Background input / field
  static Color inputBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.black.withValues(alpha: 0.05);

  /// Background blur overlay
  static Color blurBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05);

  // ─────────────────────────────────────────────
  // Sun Path Painter Colors
  // ─────────────────────────────────────────────

  static Color sunPathArc(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3);

  /// Versi tanpa context — untuk CustomPainter yang tidak punya BuildContext
  static Color sunPathArc_static(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3);

  static Color sunPathFill(bool isDark) =>
      isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.1);

  static Color sunIcon(bool isDark) =>
      isDark ? Colors.orangeAccent : Colors.deepOrange;

  // ─────────────────────────────────────────────
  // Compass Painter Colors
  // ─────────────────────────────────────────────

  static Color compassStroke(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4);

  static Color compassArrow(bool isDark) =>
      isDark ? Colors.white : Colors.black;

  static const Color compassGlowLight = Color(0xFFFFFDF3);
  static const Color compassGlowDark = Color(0xFF282C3B);

  static Color compassGlow(bool isDark) =>
      isDark ? compassGlowLight : compassGlowDark;

  static const Color actionButton = Color(0xFF51576D);

  static Color selectedCardBackground(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.1);
}

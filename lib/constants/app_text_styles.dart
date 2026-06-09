// lib/constants/app_text_styles.dart
//
// Semua TextStyle yang digunakan di seluruh aplikasi BWeather.
//
// Font: Poppins (default via ThemeData) + Montserrat untuk angka/value.
// Menggunakan google_fonts package — auto-download & cache.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─────────────────────────────────────────────
  // Home Screen — Tampilan Suhu Utama
  // ─────────────────────────────────────────────

  static TextStyle temperatureLarge(BuildContext context) => GoogleFonts.montserrat(
    color: AppColors.textPrimary(context),
    fontSize: 80,
    fontWeight: FontWeight.bold,
  );

  static TextStyle temperatureUnit(BuildContext context) => GoogleFonts.montserrat(
    color: AppColors.textPrimary(context),
    fontSize: 22,
  );

  static TextStyle weatherDescription(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontSize: 18,
  );

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────

  static TextStyle locationCity(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static TextStyle locationCountry(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 10,
    letterSpacing: 2,
  );

  // ─────────────────────────────────────────────
  // Card Labels (UV, Humidity, Feels Like, dll)
  // ─────────────────────────────────────────────

  static TextStyle cardLabel(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle cardValue(BuildContext context) => GoogleFonts.montserrat(
    color: AppColors.textPrimary(context),
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );

  static TextStyle cardDescription(BuildContext context) => GoogleFonts.montserrat(
    color: AppColors.textSecondary(context),
    fontSize: 10,
    height: 16.0 / 10.0,
  );

  // ─────────────────────────────────────────────
  // Weekly Forecast Row
  // ─────────────────────────────────────────────

  static TextStyle forecastDay(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle forecastDayToday(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static TextStyle forecastTemp(BuildContext context) => GoogleFonts.montserrat(
    color: AppColors.textPrimary(context),
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // ─────────────────────────────────────────────
  // Hourly Forecast Chart
  // ─────────────────────────────────────────────

  static TextStyle chartAxisLabel(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 10,
  );

  static TextStyle sectionLabel(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 12,
  );

  // ─────────────────────────────────────────────
  // Compass / Wind Direction
  // ─────────────────────────────────────────────

  static TextStyle compassDirection(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle windSpeed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      color: AppColors.compassGlow(isDark),
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle windUnit(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      color: AppColors.compassGlow(isDark),
      fontSize: 8,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle windSummary(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────────
  // Info Row (Angin di home)
  // ─────────────────────────────────────────────

  static TextStyle infoRow(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
  );

  // ─────────────────────────────────────────────
  // Search Page
  // ─────────────────────────────────────────────

  static TextStyle searchTitle(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontWeight: FontWeight.w500,
  );

  static TextStyle searchSubtitle(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontWeight: FontWeight.w300,
    fontSize: 12,
  );

  static TextStyle searchInput(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontWeight: FontWeight.w500,
  );

  static TextStyle searchHint(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textHint(context),
    fontWeight: FontWeight.w400,
  );

  static TextStyle searchSection(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle searchListTitle(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontWeight: FontWeight.w500,
  );

  static TextStyle searchListSubtitle(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 12,
  );

  static TextStyle searchListLabel(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontWeight: FontWeight.w400,
  );

  static TextStyle searchActionDelete(BuildContext context) => GoogleFonts.poppins(
    color: Colors.redAccent,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────────
  // Empty / Error State
  // ─────────────────────────────────────────────

  static TextStyle emptyTitle(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textPrimary(context),
    fontSize: 16,
  );

  static TextStyle emptySubtitle(BuildContext context) => GoogleFonts.poppins(
    color: AppColors.textSecondary(context),
    fontSize: 12,
  );
}

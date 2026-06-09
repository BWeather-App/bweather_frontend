// lib/constants/app_dimensions.dart
//
// Semua nilai spacing, padding, radius, dan ukuran ikon
// yang sebelumnya tersebar sebagai magic number di:
//   - weather_detail_sheet.dart (static const di WeatherWidgets)
//   - weather_home.dart         (inline angka-angka)
//   - weather_header.dart       (inline angka-angka)
//
// Cara pakai:
//   padding: const EdgeInsets.all(AppDimensions.cardPadding)
//   borderRadius: BorderRadius.circular(AppDimensions.cardRadius)

class AppDimensions {
  AppDimensions._();

  // ─────────────────────────────────────────────
  // Card
  // ─────────────────────────────────────────────

  static const double cardPadding = 14.0;
  static const double cardRadius = 22.0;
  static const double cardMinHeight = 170.0;
  static const double cardRowHeight = 180.0;
  static const double cardBorderWidth = 1.0;

  // ─────────────────────────────────────────────
  // Spacing
  // ─────────────────────────────────────────────

  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;

  // ─────────────────────────────────────────────
  // Icon Sizes
  // ─────────────────────────────────────────────

  /// Ikon label kartu kecil (UV, kelembaban, dll)
  static const double iconCard = 14.0;

  /// Ikon info row di home (angin, dll)
  static const double iconInfo = 24.0;

  /// Ikon section label (jam, lokasi)
  static const double iconSection = 13.0;

  /// Ikon cuaca utama di home
  static const double iconWeatherMain = 80.0;
  static const double iconWeatherMainHeight = 70.0;

  /// Ikon cuaca di forecast mingguan
  static const double iconWeatherForecast = 24.0;

  // ─────────────────────────────────────────────
  // Compass
  // ─────────────────────────────────────────────

  static const double compassSize = 120.0;
  static const double compassInnerSize = 49.0;
  static const double compassRadius = 15.0;
  static const double compassBorderWidth = 2.0;

  // ─────────────────────────────────────────────
  // Hourly Chart
  // ─────────────────────────────────────────────

  static const double chartHeight = 150.0;

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────

  static const double headerPaddingH = 16.0;
  static const double headerPaddingV = 12.0;

  // ─────────────────────────────────────────────
  // Page / Scaffold
  // ─────────────────────────────────────────────

  static const double pageViewHeightFactor = 0.8;
}

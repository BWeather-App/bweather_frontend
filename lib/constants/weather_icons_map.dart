// lib/constants/weather_icons_map.dart
//
// Peta kondisi cuaca → path aset ikon.
// Sebelumnya logic ini ada di WeatherModel.getIconAsset()
// dan WeatherModel.getWeatherDescription() di weather_model.dart.
//
// Dipisahkan ke sini supaya:
//   1. WeatherModel tidak perlu tahu soal UI/assets
//   2. Mudah di-update jika ada ikon baru
//   3. Bisa dipakai tanpa import WeatherModel
//
// Cara pakai:
//   final path = WeatherIcons.getAsset('hujan ringan', isDark: true);
//   final desc = WeatherIcons.getDescription(temp: 32, humidity: 60, rainChance: 10);

class WeatherIcons {
  WeatherIcons._();

  static const String _base = 'assets/icons/';

  // ─────────────────────────────────────────────
  // Mapping kondisi (lowercase) → nama file ikon
  // ─────────────────────────────────────────────

  static const Map<String, String> _conditionToIcon = {
    // Bahasa Indonesia
    'cerah': 'clear',
    'berawan': 'cloudy',
    'berawan dan lembab': 'cloudy',
    'hujan ringan': 'rainy',
    'hujan lebat': 'storm',
    'panas terik': 'clear',

    // English (dari API / WeatherAPI)
    'clear': 'clear',
    'clouds': 'cloudy',
    'rain': 'rainy',
    'drizzle': 'rainy',
    'thunderstorm': 'storm',
    'storm': 'storm',
    'snow': 'snowy',
    'mist': 'foggy',
    'fog': 'foggy',
    'haze': 'cloudy',
    'windy': 'windy',
    'berangin': 'windy',
  };

  // ─────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────

  /// Mengembalikan path aset ikon berdasarkan kondisi cuaca.
  ///
  /// [condition] — string kondisi cuaca (case-insensitive).
  /// [isDark]    — true untuk ikon versi dark mode.
  ///
  /// Fallback ke 'cloudy' jika kondisi tidak dikenali.
  static String getAsset(dynamic condition, {required bool isDark}) {
    final key = (condition is String) ? condition.toLowerCase() : 'clear';
    final iconName = _conditionToIcon[key] ?? 'unknown';
    final theme = isDark ? 'dark' : 'light';
    return '$_base$theme/$iconName.png';
  }

  /// Mengembalikan deskripsi kondisi cuaca dalam Bahasa Indonesia
  /// berdasarkan nilai suhu, kelembapan, dan peluang hujan.
  ///
  /// Gunakan ini sebagai "label" cuaca ketika API tidak
  /// mengembalikan deskripsi teks.
  static String getDescription({
    required num temp,
    required num humidity,
    required num rainChance,
  }) {
    if (rainChance > 80) return 'Hujan Lebat';
    if (rainChance > 50) return 'Hujan Ringan';
    if (humidity > 80 && temp < 26) return 'Berawan dan Lembab';
    if (temp >= 30 && rainChance < 20) return 'Panas Terik';
    if (temp <= 25 && rainChance < 10) return 'Cerah';
    return 'Berawan';
  }

  /// Versi convenience yang menerima Map data cuaca.
  static String getDescriptionFromMap(Map<String, dynamic> weather) {
    // Support dua format: flat map dan nested 'weather' key
    final data =
        (weather['weather'] is Map)
            ? Map<String, dynamic>.from(weather['weather'])
            : weather;

    final temp = (data['suhu'] ?? 0) as num;
    final humidity = (data['kelembapan'] ?? 0) as num;
    final rainChance = (data['peluang_hujan'] ?? 0) as num;

    return getDescription(
      temp: temp,
      humidity: humidity,
      rainChance: rainChance,
    );
  }
}

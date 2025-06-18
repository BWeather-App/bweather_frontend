// weather_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class WeatherModel {
  // State global yang bisa diakses dari mana saja
  static final ValueNotifier<Map<String, dynamic>?> weatherData = ValueNotifier(
    null,
  );
  static final ValueNotifier<bool> isLoading = ValueNotifier(true);

  // Fungsi untuk memuat data cuaca berdasarkan lokasi saat ini
  static Future<void> loadWeatherData(BuildContext context) async {
    isLoading.value = true;

    final granted = await PermissionService.requestLocationPermission(context);
    if (!granted) {
      isLoading.value = false;
      return;
    }

    try {
      final position = await LocationService().getCurrentLocation();
      final result = await WeatherService().getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      weatherData.value = result;
    } catch (e) {
      debugPrint('Gagal memuat data cuaca: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Deskripsi kondisi cuaca berdasarkan nilai suhu, kelembapan, dan peluang hujan
  static String getWeatherDescription(Map<String, dynamic> weather) {
    final weatherDetail = weather['weather'] ?? {};
    final temp = weatherDetail['suhu'] ?? 0;
    final humidity = weatherDetail['kelembapan'] ?? 0;
    final rainChance = weatherDetail['peluang_hujan'] ?? 0;

    if (rainChance > 80) return "Hujan Lebat";
    if (rainChance > 50) return "Hujan Ringan";
    if (humidity > 80 && temp < 26) return "Berawan dan Lembab";
    if (temp >= 30 && rainChance < 20) return "Panas Terik";
    if (temp <= 25 && rainChance < 10) return "Cerah";
    return "Berawan";
  }

  // Mendapatkan path ikon berdasarkan kondisi cuaca
  static String getIconAsset(dynamic condition, bool isDark) {
    debugPrint("Condition: $condition — isDark: $isDark");

    final base = "assets/icons/";
    final map = {
      "clear": "clear",
      "cerah": "clear",
      "clouds": "cloudy",
      "berawan": "cloudy",
      "berawan dan lembab": "cloudy",
      "rain": "rainy",
      "hujan ringan": "rainy",
      "hujan lebat": "storm",
      "drizzle": "drizzle",
      "thunderstorm": "storm",
      "storm": "storm",
      "snow": "snow",
      "mist": "mist",
      "fog": "fog",
      "haze": "haze",
      "panas terik": "clear",
    };

    final key = (condition is String) ? condition.toLowerCase() : "clear";
    final icon = map[key] ?? "cloudy";
    return "$base${isDark ? 'dark' : 'light'}/$icon.png";
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isLight;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(isLight ? 0.1 : 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }
}

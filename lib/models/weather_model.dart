// weather_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class WeatherModel {
  // Lokasi saat ini
  static final ValueNotifier<Map<String, dynamic>> weatherData =
      ValueNotifier<Map<String, dynamic>>({});
  static final ValueNotifier<bool> isLoading = ValueNotifier(true);

  // Favorite (per kota, dipakai untuk preview)
  static final ValueNotifier<List<Map<String, dynamic>>> favoriteWeatherList =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  static final ValueNotifier<bool> isFavoriteLoading = ValueNotifier(false);

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
      final rawResult = await WeatherService().getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      weatherData.value = Map<String, dynamic>.from(rawResult);
    } catch (e) {
      debugPrint('Gagal memuat data cuaca: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Untuk kota favorit
  static Future<void> loadAllFavoriteWeatherData() async {
    final favorites = FavoriteService.getFavorites().take(3).toList();
    List<Map<String, dynamic>> weatherList = [];

    for (final city in favorites) {
      final fullName = city['name'];
      if (fullName != null) {
        try {
          final data = await WeatherService.getWeatherByCityFull(fullName);
          if (data != null && data['weather'] != null) {
            final rawWeather = data['weather'];
            final parsedCurrent = rawWeather['cuaca_saat_ini'];
            final forecast =
                [
                  rawWeather['kemarin'],
                  rawWeather['hari_ini'],
                  rawWeather['besok'],
                  rawWeather['lusa'],
                  rawWeather['hari_ke_3'],
                ].whereType<Map>().toList();

            weatherList.add({
              "current": parsedCurrent, // <- ini untuk weather
              "forecast": forecast,
              "city": fullName,
            });
          }
        } catch (e) {
          debugPrint("Gagal ambil cuaca untuk: $fullName => $e");
        }
      }
    }

    favoriteWeatherList.value = weatherList;
  }

  // Deskripsi kondisi cuaca berdasarkan nilai suhu, kelembapan, dan peluang hujan
  static String getWeatherDescription(Map<String, dynamic> weather) {
    final weatherDetailRaw = weather['weather'];
    final weatherDetail =
        (weatherDetailRaw is Map)
            ? Map<String, dynamic>.from(weatherDetailRaw)
            : <String, dynamic>{};
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

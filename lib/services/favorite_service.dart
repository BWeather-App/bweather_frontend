import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_cuaca/services/weather_service.dart';

class FavoriteService {
  static late Box _box;

  // static final Box _box = Hive.box('weatherBox');
  static Future<void> init() async {
    if (!Hive.isBoxOpen('weatherBox')) {
      _box = await Hive.openBox('weatherBox');
    } else {
      _box = Hive.box('weatherBox');
    }
  }

  /// Ambil daftar kota favorit dari Hive
  static List<Map<String, String>> getFavorites() {
    final raw = _box.get('favorites', defaultValue: []);
    return List<Map<String, String>>.from(
      (raw as List).map((e) => Map<String, String>.from(e)),
    );
  }

  /// Tambahkan kota ke favorit
  static Future<void> addFavorite(String city, String full) async {
    final favorites = getFavorites();
    final exists = favorites.any((item) => item['full'] == full);
    if (!exists) {
      favorites.add({'name': city, 'full': full});
      await _box.put('favorites', favorites);
    }
  }

  /// Hapus kota dari favorit
  static Future<void> removeFavorite(String fullName) async {
    final favorites =
        getFavorites()..removeWhere((item) => item['full'] == fullName);
    await _box.put('favorites', favorites);
  }

  /// Ambil data cuaca dari max 3 kota favorit
  static Future<List<Map<String, dynamic>>> getFavoriteWeatherData() async {
    final favorites = getFavorites().take(3).toList();
    List<Map<String, dynamic>> weatherList = [];

    for (final city in favorites) {
      final fullName = city['full'];
      if (fullName != null) {
        try {
          final data = await WeatherService.getWeatherByCityFull(fullName);
          if (data != null) weatherList.add(data);
        } catch (_) {
          // optionally handle/log error
        }
      }
    }
    return weatherList;
  }

  static Future<List<Map<String, dynamic>>> loadFavoriteWeather() async {
    final box = Hive.box('weatherBox');
    final List<dynamic> favorites = box.get('favorites', defaultValue: []);
    List<Map<String, dynamic>> result = [];

    for (var fav in favorites) {
      if (fav is Map && fav.containsKey('full')) {
        try {
          final fullName = fav['full'];
          final weatherData = await WeatherService.getWeatherByCityFull(
            fullName,
          );

          if (weatherData != null) {
            result.add(weatherData);
          }
        } catch (e) {
          debugPrint('Gagal ambil cuaca untuk $fav: $e');
        }
      }
    }

    return result;
  }

  static bool isFavorite(String fullName) {
    final favorites = getFavorites();
    return favorites.any((item) => item['full'] == fullName);
  }
}

// Lama Refactor v1
// class FavoriteService {
  // static late Box _box;

//   /// Inisialisasi service, panggil di main() sebelum runApp()
  // static Future<void> init() async {
  //   if (!Hive.isBoxOpen('weatherBox')) {
  //     _box = await Hive.openBox('weatherBox');
  //   } else {
  //     _box = Hive.box('weatherBox');
  //   }
  // }

//   static Future<void> addFavorite(String city, String fullName) async {
//     final favorites = getFavorites();
//     final exists = favorites.any((item) => item['full'] == fullName);
//     if (!exists) {
//       favorites.add({'name': city, 'full': fullName});
//       await _box.put('favorites', favorites);
//     }
//   }

//   static Future<void> removeFavorite(String fullName) async {
//     final favorites = getFavorites();
//     favorites.removeWhere((item) => item['full'] == fullName);
//     await _box.put('favorites', favorites);
//   }

//   static List<Map<String, String>> getFavorites() {
//     final saved = _box.get('favorites', defaultValue: []);
//     return List<Map<String, String>>.from(
//       (saved as List).map((e) => Map<String, String>.from(e)),
//     );
//   }

  // static bool isFavorite(String fullName) {
  //   final favorites = getFavorites();
  //   return favorites.any((item) => item['full'] == fullName);
  // }

  // static Future<void> clearFavorites() async {
  //   await _box.put('favorites', []);
  // }
// }

// Lama original
// class FavoriteService {
//   static const String _boxName = 'weatherBox';
//   static const String _favoritesKey = 'favorites';

//   final Box _box = Hive.box(_boxName);

//   List<Map<String, String>> getFavorites() {
//     final saved = _box.get(_favoritesKey, defaultValue: []);
//     return List<Map<String, String>>.from(
//       (saved as List).map((e) => Map<String, String>.from(e)),
//     );
//   }

//   void addFavorite(String city, String region) {
//     final favorites = getFavorites();
//     final exists = favorites.any((item) => item['full'] == region);
//     if (!exists) {
//       favorites.add({'name': city, 'full': region});
//       _box.put(_favoritesKey, favorites);
//     }
//   }

//   void removeFavorite(String region) {
//     final favorites = getFavorites();
//     favorites.removeWhere((item) => item['full'] == region);
//     _box.put(_favoritesKey, favorites);
//   }

//   bool isFavorite(String region) {
//     return getFavorites().any((item) => item['full'] == region);
//   }

//   Future<List<Map<String, dynamic>>> loadFavoriteWeather() async {
//     final favorites = getFavorites();
//     final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

//     List<Map<String, dynamic>> result = [];
//     for (var city in favorites) {
//       final fullName = Uri.encodeComponent(city['full'] ?? city['name'] ?? '');
//       final url = Uri.parse('$baseUrl/api/search?query=$fullName');

//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final weatherData = jsonDecode(response.body);
//         result.add({'city': city, 'weather': weatherData});
//       }
//     }

//     return result;
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:flutter_cuaca/route.dart';

class FavoriteService {
  static late Box _box;

  static Future<void> init() async {
    if (!Hive.isBoxOpen('weatherBox')) {
      _box = await Hive.openBox('weatherBox');
    } else {
      _box = Hive.box('weatherBox');
    }
  }

  /// Ambil daftar kota favorit dari Hive
  static List<Map<String, dynamic>> getFavorites() {
    final raw = _box.get('favorites', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// Tambahkan kota ke favorit
  static Future<void> addFavorite(Map<String, dynamic> cityData) async {
    final favorites = getFavorites();
    final exists = favorites.any((item) => item['full'] == cityData['full']);
    if (!exists) {
      favorites.add(cityData);
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
      final lat = city['lat'];
      final lon = city['lon'];

      if (lat != null && lon != null) {
        try {
          final data = await WeatherService.getWeatherByLatLon(
            lat: double.parse(lat.toString()),
            lon: double.parse(lon.toString()),
          );

          if (data != null) {
            // Tambahkan informasi kota ke dalam data weather
            final enrichedData = Map<String, dynamic>.from(data);
            enrichedData['city_info'] = city; // Simpan info kota favorit
            weatherList.add(enrichedData);
          }
        } catch (e) {
          debugPrint("Gagal memuat cuaca favorit untuk: ${city['full']} — $e");
        }
      } else {
        debugPrint("Lat/Lon tidak tersedia untuk: ${city['full']}");
      }
    }

    return weatherList;
  }

  static Future<bool> isFavorite(String fullName) async {
    final favorites = getFavorites();
    return favorites.any((item) => item['full'] == fullName);
  }
}
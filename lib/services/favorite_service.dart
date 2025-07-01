// favorite_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FavoriteService {
  static const String _boxName = 'weatherBox';
  static const String _favoritesKey = 'favorites';
  late Box _box;

  FavoriteService() {
    _box = Hive.box(_boxName);
  }

  List<Map<String, String>> getFavorites() {
    final saved = _box.get(_favoritesKey, defaultValue: []);
    return List<Map<String, String>>.from(
      (saved as List).map((e) => Map<String, String>.from(e)),
    );
  }

  void addFavorite(String city, String region) {
    final favorites = getFavorites();
    final exists = favorites.any((item) => item['full'] == region);
    if (!exists) {
      favorites.add({'name': city, 'full': region});
      _box.put(_favoritesKey, favorites);
    }
  }

  void removeFavorite(String region) {
    final favorites = getFavorites();
    favorites.removeWhere((item) => item['full'] == region);
    _box.put(_favoritesKey, favorites);
  }

  bool isFavorite(String region) {
    return getFavorites().any((item) => item['full'] == region);
  }

  Future<List<Map<String, dynamic>>> loadFavoriteWeather() async {
    final favorites = getFavorites();
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

    List<Map<String, dynamic>> result = [];
    for (var city in favorites) {
      final fullName = Uri.encodeComponent(city['full'] ?? city['name'] ?? '');
      final url = Uri.parse('$baseUrl/api/search?query=$fullName');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final weatherData = jsonDecode(response.body);
        result.add({'city': city, 'weather': weatherData});
      }
    }

    return result;
  }
}

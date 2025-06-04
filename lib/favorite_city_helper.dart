import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCityHelper {
  static const String key = 'favorite_cities';

  static Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> addFavoriteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList(key) ?? [];
    if (!cities.contains(city)) {
      cities.add(city);
      await prefs.setStringList(key, cities);
    }
  }

  static Future<void> removeFavoriteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList(key) ?? [];
    cities.remove(city);
    await prefs.setStringList(key, cities);
  }
}
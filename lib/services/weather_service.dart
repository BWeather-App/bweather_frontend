import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  /// Memanggil data cuaca berdasarkan satu nama kota (simple)
  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse('$_baseUrl/api/search?query=$city');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari kota');
    }

    final data = Map<String, dynamic>.from(json.decode(response.body));

    if (data['forecast'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    return data;
  }

  /// Memanggil data cuaca berdasarkan latitude dan longitude
  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse('$_baseUrl/api/weather?lat=$lat&lon=$lon');
    print('Memanggil $url');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari lokasi');
    }

    final data = Map<String, dynamic>.from(json.decode(response.body));

    if (data['weather'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    return Map<String, dynamic>.from(data);
  }

  /// Mengambil saran lokasi berdasarkan query
  Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    final url = Uri.parse('$_baseUrl/api/suggestions?query=$query');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil saran lokasi');
    }

    final List<dynamic> data = json.decode(response.body);
    return data
        .map(
          (item) => {
            'name': item['name'],
            'full': item['full'],
            'lat': item['lat'].toString(),
            'lon': item['lon'].toString(),
          },
        )
        .toList();
  }

  static Future<Map<String, dynamic>?> getWeatherByCityFull(
    String fullName,
  ) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
      final encoded = Uri.encodeComponent(fullName);
      final response = await http.get(
        Uri.parse('$baseUrl/api/search?query=$encoded'),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }
    } catch (_) {}

    return null;
  }

  static Future<Map<String, dynamic>?> getWeatherByLatLon({
    required double lat,
    required double lon,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
      final url = Uri.parse('$baseUrl/api/weather?lat=$lat&lon=$lon');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        return Map<String, dynamic>.from(raw); // <== INI PENTING
      }
    } catch (e) {
      print("getWeatherByLatLon error: $e");
    }

    return null;
  }
}

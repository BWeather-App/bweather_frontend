import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl =
      'https://myporto.site/bweather-backend/public/index.php';

  // 🔍 Ambil data cuaca berdasarkan kota
  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse('$_baseUrl?endpoint=search&query=$city');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari kota');
    }

    final data = json.decode(response.body);

    if (data['weather'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    return data; // Sudah terstruktur: { location: ..., weather: { ... } }
  }

  Future<List<Map<String, String>>> searchCities(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?endpoint=search&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Pastikan lokasi ada
      if (data['location'] != null && data['location'] is Map) {
        final location = data['location'];

        return [
          {
            'city': location['name']?.split(',')[0] ?? 'Unknown',
            'region': location['name'] ?? 'Unknown Region',
            'country': '', // bisa parsing dari location kalau ada field country
          },
        ];
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load city data');
    }
  }

  // 📍 Ambil data cuaca berdasarkan lokasi
  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '$_baseUrl?endpoint=weather&latitude=$lat&longitude=$lon',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari lokasi');
    }

    final data = json.decode(response.body);

    if (data['weather'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    return data;
  }
}

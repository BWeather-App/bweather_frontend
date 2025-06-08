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

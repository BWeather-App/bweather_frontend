import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = 'http://192.168.5.6:8000';

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse('$_baseUrl/api/search?query=$city');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari kota');
    }

    final data = json.decode(response.body);

    if (data['forecast'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    return data;
  }

  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse('$_baseUrl/api/weather?lat=$lat&lon=$lon');
    print('Memanggil $_baseUrl/api/weather?lat=$lat&lon=$lon');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari lokasi');
    }

    final data = json.decode(response.body);

    // Penyesuaian sesuai response dari backend
    if (data['weather'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    return data;
  }

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
}

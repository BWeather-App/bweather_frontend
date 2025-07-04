import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notification_service.dart';

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
    debugPrint('Memanggil $url');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data dari lokasi');
    }

    final data = Map<String, dynamic>.from(json.decode(response.body));

    if (data['weather'] == null || data['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }
    final weather = data['weather'];
    final lokasi = data['location'];
    final double suhu = weather['cuaca_saat_ini']['suhu']?.toDouble() ?? 0;
    final double angin =
        weather['cuaca_saat_ini']['kecepatan_angin']?.toDouble() ?? 0;
    final double tekanan =
        weather['cuaca_saat_ini']['tekanan_udara']?.toDouble() ?? 1000;
    final int peluangHujan = weather['cuaca_saat_ini']['peluang_hujan'] ?? 0;
    final int uv = weather['cuaca_saat_ini']['indeks_uv'] ?? 0;

    bool isSuhuEkstrem = suhu < 10 || suhu > 15;
    bool isAnginEkstrem = angin > 11;
    bool isTekananEkstrem = tekanan < 900;
    bool isHujanEkstrem = peluangHujan > 80;
    bool isUVEkstrem = uv >= 8;

    bool isEkstrem =
        isSuhuEkstrem ||
        isAnginEkstrem ||
        isTekananEkstrem ||
        isHujanEkstrem ||
        isUVEkstrem;

    if (isEkstrem) {
      List<String> detail = [];

      if (isSuhuEkstrem) {
        detail.add('Suhu: $suhu°C');
      }
      if (isAnginEkstrem) {
        detail.add('Angin: ${angin.toStringAsFixed(1)} m/s');
      }
      if (isTekananEkstrem) {
        detail.add('Tekanan udara: ${tekanan.toStringAsFixed(1)} hPa');
      }
      if (isHujanEkstrem) {
        detail.add('Peluang hujan: ${peluangHujan.toStringAsFixed(0)}%');
      }
      if (isUVEkstrem) {
        detail.add('Indeks UV: $uv');
      }

      String pesan = 'Cuaca ekstrem terdeteksi!\n' + detail.join('\n');

      await NotificationService.showCuacaEkstrem(
        lokasi['city'] ?? 'Lokasi tidak diketahui',
        pesan,
      );
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

  static Future<Map<String, dynamic>?> getWeatherByCityFull(String name) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
      final encoded = Uri.encodeComponent(name);
      final response = await http.get(
        Uri.parse('$baseUrl/api/search?query=$encoded'),
      );
      debugPrint("🔍 Request URL: $baseUrl/api/search?query=$encoded");

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

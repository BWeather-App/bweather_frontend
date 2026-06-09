import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherRepository {
  WeatherRepository._();
  static final WeatherRepository instance = WeatherRepository._();

  // ─────────────────────────────────────────────
  // Base URL — ambil dari .env, tanpa fallback IP lokal
  // ─────────────────────────────────────────────

  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? '';
    if (url.isEmpty) {
      throw Exception(
        'API_BASE_URL tidak ditemukan di .env. '
        'Pastikan file .env sudah dikonfigurasi.',
      );
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // ─────────────────────────────────────────────
  // Get Weather by GPS Coordinate
  //
  // Dipakai oleh:
  //   - WeatherModel.loadWeatherData()
  //   - WeatherDetailSheet (sebelumnya langsung http call di widget)
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getWeatherByLocation({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/weather?lat=$lat&lon=$lon');

    try {
      final response = await http.get(uri);
      return _handleResponse(response, expectedKeys: ['weather', 'location']);
    } on Exception {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // Get Weather by City Name (full data)
  //
  // Dipakai oleh:
  //   - WeatherModel.loadAllFavoriteWeatherData()
  //   - SearchCityPage
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    final encoded = Uri.encodeComponent(cityName);
    final uri = Uri.parse('$_baseUrl/api/search?query=$encoded');

    try {
      final response = await http.get(uri);
      return _handleResponse(response, expectedKeys: ['weather', 'location']);
    } on Exception {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // Get City Suggestions (autocomplete search)
  //
  // Dipakai oleh: SearchCityPage
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse('$_baseUrl/api/suggestions?query=$encoded');

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil saran lokasi (${response.statusCode})',
        );
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
    } on Exception {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // Private: Handle HTTP Response
  //
  // Sentralisasi error handling agar semua method
  // dapat response yang konsisten.
  // ─────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(
    http.Response response, {
    List<String> expectedKeys = const [],
  }) {
    if (response.statusCode != 200) {
      throw WeatherApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      json.decode(response.body),
    );

    // Validasi key yang wajib ada
    for (final key in expectedKeys) {
      if (data[key] == null) {
        throw WeatherApiException(
          statusCode: response.statusCode,
          message: 'Response tidak lengkap: key "$key" tidak ditemukan',
        );
      }
    }

    return data;
  }

  String _parseErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      return decoded['error'] ?? decoded['message'] ?? 'Terjadi kesalahan';
    } catch (_) {
      return 'Terjadi kesalahan tidak diketahui';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Exception
//
// Memisahkan error API dari error umum Dart (SocketException, dll)
// supaya UI bisa menampilkan pesan yang tepat.
// ─────────────────────────────────────────────────────────────────────────────

class WeatherApiException implements Exception {
  final int statusCode;
  final String message;

  const WeatherApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'WeatherApiException($statusCode): $message';

  /// Pesan ramah untuk ditampilkan ke user
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid';
      case 404:
        return 'Data tidak ditemukan';
      case 429:
        return 'Terlalu banyak permintaan, coba lagi nanti';
      case 500:
        return 'Server sedang bermasalah, coba lagi nanti';
      default:
        return message;
    }
  }
}

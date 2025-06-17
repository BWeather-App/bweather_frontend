import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification_service.dart';

Future<bool> cekKoneksiInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }

  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

class WeatherService {
  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
  final String _baseUrl =
      'https://myporto.site';

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

    return data; // Sudah terstruktur: { location: ..., weather: { ... } 
  }

  // 📍 Ambil data cuaca berdasarkan lokasi
  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    String key = 'lat:${lat.toStringAsFixed(4)},lon:${lon.toStringAsFixed(4)}';
    final cekKoneksi = await cekKoneksiInternet();
    final box = Hive.box('weatherBox');

    if (cekKoneksi) {
      final url = Uri.parse(
        '$_baseUrl/api/weather?lat=$lat&lon=$lon',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data dari lokasi');
      }

      final data = json.decode(response.body);

      if (data['weather'] == null || data['location'] == null) {
        throw Exception('Data cuaca tidak lengkap');
      }

      // Simpan data ke Hive
      await box.put(key, data);
      final weather = data['weather']; // sesuai struktur respons kamu
      final lokasi = data['location'];

      // Cek apakah memenuhi salah satu kriteria cuaca ekstrem
      final double suhu = weather['cuaca_saat_ini']['suhu']?.toDouble() ?? 0;
      final double angin = weather['cuaca_saat_ini']['kecepatan_angin']?.toDouble() ?? 0;
      final double tekanan = weather['cuaca_saat_ini']['tekanan_udara']?.toDouble() ?? 1000;
      final int peluangHujan = weather['cuaca_saat_ini']['peluang_hujan'] ?? 0;
      final int uv = weather['cuaca_saat_ini']['indeks_uv'] ?? 0;

      bool isEkstrem = suhu < 10 || suhu > 35 || 
                      angin > 11 || 
                      tekanan < 900 || 
                      peluangHujan > 80 || 
                      uv >= 8;

      if (isEkstrem) {
        await NotificationService.showCuacaEkstrem(
          lokasi['city'] ?? 'Lokasi tidak diketahui',
          'Cuaca ekstrem terdeteksi!\nSuhu: $suhu°C\nAngin: ${angin.toStringAsFixed(1)} m/s\nUV: $uv',
        );
      }
      return data;
    } else {
      // MODE OFFLINE: ambil dari Hive
      if (!box.containsKey(key)) {
        throw Exception('Data cuaca tidak ditemukan di cache');
      }

      final cachedData = box.get(key);

      if (cachedData is! Map<String, dynamic>) {
        // Antisipasi jika data rusak
        throw Exception('Data cuaca di cache tidak valid');
      }

      return Map<String, dynamic>.from(cachedData);
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_cuaca/repositories/weather_repository.dart';
import 'package:flutter_cuaca/services/notification_service.dart';

export 'package:flutter_cuaca/repositories/weather_repository.dart'
    show WeatherApiException;

class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  final WeatherRepository _repository = WeatherRepository.instance;

  // ─────────────────────────────────────────────
  // Get Weather by GPS — dengan cek cuaca ekstrem
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getWeatherByLocation({
    required double lat,
    required double lon,
  }) async {
    final data = await _repository.getWeatherByLocation(lat: lat, lon: lon);

    // Business logic: cek & kirim notifikasi cuaca ekstrem
    // Dipisah dari Repository karena ini adalah keputusan bisnis,
    // bukan bagian dari pengambilan data
    _checkAndNotifyExtremeWeather(data);

    return data;
  }

  // ─────────────────────────────────────────────
  // Get Weather by City Name
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    final data = await _repository.getWeatherByCity(cityName);
    _checkAndNotifyExtremeWeather(data);
    return data;
  }

  // ─────────────────────────────────────────────
  // Get City Suggestions (autocomplete)
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    return _repository.getSuggestions(query);
  }

  // ─────────────────────────────────────────────
  // Private: Cek & Kirim Notifikasi Cuaca Ekstrem
  //
  // Dipisah jadi method sendiri supaya:
  //   1. Mudah di-test secara terpisah
  //   2. Tidak blocking — dipanggil tanpa await
  // ─────────────────────────────────────────────

  void _checkAndNotifyExtremeWeather(Map<String, dynamic> data) {
    try {
      final weather = data['weather'];
      final lokasi = data['location'];
      if (weather == null || lokasi == null) return;

      final current = weather['cuaca_saat_ini'];
      if (current == null) return;

      final double suhu = (current['suhu'] as num?)?.toDouble() ?? 0.0;
      final double angin =
          (current['kecepatan_angin'] as num?)?.toDouble() ?? 0.0;
      final double tekanan =
          (current['tekanan_udara'] as num?)?.toDouble() ?? 1000.0;
      final int peluangHujan = (current['peluang_hujan'] as num?)?.toInt() ?? 0;
      final int uv = (current['indeks_uv'] as num?)?.toInt() ?? 0;

      final List<String> detail = [];
      if (suhu < 10 || suhu > 35) detail.add('Suhu: $suhu°C');
      if (angin > 25) detail.add('Angin: ${angin.toStringAsFixed(1)} m/s');
      if (tekanan < 900)
        detail.add('Tekanan udara: ${tekanan.toStringAsFixed(1)} hPa');
      if (peluangHujan > 80) detail.add('Peluang hujan: $peluangHujan%');
      if (uv >= 8) detail.add('Indeks UV: $uv');

      if (detail.isEmpty) return;

      final pesan = 'Cuaca ekstrem terdeteksi!\n${detail.join('\n')}';
      final namaKota = lokasi['city'] ?? 'Lokasi tidak diketahui';

      // Fire and forget — tidak perlu await
      NotificationService.showCuacaEkstrem(namaKota, pesan);
    } catch (e) {
      // Jangan crash app hanya karena notifikasi gagal
      debugPrint('Gagal cek cuaca ekstrem: $e');
    }
  }
}

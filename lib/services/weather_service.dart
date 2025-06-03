import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final String _apiUrl =
      'https://api.kankmaz.biz.id/tools/weather/bweather?lat={lat}&lon={lon}';

  Future<Map<String, dynamic>> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final url = _apiUrl.replaceAll('{lat}', '$lat').replaceAll('{lon}', '$lon');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data cuaca');
    }

    final data = json.decode(response.body);
    final result = data['result'];

    if (result == null ||
        result['weather'] == null ||
        result['location'] == null) {
      throw Exception('Data cuaca tidak lengkap');
    }

    final current = result['weather'];
    final location = result['location'];

    // Dummy data untuk kemarin
    final yesterday = {
      'time':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'temp': ((current['temperature'] ?? 0.0) as num).toDouble() - 1,
      'main': current['main'] ?? 'Cerah',
      'description': 'Cuaca kemarin',
    };

    // Ambil forecast per menit, dan filter jadi 1 item per hari
    final List<dynamic> minutelyForecast =
        result['forecast']?['minutely'] ?? [];
    final Map<String, Map<String, dynamic>> dailyMap = {};

    for (final item in minutelyForecast) {
      final timeStr = item['time'];
      if (timeStr == null) continue;

      final dateTime = DateTime.tryParse(timeStr);
      if (dateTime == null) continue;

      final dateKey = DateFormat('yyyy-MM-dd').format(dateTime);

      // Lewati hari ini
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (dateKey == todayKey) continue;

      // Simpan hanya item pertama dari tanggal yang belum ada
      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = item;
      }
    }

    // Sortir dan ambil 3 hari ke depan
    final sortedKeys = dailyMap.keys.toList()..sort();
    final List<Map<String, dynamic>> dailyList = [];

    for (int i = 0; i < 3 && i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final item = dailyMap[key]!;

      dailyList.add({
        'time': item['time'] ?? '',
        'temp': (item['temperature'] ?? 0.0) as num,
        'main': item['weather'] ?? 'Cerah',
        'description': 'Perkiraan cuaca tanggal $key',
      });
    }

    return {
      'location': location,
      'current': {
        'time': current['time'] ?? '',
        'temp': (current['temperature'] ?? 0.0) as num,
        'main': current['main'] ?? 'Cerah',
        'description': current['description'] ?? 'Cuaca saat ini',
      },
      'yesterday': yesterday,
      'forecast': dailyList,
    };
  }
}

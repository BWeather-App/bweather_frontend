// weather_detail_sheet.dart
import 'package:flutter/material.dart';
// import 'package:flutter_cuaca/route.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class WeatherDetailSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> forecastList;
  final Map<String, dynamic> current;
  final bool isLight;
  final Color cardColor;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(int) formatTime; // Ubah dari String? ke int
  final String Function(dynamic, bool) getIconAsset;
  final double lat;
  final double lon;

  const WeatherDetailSheet({
    Key? key,
    required this.scrollController,
    required this.forecastList,
    required this.current,
    required this.isLight,
    required this.cardColor,
    required this.getWeatherDescription,
    required this.formatTime,
    required this.getIconAsset,
    required this.lat,
    required this.lon,
  }) : super(key: key);

  @override
  State<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class _WeatherDetailSheetState extends State<WeatherDetailSheet> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() => isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lon = position.longitude;

      final url = 'https://myporto.site/api/weather?lat=$lat&lon=$lon';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load weather data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '--:--';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
      return days[dateTime.weekday % 7];
    } catch (e) {
      return '';
    }
  }

  String _getWeatherIcon(double? temp, double? humidity, double? rainChance) {
    if (temp == null) return '☁️';
    if (rainChance != null && rainChance > 70) return '⛈️';
    if (rainChance != null && rainChance > 30) return '🌧️';
    if (temp > 30) return '☀️';
    if (temp < 20) return '❄️';
    return '⛅';
  }

  IconData _getWeatherIconData(
    double? temp,
    double? humidity,
    double? rainChance,
  ) {
    if (temp == null) return Icons.wb_cloudy;
    if (rainChance != null && rainChance > 70) return Icons.thunderstorm;
    if (rainChance != null && rainChance > 30) return Icons.grain;
    if (temp > 30) return Icons.wb_sunny;
    if (temp < 20) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        error = null;
                      });
                      _fetchWeatherData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ListView(
            controller: widget.scrollController,
            children: [
              const Center(
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildWeeklyForecast(),
              const SizedBox(height: 24),
              _buildHourlyForecast(),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildUVIndex(),
                  _buildTemperature(),
                  _buildSunPath(),
                  _buildHumidity(),
                  _buildWindDirection(),
                  _buildChanceOfRain(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    if (weatherData == null) return Container();

    final weather = weatherData!['weather'];
    final forecasts = [
      weather['kemarin'],
      weather['hari_ini'],
      weather['besok'],
      weather['lusa'],
      weather['hari_ke_3'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final dayData = forecasts[index] as List?;

            // Default jika kosong
            if (dayData == null || dayData.isEmpty) {
              return Column(
                children: [
                  Text(
                    '--',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.help_outline,
                    color: Colors.white54,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '--°',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }

            final midDayData = dayData[dayData.length ~/ 2];
            final waktuStr = midDayData?['waktu'] ?? '';
            final parsedDate = DateTime.tryParse(waktuStr) ?? DateTime.now();

            final weekday =
                DateFormat.E('id_ID').format(parsedDate).toUpperCase();
            final isToday = parsedDate.day == DateTime.now().day;

            final temp = midDayData?['suhu']?.round() ?? 0;
            final humidity = midDayData?['kelembapan'] ?? 0;
            final rainChance = midDayData?['peluang_hujan'] ?? 0;

            return Column(
              children: [
                Text(
                  weekday,
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  _getWeatherIconData(
                    temp.toDouble(),
                    humidity.toDouble(),
                    rainChance.toDouble(),
                  ),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  '$temp°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    if (weatherData == null) return Container();

    final todayData = weatherData!['weather']['hari_ini'] as List? ?? [];
    if (todayData.isEmpty) return Container();

    // Take next 6 hours from current time
    final now = DateTime.now();
    final next6Hours =
        todayData
            .where((hourData) {
              final timeStr = hourData['waktu'] as String?;
              if (timeStr == null) return false;
              try {
                final time = DateTime.parse(timeStr);
                return time.isAfter(now) &&
                    time.isBefore(now.add(const Duration(hours: 6)));
              } catch (e) {
                return false;
              }
            })
            .take(6)
            .toList();

    if (next6Hours.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white54, size: 13),
            const SizedBox(width: 4),
            const Text(
              'Ramalan 6 Jam',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < next6Hours.length) {
                        return Text(
                          _formatTime(next6Hours[index]['waktu']),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      next6Hours.asMap().entries.map((entry) {
                        final temp = entry.value['suhu']?.toDouble() ?? 25.0;
                        return FlSpot(entry.key.toDouble(), temp);
                      }).toList(),
                  isCurved: true,
                  color: Colors.white,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              minY:
                  next6Hours
                      .map((e) => (e['suhu']?.toDouble() ?? 25.0))
                      .reduce(
                        (value, element) => value < element ? value : element,
                      ) -
                  2,
              maxY:
                  next6Hours
                      .map((e) => (e['suhu']?.toDouble() ?? 25.0))
                      .reduce(
                        (value, element) => value > element ? value : element,
                      ) +
                  2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUVIndex() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final uvIndex = current?['indeks_uv']?.toDouble() ?? 0.0;

    String getUVDescription(double uv) {
      if (uv < 3) return 'Rendah';
      if (uv < 6) return 'Sedang';
      if (uv < 8) return 'Tinggi';
      if (uv < 11) return 'Sangat Tinggi';
      return 'Ekstrem';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 4),
              const Text(
                'UV Index',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            uvIndex.round().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            getUVDescription(uvIndex),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            child: LinearProgressIndicator(
              value: (uvIndex / 11).clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                uvIndex < 3
                    ? Colors.green
                    : uvIndex < 6
                    ? Colors.yellow
                    : uvIndex < 8
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            uvIndex > 3
                ? 'Gunakan tabir surya saat keluar.'
                : 'Aman untuk beraktivitas di luar.',
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperature() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final feelsLike = current?['terasa_seperti']?.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.thermostat_outlined,
                color: Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 4),
              const Text(
                'Terasa Seperti',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${feelsLike}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suhu yang terasa saat keluar,\ndengan faktor angin.',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSunPath() {
    final todayData = weatherData?['weather']['hari_ini'] as List? ?? [];
    String sunrise = '--:--';
    String sunset = '--:--';

    if (todayData.isNotEmpty) {
      sunrise = _formatTime(todayData.first['matahari_terbit']);
      sunset = _formatTime(todayData.first['matahari_terbenam']);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.brightness_6_outlined,
                color: Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 4),
              const Text(
                'Jalur Matahari',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              painter: SunPathPainter(),
              size: const Size(double.infinity, 60),
            ),
          ),
          Text(
            'Terbit: $sunrise  Terbenam: $sunset',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidity() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final humidity = current?['kelembapan']?.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 4),
              const Text(
                'Kelembaban',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$humidity%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            humidity > 70
                ? 'Kelembaban tinggi membuat\nterasa lebih panas.'
                : 'Kelembaban dalam kondisi\nnormal.',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildWindDirection() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final windDirection = current?['arah_angin']?.toDouble() ?? 0.0;
    final windSpeed = current?['kecepatan_angin']?.toDouble() ?? 0.0;

    String getWindDirectionText(double degrees) {
      if (degrees >= 337.5 || degrees < 22.5) return 'U';
      if (degrees >= 22.5 && degrees < 67.5) return 'TL';
      if (degrees >= 67.5 && degrees < 112.5) return 'T';
      if (degrees >= 112.5 && degrees < 157.5) return 'TG';
      if (degrees >= 157.5 && degrees < 202.5) return 'S';
      if (degrees >= 202.5 && degrees < 247.5) return 'BD';
      if (degrees >= 247.5 && degrees < 292.5) return 'B';
      if (degrees >= 292.5 && degrees < 337.5) return 'BL';
      return 'U';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Colors.white54, size: 13),
              const SizedBox(width: 4),
              const Text(
                'Arah Angin',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: CompassPainter(windDirection),
                child: Center(
                  child: Text(
                    getWindDirectionText(windDirection),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              '${windSpeed.round()} km/h',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChanceOfRain() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final rainChance = current?['peluang_hujan']?.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.umbrella_outlined,
                color: Colors.white54,
                size: 12,
              ),
              const SizedBox(width: 4),
              const Text(
                'Kemungkinan Hujan',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$rainChance%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rainChance > 70
                ? 'Kemungkinan besar akan hujan.\nBawa payung.'
                : rainChance > 30
                ? 'Kemungkinan hujan ringan.'
                : 'Kemungkinan kecil hujan.',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Custom Painters
class SunPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);

    // Sun position (current time simulation)
    final sunPaint =
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.3), 6, sunPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CompassPainter extends CustomPainter {
  final double windDirection;

  CompassPainter([this.windDirection = 0]);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw compass circle
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw wind direction arrow
    final arrowPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final arrowLength = radius * 0.7;
    final arrowAngle = (windDirection * math.pi / 180) - (math.pi / 2);

    final arrowEnd = Offset(
      center.dx + arrowLength * math.cos(arrowAngle),
      center.dy + arrowLength * math.sin(arrowAngle),
    );

    canvas.drawLine(center, arrowEnd, arrowPaint);

    // Draw arrowhead
    final headLength = 8.0;
    final headAngle = 0.5;

    final leftHead = Offset(
      arrowEnd.dx - headLength * math.cos(arrowAngle - headAngle),
      arrowEnd.dy - headLength * math.sin(arrowAngle - headAngle),
    );

    final rightHead = Offset(
      arrowEnd.dx - headLength * math.cos(arrowAngle + headAngle),
      arrowEnd.dy - headLength * math.sin(arrowAngle + headAngle),
    );

    canvas.drawLine(arrowEnd, leftHead, arrowPaint);
    canvas.drawLine(arrowEnd, rightHead, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// weather_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherDetailSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> forecastList;
  final Map<String, dynamic> current;
  final bool isLight;
  final Color cardColor;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(int) formatTime;
  final String Function(dynamic, bool) getIconAsset;
  final double? lat;
  final double? lon;

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
    this.lat,
    this.lon,
  }) : super(key: key);

  @override
  State<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class WeatherWidgets extends StatelessWidget {
  final Map<String, dynamic>? weatherData;

  const WeatherWidgets({Key? key, this.weatherData}) : super(key: key);

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '--:--';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  Widget _buildUVIndex() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final uvIndex = current?['indeks_uv']?.toDouble() ?? 2.0;

    String getUVDescription(double uv) {
      if (uv < 3) return 'Rendah';
      if (uv < 6) return 'Sedang';
      if (uv < 8) return 'Tinggi';
      if (uv < 11) return 'Sangat Tinggi';
      return 'Ekstrem';
    }

    Color getUVColor(double uv) {
      if (uv < 3) return Colors.green;
      if (uv < 6) return Colors.yellow;
      if (uv < 8) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'UV Index',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            uvIndex.round().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            getUVDescription(uvIndex),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              widthFactor: (uvIndex / 11).clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: getUVColor(uvIndex),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperature() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final feelsLike = current?['terasa_seperti']?.round() ?? 26;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.thermostat_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Terasa Seperti',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${feelsLike}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suhu yang dirasakan\ndengan faktor angin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunPath() {
    final todayData = weatherData?['weather']['hari_ini'] as List? ?? [];
    String sunrise = '05:46';
    String sunset = '17:27';

    if (todayData.isNotEmpty) {
      sunrise = _formatTime(todayData.first['matahari_terbit']);
      sunset = _formatTime(todayData.first['matahari_terbenam']);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Jalur Matahari',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: CustomPaint(
              painter: SunPathPainter(sunrise: sunrise, sunset: sunset),
              size: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terbit: $sunrise  Terbenam: $sunset',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidity() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final humidity = current?['kelembapan']?.round() ?? 87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Kelembaban',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$humidity%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            humidity > 70
                ? 'Kelembaban tinggi,\nterasa lebih panas'
                : 'Kelembaban dalam\nkondisi normal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindDirection() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final windDirection = current?['arah_angin']?.toDouble() ?? 180.0;
    final windSpeed = current?['kecepatan_angin']?.toDouble() ?? 18.0;

    String getWindDirectionText(double degrees) {
      if (degrees >= 337.5 || degrees < 22.5) return 'U';
      if (degrees >= 22.5 && degrees < 67.5) return 'TL';
      if (degrees >= 67.5 && degrees < 112.5) return 'T';
      if (degrees >= 112.5 && degrees < 157.5) return 'TG';
      if (degrees >= 157.5 && degrees < 202.5) return 'S';
      if (degrees >= 202.5 && degrees < 247.5) return 'BD';
      if (degrees >= 247.5 && degrees < 292.5) return 'B';
      if (degrees >= 292.5 && degrees < 337.5) return 'BL';
      return 'S';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.air, color: Colors.white.withOpacity(0.6), size: 14),
              const SizedBox(width: 4),
              Text(
                'Arah Angin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: CompassPainter(windDirection),
                child: Center(
                  child: Text(
                    getWindDirectionText(windDirection),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${windSpeed.round()} km/h',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChanceOfRain() {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final rainChance = current?['peluang_hujan']?.round() ?? 74;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.umbrella_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Kemungkinan Hujan',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$rainChance%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rainChance > 70
                ? 'Kemungkinan besar\nhujan, bawa payung'
                : rainChance > 30
                ? 'Kemungkinan hujan\nringan'
                : 'Kemungkinan kecil\nhujan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk membuat grid layout 2 kolom seperti gambar 3
  Widget buildWeatherGrid() {
    return Column(
      children: [
        // Row 1: UV Index dan Terasa Seperti
        Row(
          children: [
            Expanded(child: _buildUVIndex()),
            const SizedBox(width: 12),
            Expanded(child: _buildTemperature()),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Jalur Matahari dan Kelembaban
        Row(
          children: [
            Expanded(child: _buildSunPath()),
            const SizedBox(width: 12),
            Expanded(child: _buildHumidity()),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Arah Angin dan Kemungkinan Hujan
        Row(
          children: [
            Expanded(child: _buildWindDirection()),
            const SizedBox(width: 12),
            Expanded(child: _buildChanceOfRain()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildWeatherGrid();
  }
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
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      double lat, lon;

      // Jika lat/lon sudah disediakan (dari kota favorit), gunakan itu
      if (widget.lat != null && widget.lon != null) {
        lat = widget.lat!;
        lon = widget.lon!;
      } else {
        // Jika tidak, gunakan lokasi saat ini
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lon = position.longitude;
      }

      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
      final url = '$baseUrl/api/weather?lat=$lat&lon=$lon';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        final data = Map<String, dynamic>.from(raw);

        if (!mounted) return;
        setState(() {
          weatherData = data;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          error = 'Failed to load weather data';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
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
    final weatherWidgets = WeatherWidgets(weatherData: weatherData);

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

              // Panggil method buildWeatherGrid() yang sudah dibuat
              weatherWidgets.buildWeatherGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    if (weatherData == null || weatherData!['weather'] == null)
      return Container();

    final weather = weatherData!['weather'] as Map<String, dynamic>;

    final forecasts = [
      weather['kemarin'] ?? [],
      weather['hari_ini'] ?? [],
      weather['besok'] ?? [],
      weather['lusa'] ?? [],
      weather['hari_ke_3'] ?? [],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final dayData = forecasts[index] as List?;

            if (dayData == null || dayData.isEmpty) {
              return Column(
                children: const [
                  Text(
                    '--',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(Icons.help_outline, color: Colors.white54, size: 24),
                  SizedBox(height: 8),
                  Text(
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

            final midDayData =
                dayData.isNotEmpty ? dayData[dayData.length ~/ 2] : null;

            final waktuStr = midDayData?['waktu'] ?? '';
            final parsedDate = DateTime.tryParse(waktuStr) ?? DateTime.now();

            final weekday =
                DateFormat.E('id_ID').format(parsedDate).toUpperCase();
            final isToday = parsedDate.day == DateTime.now().day;

            final temp = midDayData?['suhu']?.round() ?? 0;

            // Gunakan fungsi yang sudah ada
            final description = WeatherModel.getWeatherDescription({
              'weather': midDayData,
            });
            final iconPath = WeatherModel.getIconAsset(description, false);

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
                Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
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
}

// Custom Painters
class SunPathPainter extends CustomPainter {
  final String sunrise;
  final String sunset;

  SunPathPainter({required this.sunrise, required this.sunset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = Colors.orange.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    // Draw sun path arc
    final rect = Rect.fromLTWH(
      0,
      size.height / 3,
      size.width,
      size.height / 1.5,
    );
    canvas.drawArc(rect, math.pi, math.pi, false, paint);

    // Fill the arc
    canvas.drawArc(rect, math.pi, math.pi, false, fillPaint);

    // Draw current sun position
    final sunPaint =
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.3), 4, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompassPainter extends CustomPainter {
  final double windDirection;

  CompassPainter(this.windDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw compass circle
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw wind direction arrow
    final arrowPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final angle = (windDirection - 90) * math.pi / 180;
    final arrowEnd = Offset(
      center.dx + radius * 0.5 * math.cos(angle),
      center.dy + radius * 0.5 * math.sin(angle),
    );

    canvas.drawLine(center, arrowEnd, arrowPaint);

    // Draw arrow head
    final arrowHeadPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(arrowEnd, 3, arrowHeadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

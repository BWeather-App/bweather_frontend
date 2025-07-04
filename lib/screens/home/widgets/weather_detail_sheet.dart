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
    // Theme-based colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final blurBackgroundColor =
    //     isDark
    //         ? Colors.white.withOpacity(0.05)
    //         : Colors.black.withOpacity(0.05);
    final textColor = isDark ? Colors.white : Colors.black;
    // final hintColor = isDark ? Colors.white38 : Colors.black38;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final inputBoxColor =
        isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.05);
    // final cardColor =
    //     isDark
    //         ? Colors.white.withOpacity(0.05)
    //         : Colors.black.withOpacity(0.03);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    if (isLoading) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(child: CircularProgressIndicator(color: textColor)),
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
                  Icon(Icons.error, color: textColor, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: TextStyle(color: textColor),
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
              Center(
                child: Icon(Icons.keyboard_arrow_up, color: subtitleColor),
              ),
              const SizedBox(height: 16),
              _buildWeeklyForecast(textColor, iconColor, subtitleColor),
              const SizedBox(height: 24),
              _buildHourlyForecast(textColor, subtitleColor),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildUVIndex(
                    textColor,
                    subtitleColor,
                    inputBoxColor,
                    borderColor,
                  ),
                  _buildTemperature(
                    textColor,
                    subtitleColor,
                    inputBoxColor,
                    borderColor,
                  ),
                  _buildSunPath(
                    textColor,
                    subtitleColor,
                    inputBoxColor,
                    borderColor,
                  ),
                  _buildHumidity(
                    textColor,
                    subtitleColor,
                    inputBoxColor,
                    borderColor,
                  ),
                  _buildWindDirection(
                    textColor,
                    subtitleColor,
                    inputBoxColor,
                    borderColor,
                  ),
                  _buildChanceOfRain(
                    textColor,
                    subtitleColor,
                    inputBoxColor,
                    borderColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast(
    Color textColor,
    Color iconColor,
    Color subtitleColor,
  ) {
    if (weatherData == null || weatherData!['weather'] == null)
      return Container();

    final weather = weatherData!['weather'] as Map;
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
                children: [
                  Text(
                    '--',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.help_outline, color: iconColor, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    '--°',
                    style: TextStyle(
                      color: subtitleColor,
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
                    color: isToday ? textColor : subtitleColor,
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  color: iconColor, // 👈 pakai warna ikon
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  '$temp°',
                  style: TextStyle(
                    color: textColor,
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

  Widget _buildHourlyForecast(Color textColor, Color subtitleColor) {
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
            Icon(Icons.access_time, color: subtitleColor, size: 13),
            const SizedBox(width: 4),
            Text(
              'Ramalan 6 Jam',
              style: TextStyle(color: subtitleColor, fontSize: 12),
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
                          style: TextStyle(color: subtitleColor, fontSize: 10),
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
                  color: textColor,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: textColor,
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

  Widget _buildUVIndex(
    Color textColor,
    Color subtitleColor,
    Color inputBoxColor,
    Color borderColor,
  ) {
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
        color: inputBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: subtitleColor, size: 13),
              const SizedBox(width: 4),
              Text(
                'UV Index',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            uvIndex.round().toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            getUVDescription(uvIndex),
            style: TextStyle(color: textColor, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            child: LinearProgressIndicator(
              value: (uvIndex / 11).clamp(0.0, 1.0),
              backgroundColor: subtitleColor.withOpacity(0.3),
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
            style: TextStyle(color: subtitleColor, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperature(
    Color textColor,
    Color subtitleColor,
    Color inputBoxColor,
    Color borderColor,
  ) {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final feelsLike = current?['terasa_seperti']?.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat_outlined, color: subtitleColor, size: 13),
              const SizedBox(width: 4),
              Text(
                'Terasa Seperti',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${feelsLike}°',
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suhu yang terasa saat keluar,\ndengan faktor angin.',
            style: TextStyle(color: subtitleColor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSunPath(
    Color textColor,
    Color subtitleColor,
    Color inputBoxColor,
    Color borderColor,
  ) {
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
        color: inputBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.brightness_6_outlined, color: subtitleColor, size: 13),
              const SizedBox(width: 4),
              Text(
                'Jalur Matahari',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: SunPathPainter(subtitleColor),
              size: const Size(double.infinity, 60),
            ),
          ),
          Text(
            'Terbit: $sunrise  Terbenam: $sunset',
            style: TextStyle(color: subtitleColor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidity(
    Color textColor,
    Color subtitleColor,
    Color inputBoxColor,
    Color borderColor,
  ) {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final humidity = current?['kelembapan']?.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: subtitleColor, size: 13),
              const SizedBox(width: 4),
              Text(
                'Kelembaban',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$humidity%',
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            humidity > 70
                ? 'Kelembaban tinggi membuat\nterasa lebih panas.'
                : 'Kelembaban dalam kondisi\nnormal.',
            style: TextStyle(color: subtitleColor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildWindDirection(
    Color textColor,
    Color subtitleColor,
    Color inputBoxColor,
    Color borderColor,
  ) {
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
        color: inputBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air, color: subtitleColor, size: 13),
              const SizedBox(width: 4),
              Text(
                'Arah Angin',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: CompassPainter(
                  windDirection,
                  subtitleColor,
                  textColor,
                ),
                child: Center(
                  child: Text(
                    getWindDirectionText(windDirection),
                    style: TextStyle(
                      color: textColor,
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
              style: TextStyle(color: subtitleColor, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChanceOfRain(
    Color textColor,
    Color subtitleColor,
    Color inputBoxColor,
    Color borderColor,
  ) {
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final rainChance = current?['peluang_hujan']?.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.umbrella_outlined, color: subtitleColor, size: 12),
              const SizedBox(width: 4),
              Text(
                'Kemungkinan Hujan',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$rainChance%',
            style: TextStyle(
              color: textColor,
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
            style: TextStyle(color: subtitleColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Custom Painters
class SunPathPainter extends CustomPainter {
  final Color subtitleColor;

  SunPathPainter(this.subtitleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = subtitleColor.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    // canvas.drawPath(path, paint);

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
  final Color subtitleColor;
  final Color textColor;

  CompassPainter(this.windDirection, this.subtitleColor, this.textColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw compass circle
    final circlePaint =
        Paint()
          ..color = subtitleColor.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw wind direction arrow
    final arrowPaint =
        Paint()
          ..color = textColor
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

// weather_detail_sheet.dart
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:flutter_cuaca/route.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';

class WeatherDetailSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> forecastList;
  final Map<String, dynamic> current;
  final bool isLight;
  final Color cardColor;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(String?) formatTime;
  final String Function(dynamic, bool) getIconAsset;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildWeeklyForecast(),
              const SizedBox(height: 24),

              // Hourly Forecast
              _buildHourlyForecast(),
              const SizedBox(height: 24),

              // Grid Section
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
}

Widget _buildWeeklyForecast() {
  final days = ['SEL', 'SEL', 'RAB', 'KAM', 'JUM'];
  final icons = [
    Icons.thunderstorm,
    Icons.wb_cloudy,
    Icons.thunderstorm,
    Icons.wb_sunny,
    Icons.cloud,
  ];
  final temps = ['27°', '28°', '15°', '23°', '25°'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Row(
      //   children: [
      //     const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
      //     const SizedBox(width: 8),
      //     const Text(
      //       'Ramalan 5 hari',
      //       style: TextStyle(color: Colors.white54, fontSize: 14),
      //     ),
      //   ],
      // ),
      // const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          return Column(
            children: [
              Text(
                days[index],
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Icon(icons[index], color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                temps[index],
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white54, size: 13),
          const SizedBox(width: 4),
          const Text(
            'Ramalan 24 Jam',
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
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final hours = ['20.00', '21.00', '22.00', '23.00'];
                    if (value.toInt() < hours.length) {
                      return Text(
                        hours[value.toInt()],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
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
                spots: [
                  const FlSpot(0, 28),
                  const FlSpot(1, 25),
                  const FlSpot(2, 27),
                  const FlSpot(3, 24),
                ],
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
            minY: 20,
            maxY: 30,
          ),
        ),
      ),
    ],
  );
}

Widget _buildUVIndex() {
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
        const Text(
          '3',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Sedang',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          child: LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gunakan tabir surya saat keluar.',
          style: TextStyle(color: Colors.white54, fontSize: 9),
        ),
      ],
    ),
  );
}

Widget _buildTemperature() {
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
        const Text(
          '25°',
          style: TextStyle(
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
        const Text(
          'Sunrise: 06:15  Sunset: 18:30',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    ),
  );
}

Widget _buildHumidity() {
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
        const Text(
          '58%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Titik embun saat ini 13°C.\nKelembaban tinggi membuat terasa lebih.\n',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    ),
  );
}

Widget _buildWindDirection() {
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
              'Arah angin',
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
              painter: CompassPainter(),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        // const SizedBox(height: 8),
        // const Text(
        //   'Angin dari arah Barat dengan\nkecepatan 8 km/jam.',
        //   style: TextStyle(color: Colors.white54, fontSize: 10),
        // ),
      ],
    ),
  );
}

Widget _buildChanceOfRain() {
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
              'Kwmungkinan Hujan',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '76%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kemungkinan terjadi presipitasi.\nHujan ringan.',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    ),
  );
}

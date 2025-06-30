import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Jalankan main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('weatherBox');
  runApp(const MyApp());
}

// Root Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca Dummy',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SearchCityPage(),
        '/city-weather': (_) => const CityWeatherPreviewPage(),
      },
    );
  }
}

/// DUMMY DATA
final dummyWeather = {
  "forecast": [
    {"label": "Kemarin", "tanggal": "27/25", "ikon": "cloudy", "suhu": 28},
    {"label": "Hari Ini", "tanggal": "28/25", "ikon": "sunny", "suhu": 32},
    {"label": "Besok", "tanggal": "29/25", "ikon": "rainy", "suhu": 26},
    {
      "label": "Hari 3",
      "tanggal": "30/25",
      "ikon": "partly cloudy",
      "suhu": 30,
    },
    {
      "label": "Hari 4",
      "tanggal": "30/25",
      "ikon": "partly cloudy",
      "suhu": 29,
    },
  ],
};

class SearchCityPage extends StatelessWidget {
  const SearchCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyCities = [
      {"name": "Surabaya", "full": "Surabaya, Jawa Timur"},
      {"name": "Jakarta", "full": "Jakarta, DKI Jakarta"},
      {"name": "Bandung", "full": "Bandung, Jawa Barat"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyCities.length,
        itemBuilder: (context, index) {
          final city = dummyCities[index];
          return Card(
            color: Colors.white10,
            child: ListTile(
              title: Text(
                city['name']!,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                city['full']!,
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/city-weather',
                  arguments: city['name'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CityWeatherPreviewPage extends StatefulWidget {
  const CityWeatherPreviewPage({super.key});

  @override
  State<CityWeatherPreviewPage> createState() => _CityWeatherPreviewPageState();
}

class _CityWeatherPreviewPageState extends State<CityWeatherPreviewPage> {
  Map<String, dynamic>? weatherData;
  bool isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city = ModalRoute.of(context)?.settings.arguments as String?;
    weatherData = dummyWeather;

    // Simulasi favorit lokal (tanpa Hive)
    if (city == "Jakarta") {
      isFavorite = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final city =
        ModalRoute.of(context)?.settings.arguments as String? ?? "Kota";
    final List<double> suhuList =
        weatherData!['forecast']
            .map<double>((item) => double.parse(item['suhu'].toString()))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          city,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 250, // ✅ Tinggi box utama (ubah sesuai kebutuhan)
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          weatherData!['forecast'].length,
                          (index) {
                            final weather = weatherData!['forecast'][index];
                            return Column(
                              children: [
                                Text(
                                  weather['label'].toString().toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: const Color(
                                      0xFFFFFDF3,
                                    ).withOpacity(index == 1 ? 0.9 : 0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weather['tanggal'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Icon(
                                  getWeatherIcon(weather['ikon']),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${weather['suhu']}°",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFFFFFDF3),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        height: 60,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(show: false),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                ),
                                barWidth: 2,
                                spots: List.generate(
                                  suhuList.length,
                                  (index) =>
                                      FlSpot(index.toDouble(), suhuList[index]),
                                ),
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
            isFavorite
                ? WeatherActionButton(
                  icon: Icons.arrow_back,
                  label: "Lihat ke halaman awal",
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                )
                : WeatherActionButton(
                  icon: Icons.add,
                  label: "Tambah ke halaman awal",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          ],
        ),
      ),
    );
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rainy':
        return Icons.beach_access;
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'partly cloudy':
        return Icons.cloud_queue;
      default:
        return Icons.wb_cloudy;
    }
  }
}

class WeatherActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const WeatherActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ink(
          decoration: const ShapeDecoration(
            color: Color(0x0051576D),
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            iconSize: 28,
            padding: const EdgeInsets.all(20), // bikin lebih besar dan simetris
            // splashRadius: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

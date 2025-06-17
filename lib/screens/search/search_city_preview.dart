import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import './widgets/weather_action_button.dart';

class CityWeatherPreviewPage extends StatefulWidget {
  const CityWeatherPreviewPage({super.key});

  @override
  State<CityWeatherPreviewPage> createState() => _CityWeatherPreviewPageState();
}

class _CityWeatherPreviewPageState extends State<CityWeatherPreviewPage> {
  Map<String, dynamic>? weatherData;
  bool _isLoading = false;

  Future<void> fetchWeather(String cityName) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://myporto.site/api/search?query=$cityName'),
      );

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception("Gagal ambil data cuaca");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal ambil data cuaca")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city = ModalRoute.of(context)?.settings.arguments as String?;
    if (city != null) fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    final city = ModalRoute.of(context)?.settings.arguments as String?;
    final List<double> suhuList =
        weatherData != null
            ? weatherData!['forecast']
                .map<double>((item) => double.parse(item['suhu'].toString()))
                .toList()
            : [];

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          city ?? "",
          style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : weatherData == null
              ? const Center(
                child: Text(
                  "Tidak ada data",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: List.generate(
                                    weatherData!['forecast'].length,
                                    (index) {
                                      final weather =
                                          weatherData!['forecast'][index];
                                      return Column(
                                        children: [
                                          Text(
                                            weather['label'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            weather['tanggal'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Icon(
                                            getWeatherIcon(weather['ikon']),
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "${weather['suhu']}°",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 100,
                                  child: LineChart(
                                    LineChartData(
                                      titlesData: FlTitlesData(show: false),
                                      gridData: FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          isCurved: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white70,
                                            ],
                                          ),

                                          barWidth: 2,
                                          spots: List.generate(
                                            suhuList.length,
                                            (index) => FlSpot(
                                              index.toDouble(),
                                              suhuList[index],
                                            ),
                                          ),
                                          dotData: FlDotData(show: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                WeatherActionButton(
                                  icon: Icons.arrow_forward,
                                  label: "Lihat ke halaman awal",
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/',
                                      (route) => false,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

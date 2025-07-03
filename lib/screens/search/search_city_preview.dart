import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import './widgets/weather_action_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_cuaca/route.dart';

class CityWeatherPreviewPage extends StatefulWidget {
  const CityWeatherPreviewPage({super.key});

  @override
  State<CityWeatherPreviewPage> createState() => _CityWeatherPreviewPageState();
}

class _CityWeatherPreviewPageState extends State<CityWeatherPreviewPage> {
  Map<String, dynamic>? weatherData;
  bool _isLoading = false;
  bool isFavorite = false;
  String? currentCity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city = ModalRoute.of(context)?.settings.arguments as String?;
    if (city != null && city != currentCity) {
      currentCity = city;
      fetchWeather(city);
      checkIfFavorite(city);
    }
  }

  Future<void> fetchWeather(String cityName) async {
    setState(() => _isLoading = true);

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
      final encodedCity = Uri.encodeComponent(cityName);
      final url = Uri.parse('$baseUrl/api/search?query=$encodedCity');

      final response = await http.get(url);

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

  Future<void> checkIfFavorite(String fullName) async {
    // Pastikan FavoriteService sudah diinisialisasi
    await FavoriteService.init();
    final result = await FavoriteService.isFavorite(fullName);
    setState(() => isFavorite = result);
  }

  Future<void> addToFavorite() async {
    if (weatherData != null && currentCity != null) {
      // Ambil data lat/lon dari API suggestions untuk mendapatkan koordinat yang tepat
      try {
        final baseUrl =
            dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
        final encodedCity = Uri.encodeComponent(currentCity!);
        final suggestionsUrl = Uri.parse(
          '$baseUrl/api/suggestions?query=$encodedCity',
        );

        final response = await http.get(suggestionsUrl);

        if (response.statusCode == 200) {
          final List<dynamic> suggestions = json.decode(response.body);

          // Cari yang paling cocok dengan nama kota
          final matchedCity = suggestions.firstWhere(
            (item) => item['full'] == currentCity,
            orElse: () => suggestions.isNotEmpty ? suggestions.first : null,
          );

          if (matchedCity != null) {
            final cityData = {
              'name': matchedCity['name'],
              'full': matchedCity['full'],
              'lat': matchedCity['lat'].toString(),
              'lon': matchedCity['lon'].toString(),
            };

            await FavoriteService.addFavorite(cityData);
            setState(() => isFavorite = true);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${matchedCity['name']} ditambahkan ke favorit"),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Error adding to favorite: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menambahkan ke favorit")),
        );
      }
    }
  }

  Future<void> removeFromFavorite(String full) async {
    await FavoriteService.removeFavorite(full);
    setState(() => isFavorite = false);
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

  @override
  Widget build(BuildContext context) {
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
          currentCity ?? "",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                          weather['label']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: const Color(
                                              0xFFFFFDF3,
                                            ).withOpacity(
                                              index == 1 ? 0.9 : 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          weather['tanggal'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
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
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            color: const Color(0xFFFFFDF3),
                                            fontSize: 16,
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
                          onPressed: addToFavorite,
                        ),
                  ],
                ),
              ),
    );
  }
}

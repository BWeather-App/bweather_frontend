import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cuaca/route.dart';

class WeatherHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const WeatherHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WeatherModel.loadWeatherData(context);
  }

  String formatTime(String? t) {
    if (t == null) return '-';
    final dt = DateTime.tryParse(t);
    return dt != null ? DateFormat.Hm().format(dt) : '-';
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ValueListenableBuilder<bool>(
        valueListenable: WeatherModel.isLoading,
        builder: (context, isLoading, _) {
          return ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: WeatherModel.weatherData,
            builder: (context, weatherData, _) {
              final weather = weatherData?['weather']?['cuaca_saat_ini'] ?? {};

              final forecastList = [
                if ((weatherData?['weather']?['kemarin'] ?? []).isNotEmpty)
                  weatherData!['weather']['kemarin'][0],
                if ((weatherData?['weather']?['hari_ini'] ?? []).isNotEmpty)
                  weatherData!['weather']['hari_ini'][0],
                if ((weatherData?['weather']?['besok'] ?? []).isNotEmpty)
                  weatherData!['weather']['besok'][0],
                if ((weatherData?['weather']?['lusa'] ?? []).isNotEmpty)
                  weatherData!['weather']['lusa'][0],
                if ((weatherData?['weather']?['hari_ke_3'] ?? []).isNotEmpty)
                  weatherData!['weather']['hari_ke_3'][0],
              ];

              return Stack(
                children: [
                  // === HEADER TETAP DI ATAS ===
                  WeatherHeader(
                    location: weatherData?['location'],
                    isLight: isLight,
                    onAddCity: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchCityPage(),
                        ),
                      );
                    },
                    onToggleTheme: widget.onToggleTheme,
                  ),

                  // === KONTEN TENGAH (SUHU, DESKRIPSI, ANGIN) ===
                  if (!isLoading && weatherData != null)
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SUHU
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${(weather['suhu'] ?? 0).round()}",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  "°C",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // DESKRIPSI CUACA
                          Text(
                            WeatherModel.getWeatherDescription((weather)),
                            style: TextStyle(color: textColor, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // KECEPATAN ANGIN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.air, color: textColor, size: 24),
                              const SizedBox(width: 8),
                              Text("Angin", style: TextStyle(color: textColor)),
                              const SizedBox(width: 8),
                              Text(
                                "${weather['kecepatan_angin'] ?? '-'} m/s",
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // === LOADING INDICATOR ===
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),

                  // === ERROR STATE ===
                  if (!isLoading && weatherData == null)
                    Center(
                      child: Text(
                        "Gagal memuat data cuaca.",
                        style: TextStyle(color: textColor),
                      ),
                    ),

                  // === DRAGGABLE BOTTOM SHEET ===
                  if (!isLoading && weatherData != null)
                    DraggableScrollableSheet(
                      initialChildSize: 0.25,
                      minChildSize: 0.25,
                      maxChildSize: 1.0,
                      builder: (context, scrollController) {
                        return WeatherDetailSheet(
                          scrollController: scrollController,
                          forecastList:
                              forecastList.cast<Map<String, dynamic>>(),
                          current: weather,
                          isLight: isLight,
                          cardColor: cardColor,
                          getWeatherDescription:
                              WeatherModel.getWeatherDescription,
                          formatTime: formatTime,
                          getIconAsset: WeatherModel.getIconAsset,
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

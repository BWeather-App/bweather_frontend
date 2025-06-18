import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cuaca/route.dart';
import 'dart:ui';

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
  @override
  void initState() {
    super.initState();
    WeatherModel.loadWeatherData(context);
  }

  String formatTimeFromString(String? t) {
    if (t == null) return '-';
    final dt = DateTime.tryParse(t);
    return dt != null ? DateFormat.Hm().format(dt) : '-';
  }

  String formatTimeFromTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.Hm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: WeatherModel.isLoading,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: WeatherModel.weatherData,
              builder: (context, weatherData, _) {
                final weather =
                    weatherData?['weather']?['cuaca_saat_ini'] ?? {};
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

                final current = weatherData?['current'];
                final lat = weatherData?['location']?['lat'];
                final lon = weatherData?['location']?['lon'];

                String _getIconAsset(String? condition, bool isDarkMode) {
                  return WeatherModel.getIconAsset(condition ?? '', isDarkMode);
                }

                final String? mainCondition = weatherData?['cuaca'];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WeatherHeader(
                      location: weatherData?['location'],
                      isLight: isLight,
                      onAddCity: () async {
                        final result = await showGeneralDialog<String>(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Search",
                          barrierColor: Colors.transparent,
                          pageBuilder: (_, __, ___) => const SearchCityPage(),
                          transitionBuilder: (context, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                        );

                        if (result != null && result.isNotEmpty) {
                          print("Kota dipilih: $result");
                        }
                      },
                      onToggleTheme: widget.onToggleTheme,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          if (!isLoading && weatherData != null)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (mainCondition != null) ...[
                                        Image.asset(
                                          _getIconAsset(
                                            mainCondition,
                                            !isLight,
                                          ),
                                          width: 120,
                                          height: 120,
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                      const SizedBox(height: 10),
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
                                  Text(
                                    WeatherModel.getWeatherDescription(weather),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.air,
                                        color: textColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Angin",
                                        style: TextStyle(color: textColor),
                                      ),
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

                          if (isLoading)
                            const Center(child: CircularProgressIndicator()),

                          if (!isLoading && weatherData == null)
                            Center(
                              child: Text(
                                "Gagal memuat data cuaca.",
                                style: TextStyle(color: textColor),
                              ),
                            ),

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
                                  current: current ?? {},
                                  isLight: isLight,
                                  cardColor: cardColor,
                                  getWeatherDescription:
                                      WeatherModel.getWeatherDescription,
                                  formatTime: formatTimeFromTimestamp,
                                  getIconAsset:
                                      (condition, isDark) =>
                                          WeatherModel.getIconAsset(
                                            condition,
                                            isDark,
                                          ),
                                  lat: lat,
                                  lon: lon,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

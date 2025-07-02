import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cuaca/route.dart';
// import 'dart:ui';
import 'package:hive/hive.dart';

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
  List<Map<String, dynamic>> favoriteWeatherList = []; // Bersifat public
  bool isFavoriteLoading = true;

  @override
  void initState() {
    super.initState();
    WeatherModel.loadWeatherData(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFavoriteDataOnce(); // hanya sekali load
    });
  }

  Future<void> loadFavoriteDataOnce() async {
    setState(() => isFavoriteLoading = true);

    try {
      final data = await FavoriteService.getFavoriteWeatherData();
      setState(() {
        favoriteWeatherList =
            data; // Simpan semua (maks 3 sudah dibatasi di service)
      });
    } catch (e) {
      debugPrint("Gagal memuat data favorit: $e");
    } finally {
      setState(() => isFavoriteLoading = false);
    }
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
    // final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    // final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: WeatherModel.isLoading,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: WeatherModel.weatherData,
              builder: (context, weatherData, _) {
                // final weather =
                //     weatherData?['weather']?['cuaca_saat_ini'] ?? {};
                // final forecastList = [
                //   if ((weatherData?['weather']?['kemarin'] ?? []).isNotEmpty)
                //     (weatherData?['weather'] as Map?)?['kemarin'],
                //   if ((weatherData?['weather']?['hari_ini'] ?? []).isNotEmpty)
                //     (weatherData?['weather'] as Map?)?['hari_ini'],
                //   if ((weatherData?['weather']?['besok'] ?? []).isNotEmpty)
                //     (weatherData?['weather'] as Map?)?['besok'],
                //   if ((weatherData?['weather']?['lusa'] ?? []).isNotEmpty)
                //     (weatherData?['weather'] as Map?)?['lusa'],
                //   if ((weatherData?['weather']?['hari_ke_3'] ?? []).isNotEmpty)
                //     (weatherData?['weather'] as Map?)?['hari_ke_3'],
                // ];

                final rawWeather = weatherData?['weather'];
                final weather =
                    (rawWeather is Map && rawWeather['cuaca_saat_ini'] is Map)
                        ? Map<String, dynamic>.from(
                          rawWeather['cuaca_saat_ini'],
                        )
                        : <String, dynamic>{};

                final forecastList = <Map<String, dynamic>>[];

                if (rawWeather is Map) {
                  final keys = [
                    'kemarin',
                    'hari_ini',
                    'besok',
                    'lusa',
                    'hari_ke_3',
                  ];
                  for (final key in keys) {
                    final item = rawWeather[key];
                    if (item is Map) {
                      forecastList.add(Map<String, dynamic>.from(item));
                    }
                  }
                }

                final current = weatherData?['weather'];
                final lat = weatherData?['location']?['lat'];
                final lon = weatherData?['location']?['lon'];

                final description = WeatherModel.getWeatherDescription(weather);

                final mainCondition = weather['main'] ?? description;

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
                      child: PageView.builder(
                        itemCount:
                            1 +
                            favoriteWeatherList.length.clamp(
                              0,
                              3,
                            ), // 1 = lokasi saat ini
                        itemBuilder: (context, index) {
                          final isLight =
                              Theme.of(context).brightness == Brightness.light;
                          final textColor =
                              isLight ? const Color(0xFF232B3E) : Colors.white;
                          final cardColor =
                              isLight
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.05);
                          if (index == 0) {
                            return Stack(
                              children: [
                                if (!isLoading && weatherData != null)
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (mainCondition != null) ...[
                                          Image.asset(
                                            WeatherModel.getIconAsset(
                                              mainCondition,
                                              !isLight,
                                            ),
                                            width: 80,
                                            height: 70,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                              ),
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
                                          WeatherModel.getWeatherDescription(
                                            weather,
                                          ),
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.air,
                                              color: textColor,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Angin",
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${weather['kecepatan_angin'] ?? '-'} m/s",
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                if (isLoading)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),

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
                                        forecastList: forecastList,
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
                            );
                          } else {
                            final cityWeather = favoriteWeatherList[index - 1];
                            // 🐞 Debug cepat di sini
                            debugPrint('======= DEBUG FAVORITE CITY =======');
                            debugPrint(
                              'rawCityWeather runtimeType: ${cityWeather.runtimeType}',
                            );
                            debugPrint(
                              'weather type: ${cityWeather['weather']?.runtimeType}',
                            );
                            debugPrint('full data: $cityWeather');
                            
                            final weather = cityWeather['weather'];
                            if (weather == null ||
                                weather is! Map<String, dynamic>) {
                              return Center(
                                child: Text(
                                  "Cuaca tidak tersedia",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            buildFavoriteWeatherView(
                              cityWeather,
                              isLight: isLight,
                              textColor: textColor,
                              cardColor: cardColor,
                              formatTimeFromTimestamp: formatTimeFromTimestamp,
                            );
                          }

                          //else {
                          //   final cityWeather = favoriteWeatherList[index - 1];
                          //   return buildFavoriteWeatherView(cityWeather);
                          // }
                        },
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

Widget buildFavoriteWeatherView(
  Map<String, dynamic> cityWeather, {
  required bool isLight,
  required Color textColor,
  required Color cardColor,
  required String Function(int) formatTimeFromTimestamp,
}) {
  final current = cityWeather['current'] ?? {}; // Gunakan langsung current
  final forecastList = cityWeather['forecast'] ?? [];
  final mainCondition = current['cuaca'];
  final lat = current['lat'];
  final lon = current['lon'];

  return Stack(
    children: [
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mainCondition != null) ...[
              Image.asset(
                WeatherModel.getIconAsset(mainCondition, !isLight),
                width: 80,
                height: 70,
              ),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${(current['suhu'] ?? 0).round()}",
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
                    style: TextStyle(color: textColor, fontSize: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              WeatherModel.getWeatherDescription(current),
              style: TextStyle(color: textColor, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.air, color: textColor, size: 24),
                const SizedBox(width: 8),
                Text("Angin", style: TextStyle(color: textColor)),
                const SizedBox(width: 8),
                Text(
                  "${current['kecepatan_angin'] ?? '-'} m/s",
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ],
        ),
      ),

      // Detail Cuaca (bawah)
      DraggableScrollableSheet(
        initialChildSize: 0.25,
        minChildSize: 0.25,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return WeatherDetailSheet(
            scrollController: scrollController,
            forecastList: forecastList,
            current: current,
            isLight: isLight,
            cardColor: cardColor,
            getWeatherDescription: WeatherModel.getWeatherDescription,
            formatTime: formatTimeFromTimestamp,
            getIconAsset:
                (condition, isDark) =>
                    WeatherModel.getIconAsset(condition, isDark),
            lat: lat,
            lon: lon,
          );
        },
      ),
    ],
  );
}

// Favorite Kota lama
// Widget buildFavoriteWeatherView(Map<String, dynamic> cityWeather) {
//   return Padding(
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           cityWeather['location'] ?? 'Tidak diketahui',
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           '${cityWeather['temperature']}°C',
//           style: const TextStyle(fontSize: 48),
//         ),
//         // ...tambahkan forecast dan info lain
//       ],
//     ),
//   );
// }

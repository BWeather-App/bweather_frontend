import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cuaca/route.dart';
// import 'package:hive/hive.dart';

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
  List<Map<String, dynamic>> favoriteWeatherList = [];
  bool isFavoriteLoading = true;

  @override
  void initState() {
    super.initState();
    WeatherModel.loadWeatherData(context);

    // Pastikan Hive box sudah diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FavoriteService.init();
      await loadFavoriteDataOnce();
    });
  }

  Future<void> loadFavoriteDataOnce() async {
    setState(() => isFavoriteLoading = true);

    try {
      final data = await FavoriteService.getFavoriteWeatherData();
      debugPrint("Loaded ${data.length} favorite cities");
      setState(() {
        favoriteWeatherList = data;
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: WeatherModel.isLoading,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: WeatherModel.weatherData,
              builder: (context, weatherData, _) {
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

                return RefreshIndicator(
                  onRefresh: () async {
                    RestartWidget.restartApp(context); // soft-restart app
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Column(
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
                                pageBuilder:
                                    (_, __, ___) => const SearchCityPage(),
                                transitionBuilder: (
                                  context,
                                  animation,
                                  __,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(
                                  milliseconds: 200,
                                ),
                              );

                              if (result != null && result.isNotEmpty) {
                                print("Kota dipilih: $result");
                                await loadFavoriteDataOnce();
                              }
                            },
                            onToggleTheme: widget.onToggleTheme,
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.8, // agar PageView cukup tinggi
                            child: PageView.builder(
                              itemCount: 1 + favoriteWeatherList.length,
                              itemBuilder: (context, index) {
                                final isLight =
                                    Theme.of(context).brightness ==
                                    Brightness.light;
                                final textColor =
                                    isLight
                                        ? const Color(0xFF232B3E)
                                        : Colors.white;
                                final cardColor =
                                    isLight
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.05);

                                if (index == 0) {
                                  // Halaman cuaca lokasi saat ini
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                              scrollController:
                                                  scrollController,
                                              forecastList: forecastList,
                                              current: current ?? {},
                                              isLight: isLight,
                                              cardColor: cardColor,
                                              getWeatherDescription:
                                                  WeatherModel
                                                      .getWeatherDescription,
                                              formatTime:
                                                  formatTimeFromTimestamp,
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
                                  // Halaman cuaca kota favorit
                                  if (isFavoriteLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final cityWeather =
                                      favoriteWeatherList[index - 1];
                                  return buildFavoriteWeatherView(
                                    cityWeather,
                                    isLight: isLight,
                                    textColor: textColor,
                                    cardColor: cardColor,
                                    formatTimeFromTimestamp:
                                        formatTimeFromTimestamp,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
  debugPrint(
    "Building favorite weather view for: ${cityWeather['city_info']?['full']}",
  );

  final weather = cityWeather['weather'] ?? {};
  final current = weather['cuaca_saat_ini'] ?? {};
  final cityInfo = cityWeather['city_info'] ?? {};

  if (current.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: textColor, size: 48),
          const SizedBox(height: 16),
          Text(
            "Data cuaca tidak tersedia",
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          Text(
            "untuk ${cityInfo['full'] ?? 'kota favorit'}",
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  final forecastList = <Map<String, dynamic>>[];
  final keys = ['kemarin', 'hari_ini', 'besok', 'lusa', 'hari_ke_3'];

  for (final key in keys) {
    final item = weather[key];
    if (item is Map) {
      forecastList.add(Map<String, dynamic>.from(item));
    }
  }

  final lat = cityWeather['location']?['lat'];
  final lon = cityWeather['location']?['lon'];

  return Stack(
    children: [
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cuaca
            Image.asset(
              WeatherModel.getIconAsset(
                WeatherModel.getWeatherDescription(current),
                !isLight,
              ),
              width: 80,
              height: 70,
            ),
            const SizedBox(height: 10),

            // Suhu
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

            // Deskripsi cuaca
            Text(
              WeatherModel.getWeatherDescription(current),
              style: TextStyle(color: textColor, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Nama kota
            Text(
              cityInfo['full'] ?? 'Kota Favorit',
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Info angin
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

      // Detail sheet
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

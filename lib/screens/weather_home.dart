import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';
import 'search_city_page.dart';
import 'manage_city_page.dart';
import 'weather_detail_page.dart';

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
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final granted = await PermissionService.requestLocationPermission(context);
    if (!granted) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final position = await LocationService().getCurrentLocation();
      final data = await WeatherService().fetchWeather(
        lat: position.latitude,
        lon: position.longitude,
      );
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat data cuaca: $e');
      setState(() => isLoading = false);
    }
  }

  String _getIconAsset(String condition, bool isDark) {
    final base = "assets/icons/";
    final map = {
      "clear": "clear",
      "cerah": "clear",
      "clouds": "cloudy",
      "rain": "rain",
      "drizzle": "drizzle",
      "thunderstorm": "storm",
      "snow": "snow",
      "mist": "mist",
      "fog": "fog",
      "haze": "haze",
    };
    final icon = map[condition.toLowerCase()] ?? "cloudy";
    return "$base${isDark ? 'dark' : 'light'}/$icon.png";
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final iconColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    final weather = weatherData?['current'];
    final location = weatherData?['location'];
    final forecastList = [
      if (weatherData?['yesterday'] != null) weatherData!['yesterday'],
      if (weatherData?['current'] != null) weatherData!['current'],
      ...?weatherData?['forecast'],
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.add, color: iconColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchCityPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isLight ? Icons.dark_mode : Icons.light_mode,
              color: iconColor,
            ),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageCityPage()),
              );
            },
          ),
        ],
        centerTitle: true,
        title: Column(
          children: [
            Text(
              location?['name'] ?? "Memuat lokasi...",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              location?['country'] ?? "",
              style: TextStyle(
                color: subTextColor,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : weatherData == null
              ? Center(
                child: Text(
                  "Gagal memuat data cuaca.",
                  style: TextStyle(color: textColor),
                ),
              )
              : Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    _getIconAsset(weather?['main'] ?? 'clear', !isLight),
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${(weather?['temp'] ?? 0).round()}",
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
                          style: TextStyle(color: subTextColor, fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather?['description'] ?? "",
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.air, color: subTextColor, size: 24),
                      const SizedBox(width: 8),
                      Text("Angin", style: TextStyle(color: subTextColor)),
                      const SizedBox(width: 8),
                      Text(
                        "${weather?['wind_speed'] ?? '-'} m/s",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeatherDetailPage(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: subTextColor,
                      size: 32,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          isLight
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          forecastList.map<Widget>((day) {
                            final time =
                                DateTime.tryParse(day['time']) ??
                                DateTime.now();
                            final weekday =
                                DateFormat.E(
                                  'id_ID',
                                ).format(time).toUpperCase();
                            final temp = "${(day['temp'] ?? 0).round()}°";
                            final icon = _getIconAsset(
                              day['main'] ?? 'clear',
                              !isLight,
                            );
                            final isToday = DateTime.now().day == time.day;

                            return _WeatherDay(
                              iconWidget: Image.asset(
                                icon,
                                width: 40,
                                height: 40,
                              ),
                              day: weekday,
                              temp: temp,
                              selected: isToday,
                              isLight: isLight,
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _WeatherDay extends StatelessWidget {
  final Widget iconWidget;
  final String day;
  final String temp;
  final bool selected;
  final bool isLight;

  const _WeatherDay({
    required this.iconWidget,
    required this.day,
    required this.temp,
    this.selected = false,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white70;

    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: selected ? textColor : subTextColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        iconWidget,
        const SizedBox(height: 4),
        Text(
          temp,
          style: TextStyle(
            color: selected ? textColor : subTextColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

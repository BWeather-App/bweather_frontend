import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';
import 'search_city_page.dart';
import 'manage_city_page.dart';

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
  final ScrollController _scrollController = ScrollController();

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
      final result = await WeatherService().getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        weatherData = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat data cuaca: $e');
      setState(() => isLoading = false);
    }
  }

  String _getWeatherDescription(Map<String, dynamic> weather) {
    final temp = weather['suhu'] ?? 0;
    final humidity = weather['kelembapan'] ?? 0;
    final rainChance = weather['peluang_hujan'] ?? 0;

    if (rainChance > 80) return "Hujan Lebat";
    if (rainChance > 50) return "Hujan Ringan";
    if (humidity > 80 && temp < 26) return "Berawan dan Lembab";
    if (temp >= 30 && rainChance < 20) return "Panas Terik";
    if (temp <= 25 && rainChance < 10) return "Cerah";
    return "Berawan";
  }

  String _getIconAsset(dynamic condition, bool isDark) {
    final base = "assets/icons/";
    final map = {
      "clear": "clear",
      "cerah": "clear",
      "clouds": "cloudy",
      "berawan": "cloudy",
      "berawan dan lembab": "cloudy",
      "rain": "rain",
      "hujan ringan": "rain",
      "hujan lebat": "storm",
      "drizzle": "drizzle",
      "thunderstorm": "storm",
      "storm": "storm",
      "snow": "snow",
      "mist": "mist",
      "fog": "fog",
      "haze": "haze",
      "panas terik": "clear",
    };

    final key = (condition is String) ? condition.toLowerCase() : "clear";
    final icon = map[key] ?? "cloudy";
    return "$base${isDark ? 'dark' : 'light'}/$icon.png";
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final iconColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    final weather = weatherData?['weather']?['cuaca_saat_ini'];
    final location = weatherData?['location'];
    final mainCondition =
        weather?['main'] ?? _getWeatherDescription(weather ?? {});
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

    final current = weatherData?['weather']?['cuaca_saat_ini'] ?? {};

    String formatTime(String? t) {
      if (t == null) return '-';
      final dt = DateTime.tryParse(t);
      return dt != null ? DateFormat.Hm().format(dt) : '-';
    }

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
              : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 30),

                  Image.asset(
                    _getIconAsset(mainCondition, !isLight),
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${(weather?['suhu'] ?? 0).round()}",
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
                    _getWeatherDescription(weather ?? {}),
                    style: TextStyle(color: textColor, fontSize: 18),
                    textAlign: TextAlign.center,
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
                        "${weather?['kecepatan_angin'] ?? '-'} m/s",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                  // Tambahkan ini tepat di bawah Container forecast
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: subTextColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                  offset: Offset(0, 4),
                                ),
                              ]
                              : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          forecastList.map<Widget>((day) {
                            final time =
                                DateTime.tryParse(day['waktu'] ?? '') ??
                                DateTime.now();
                            final weekday =
                                DateFormat.E(
                                  'id_ID',
                                ).format(time).toUpperCase();
                            final temp = "${(day['suhu'] ?? 0).round()}°";
                            final condition =
                                day['main'] ?? _getWeatherDescription(day);
                            final icon = _getIconAsset(condition, !isLight);

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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _InfoCard(
                        title: "UV Index",
                        value: "${current['indeks_uv'] ?? '-'}",
                        subtitle: "",
                        color: Colors.green,
                        isLight: isLight,
                      ),
                      const SizedBox(width: 12),
                      _InfoCard(
                        title: "Terasa Seperti",
                        value: "${(current['terasa_seperti'] ?? 0).round()}°C",
                        subtitle: "",
                        color: Colors.blue,
                        isLight: isLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoCard(
                        title: "Matahari",
                        value:
                            "${formatTime(current['matahari_terbit'])} - ${formatTime(current['matahari_terbenam'])}",
                        subtitle: "Terbit - Terbenam",
                        color: Colors.amber,
                        isLight: isLight,
                      ),
                      const SizedBox(width: 12),
                      _InfoCard(
                        title: "Kelembaban",
                        value: "${(current['kelembapan'] ?? 0).round()}%",
                        subtitle: "",
                        color: Colors.cyan,
                        isLight: isLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoCard(
                        title: "Arah Angin",
                        value: "${current['arah_angin'] ?? '-'}°",
                        subtitle: "",
                        color: Colors.orange,
                        isLight: isLight,
                      ),
                      const SizedBox(width: 12),
                      _InfoCard(
                        title: "Peluang Hujan",
                        value: "${(current['peluang_hujan'] ?? 0).round()}%",
                        subtitle: "",
                        color: Colors.indigo,
                        isLight: isLight,
                      ),
                    ],
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isLight;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);
    final List<BoxShadow> cardShadow =
        isLight
            ? [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ]
            : const [];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: subTextColor, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(color: subTextColor, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

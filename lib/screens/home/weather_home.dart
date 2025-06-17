import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
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
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final result = await WeatherModel.loadWeatherData(context, (v) {
      setState(() => isLoading = v);
    });

    if (result != null) {
      setState(() => weatherData = result);
    }
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
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Tutup dialog pencarian', // ✅ Tambahkan label ini
              barrierColor: Colors.black12,
              pageBuilder: (_, __, ___) => const SearchCityPage(),
              transitionBuilder: (context, anim1, anim2, child) {
                return FadeTransition(opacity: anim1, child: child);
              },
              transitionDuration: const Duration(milliseconds: 200),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${location?['city'] ?? ''}, ',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: location?['region'] ?? '',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              location?['country']?.toUpperCase() ?? '',
              style: TextStyle(
                color: subTextColor,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // ⛔️ Logika if sebelumnya salah urut, harus dibetulkan
              if (isLoading) const SizedBox(height: 100),
              if (!isLoading && weatherData == null)
                Center(
                  child: Text(
                    "Gagal memuat data cuaca.",
                    style: TextStyle(color: textColor),
                  ),
                ),
              if (!isLoading && weatherData != null) ...[
                // ✅ HEADER
                WeatherHeader(
                  weather: (weather ?? {}) as Map<String, dynamic>,
                  getWeatherDescription: WeatherModel.getWeatherDescription,
                  getIconAsset: WeatherModel.getIconAsset,
                  isLight: isLight,
                ),

                // Panah tarik
                const SizedBox(height: 24),
              ],
            ],
          ),

          // ✅ SHEET DI TUMPUKAN ATAS
          if (!isLoading && weatherData != null)
            DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: 0.25,
              maxChildSize: 1.0,
              builder: (context, scrollController) {
                return WeatherDetailSheet(
                  scrollController: scrollController,
                  forecastList: forecastList.cast<Map<String, dynamic>>(),
                  current: current,
                  isLight: isLight,
                  cardColor: cardColor,
                  getWeatherDescription: WeatherModel.getWeatherDescription,
                  formatTime: formatTime,
                  getIconAsset: WeatherModel.getIconAsset,
                );
              },
            ),

          // ✅ LOADING TETAP DITUMPUKAN DI ATAS
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

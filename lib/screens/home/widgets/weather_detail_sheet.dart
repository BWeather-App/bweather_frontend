// weather_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherDetailSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> forecastList;
  final Map<String, dynamic> current;
  final bool isLight;
  final Color cardColor;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(int) formatTime;
  final String Function(dynamic, bool) getIconAsset;
  final double? lat;
  final double? lon;

  const WeatherDetailSheet({
    Key? key,
    required this.scrollController,
    required this.forecastList,
    required this.current,
    required this.isLight,
    required this.cardColor,
    required this.getWeatherDescription,
    required this.formatTime,
    required this.getIconAsset,
    this.lat,
    this.lon,
  }) : super(key: key);

  @override
  State<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class WeatherWidgets extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final BuildContext context;

  const WeatherWidgets({Key? key, this.weatherData, required this.context})
    : super(key: key);

  // Konstanta spacing untuk konsistensi
  static const double _cardPadding = 16.0;
  static const double _cardBorderRadius = 16.0;
  static const double _cardGap = 12.0;
  static const double _headerSpacing = 12.0;
  static const double _smallSpacing = 4.0;
  static const double _mediumSpacing = 8.0;
  static const double _iconSize = 14.0;
  static const double _cardMinHeight =
      160.0; // Tambahkan minimum height yang konsisten

  // Helper method to get theme colors
  Map<String, Color> _getThemeColors() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      'blurBackgroundColor':
          isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
      'textColor': isDark ? Colors.white : Colors.black,
      'hintColor': isDark ? Colors.white38 : Colors.black38,
      'iconColor': isDark ? Colors.white70 : Colors.black54,
      'subtitleColor': isDark ? Colors.white70 : Colors.black54,
      'inputBoxColor':
          isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.05),
      'cardColor':
          isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
      'borderColor':
          isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
    };
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '--:--';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  Widget _buildUVIndex() {
    final colors = _getThemeColors();
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final uvIndex = current?['indeks_uv']?.toDouble() ?? 2.0;

    String getUVDescription(double uv) {
      if (uv < 3) return 'Rendah';
      if (uv < 6) return 'Sedang';
      if (uv < 8) return 'Tinggi';
      if (uv < 11) return 'Sangat Tinggi';
      return 'Ekstrem';
    }

    List<Color> getUVGradientColors() {
      return [
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.red,
        Colors.purple,
      ];
    }

    return Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors['cardColor'],
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: colors['borderColor']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: colors['iconColor'],
                size: _iconSize,
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                'UV Index',
                style: TextStyle(
                  color: colors['subtitleColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _headerSpacing),
          Text(
            uvIndex.round().toString(),
            style: TextStyle(
              color: colors['textColor'],
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: _smallSpacing),
          Text(
            getUVDescription(uvIndex),
            style: TextStyle(
              color: colors['subtitleColor'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _headerSpacing),
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: getUVGradientColors(),
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
          const SizedBox(height: _mediumSpacing),
          const Spacer(), // Tambahkan spacer untuk mengisi ruang
          Text(
            getUVDescription(uvIndex) == 'Rendah'
                ? 'Aman untuk beraktivitas'
                : getUVDescription(uvIndex) == 'Sedang'
                ? 'Sedang sepanjang hari'
                : getUVDescription(uvIndex) == 'Tinggi'
                ? 'Gunakan pelindung'
                : 'Hindari paparan langsung',
            style: TextStyle(
              color: colors['subtitleColor'],
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTemperature() {
    final colors = _getThemeColors();
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final feelsLike = current?['terasa_seperti']?.round() ?? 26;

    return Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors['cardColor'],
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: colors['borderColor']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.thermostat_outlined,
                color: colors['iconColor'],
                size: _iconSize,
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                'Terasa Seperti',
                style: TextStyle(
                  color: colors['subtitleColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _headerSpacing),
          Text(
            '${feelsLike}°',
            style: TextStyle(
              color: colors['textColor'],
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Spacer(), // Tambahkan spacer
          Text(
            'Suhu yang dirasakan\ndengan faktor angin',
            style: TextStyle(
              color: colors['subtitleColor'],
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunPath() {
    final colors = _getThemeColors();
    final todayData = weatherData?['weather']['hari_ini'] as List? ?? [];
    String sunrise = '05:46';
    String sunset = '17:27';

    if (todayData.isNotEmpty) {
      sunrise = _formatTime(todayData.first['matahari_terbit']);
      sunset = _formatTime(todayData.first['matahari_terbenam']);
    }

    return Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors['cardColor'],
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: colors['borderColor']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: colors['iconColor'],
                size: _iconSize,
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                'Jalur Matahari',
                style: TextStyle(
                  color: colors['subtitleColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _headerSpacing),
          Expanded(
            child: CustomPaint(
              painter: SunPathPainter(
                sunrise: sunrise,
                sunset: sunset,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
              size: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: _mediumSpacing),
          Text(
            'Terbit: $sunrise  Terbenam: $sunset',
            style: TextStyle(color: colors['subtitleColor'], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidity() {
    final colors = _getThemeColors();
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final humidity = current?['kelembapan']?.round() ?? 87;

    return Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors['cardColor'],
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: colors['borderColor']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: colors['iconColor'],
                size: _iconSize,
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                'Kelembaban',
                style: TextStyle(
                  color: colors['subtitleColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _headerSpacing),
          Text(
            '$humidity%',
            style: TextStyle(
              color: colors['textColor'],
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Spacer(), // Tambahkan spacer
          Text(
            humidity > 70
                ? 'Kelembaban tinggi,\nterasa lebih panas'
                : 'Kelembaban dalam\nkondisi normal',
            style: TextStyle(
              color: colors['subtitleColor'],
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindDirection() {
    final colors = _getThemeColors();
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final windDirection = current?['arah_angin']?.toDouble() ?? 180.0;
    final windSpeed = current?['kecepatan_angin']?.toDouble() ?? 18.0;

    String getWindDirectionText(double degrees) {
      if (degrees >= 337.5 || degrees < 22.5) return 'U';
      if (degrees >= 22.5 && degrees < 67.5) return 'TL';
      if (degrees >= 67.5 && degrees < 112.5) return 'T';
      if (degrees >= 112.5 && degrees < 157.5) return 'TG';
      if (degrees >= 157.5 && degrees < 202.5) return 'S';
      if (degrees >= 202.5 && degrees < 247.5) return 'BD';
      if (degrees >= 247.5 && degrees < 292.5) return 'B';
      if (degrees >= 292.5 && degrees < 337.5) return 'BL';
      return 'S';
    }

    return Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors['cardColor'],
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: colors['borderColor']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.air, color: colors['iconColor'], size: _iconSize),
              const SizedBox(width: _smallSpacing),
              Text(
                'Arah Angin',
                style: TextStyle(
                  color: colors['subtitleColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _headerSpacing),
          Expanded(
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4A9EFF), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: ModernCompassPainter(
                    windDirection,
                    windSpeed,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  child: Stack(
                    children: [
                      // Compass direction labels
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: colors['textColor'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            'T',
                            style: TextStyle(
                              color: colors['textColor'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: colors['textColor'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            'B',
                            style: TextStyle(
                              color: colors['textColor'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Center wind speed
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${windSpeed.round()}',
                              style: TextStyle(
                                color: colors['textColor'],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'm/s',
                              style: TextStyle(
                                color: colors['subtitleColor'],
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: _mediumSpacing),
          Center(
            child: Text(
              '${getWindDirectionText(windDirection)} ${windSpeed.round()} m/s',
              style: TextStyle(
                color: colors['subtitleColor'],
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChanceOfRain() {
    final colors = _getThemeColors();
    final current = weatherData?['weather']['cuaca_saat_ini'];
    final rainChance = current?['peluang_hujan']?.round() ?? 74;

    return Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors['cardColor'],
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: colors['borderColor']!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.umbrella_outlined,
                color: colors['iconColor'],
                size: _iconSize,
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                'Kemungkinan Hujan',
                style: TextStyle(
                  color: colors['subtitleColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _headerSpacing),
          Text(
            '$rainChance%',
            style: TextStyle(
              color: colors['textColor'],
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Spacer(), // Tambahkan spacer
          Text(
            rainChance > 70
                ? 'Kemungkinan besar\nhujan, bawa payung'
                : rainChance > 30
                ? 'Kemungkinan hujan\nringan'
                : 'Kemungkinan kecil\nhujan',
            style: TextStyle(
              color: colors['subtitleColor'],
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeatherGrid() {
    return Column(
      children: [
        // Row 1: UV Index dan Terasa Seperti
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildUVIndex()),
              const SizedBox(width: _cardGap),
              Expanded(child: _buildTemperature()),
            ],
          ),
        ),
        const SizedBox(height: _cardGap),

        // Row 2: Jalur Matahari dan Kelembaban
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildSunPath()),
              const SizedBox(width: _cardGap),
              Expanded(child: _buildHumidity()),
            ],
          ),
        ),
        const SizedBox(height: _cardGap),

        // Row 3: Arah Angin dan Kemungkinan Hujan
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildWindDirection()),
              const SizedBox(width: _cardGap),
              Expanded(child: _buildChanceOfRain()),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildWeatherGrid();
  }
}

class _WeatherDetailSheetState extends State<WeatherDetailSheet> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      double lat, lon;

      // Jika lat/lon sudah disediakan (dari kota favorit), gunakan itu
      if (widget.lat != null && widget.lon != null) {
        lat = widget.lat!;
        lon = widget.lon!;
      } else {
        // Jika tidak, gunakan lokasi saat ini
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lon = position.longitude;
      }

      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
      final url = '$baseUrl/api/weather?lat=$lat&lon=$lon';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        final data = Map<String, dynamic>.from(raw);

        if (!mounted) return;
        setState(() {
          weatherData = data;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          error = 'Failed to load weather data';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '--:--';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  // Helper method to get theme colors
  Map<String, Color> _getThemeColors() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      'blurBackgroundColor':
          isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
      'textColor': isDark ? Colors.white : Colors.black,
      'hintColor': isDark ? Colors.white38 : Colors.black38,
      'iconColor': isDark ? Colors.white70 : Colors.black54,
      'subtitleColor': isDark ? Colors.white70 : Colors.black54,
      'inputBoxColor':
          isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.05),
      'cardColor':
          isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
      'borderColor':
          isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors();

    if (isLoading) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: colors['textColor']),
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: colors['textColor'], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: TextStyle(color: colors['textColor']),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        error = null;
                      });
                      _fetchWeatherData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final weatherWidgets = WeatherWidgets(
      weatherData: weatherData,
      context: context,
    );

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ListView(
            controller: widget.scrollController,
            children: [
              Center(
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: colors['iconColor'],
                ),
              ),
              const SizedBox(height: 16),
              _buildWeeklyForecast(),
              const SizedBox(height: 24),
              _buildHourlyForecast(),
              const SizedBox(height: 24),

              // Panggil method buildWeatherGrid() yang sudah dibuat
              weatherWidgets.buildWeatherGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    final colors = _getThemeColors();

    if (weatherData == null || weatherData!['weather'] == null)
      return Container();

    final weather = weatherData!['weather'] as Map<String, dynamic>;

    final forecasts = [
      weather['kemarin'] ?? [],
      weather['hari_ini'] ?? [],
      weather['besok'] ?? [],
      weather['lusa'] ?? [],
      weather['hari_ke_3'] ?? [],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final dayData = forecasts[index] as List?;

            if (dayData == null || dayData.isEmpty) {
              return Column(
                children: [
                  Text(
                    '--',
                    style: TextStyle(
                      color: colors['subtitleColor'],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.help_outline,
                    color: colors['subtitleColor'],
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '--°',
                    style: TextStyle(
                      color: colors['subtitleColor'],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }

            final midDayData =
                dayData.isNotEmpty ? dayData[dayData.length ~/ 2] : null;

            final waktuStr = midDayData?['waktu'] ?? '';
            final parsedDate = DateTime.tryParse(waktuStr) ?? DateTime.now();

            final weekday =
                DateFormat.E('id_ID').format(parsedDate).toUpperCase();
            final isToday = parsedDate.day == DateTime.now().day;

            final temp = midDayData?['suhu']?.round() ?? 0;

            // Gunakan fungsi yang sudah ada
            final description = WeatherModel.getWeatherDescription({
              'weather': midDayData,
            });
            final iconPath = WeatherModel.getIconAsset(description, false);

            return Column(
              children: [
                Text(
                  weekday,
                  style: TextStyle(
                    color:
                        isToday ? colors['textColor'] : colors['subtitleColor'],
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: colors['iconColor'],
                ),
                const SizedBox(height: 8),
                Text(
                  '$temp°',
                  style: TextStyle(
                    color: colors['textColor'],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final colors = _getThemeColors();

    if (weatherData == null) return Container();

    final todayData = weatherData!['weather']['hari_ini'] as List? ?? [];
    if (todayData.isEmpty) return Container();

    // Take next 6 hours from current time
    final now = DateTime.now();
    final next6Hours =
        todayData
            .where((hourData) {
              final timeStr = hourData['waktu'] as String?;
              if (timeStr == null) return false;
              try {
                final time = DateTime.parse(timeStr);
                return time.isAfter(now) &&
                    time.isBefore(now.add(const Duration(hours: 6)));
              } catch (e) {
                return false;
              }
            })
            .take(6)
            .toList();

    if (next6Hours.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, color: colors['subtitleColor'], size: 13),
            const SizedBox(width: 4),
            Text(
              'Ramalan 6 Jam',
              style: TextStyle(color: colors['subtitleColor'], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < next6Hours.length) {
                        return Text(
                          _formatTime(next6Hours[index]['waktu']),
                          style: TextStyle(
                            color: colors['subtitleColor'],
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      next6Hours.asMap().entries.map((entry) {
                        final temp = entry.value['suhu']?.toDouble() ?? 25.0;
                        return FlSpot(entry.key.toDouble(), temp);
                      }).toList(),
                  isCurved: true,
                  color: colors['textColor'],
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: colors['textColor']!,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              minY:
                  next6Hours
                      .map((e) => (e['suhu']?.toDouble() ?? 25.0))
                      .reduce(
                        (value, element) => value < element ? value : element,
                      ) -
                  2,
              maxY:
                  next6Hours
                      .map((e) => (e['suhu']?.toDouble() ?? 25.0))
                      .reduce(
                        (value, element) => value > element ? value : element,
                      ) +
                  2,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painters
class SunPathPainter extends CustomPainter {
  final String sunrise;
  final String sunset;
  final bool isDark; // <- tambahkan parameter ini

  SunPathPainter({
    required this.sunrise,
    required this.sunset,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gunakan logika warna berdasarkan tema
    final arcColor =
        isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3);
    final fillColor =
        isDark
            ? Colors.orange.withOpacity(0.2)
            : Colors.orange.withOpacity(0.1);
    final sunColor = isDark ? Colors.orangeAccent : Colors.deepOrange;

    final paint =
        Paint()
          ..color = arcColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;

    // Draw sun path arc
    final rect = Rect.fromLTWH(
      0,
      size.height / 3,
      size.width,
      size.height / 1.5,
    );
    canvas.drawArc(rect, math.pi, math.pi, false, paint);
    canvas.drawArc(rect, math.pi, math.pi, false, fillPaint);

    // Draw current sun position (dummy)
    final sunPaint =
        Paint()
          ..color = sunColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.3), 4, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ModernCompassPainter extends CustomPainter {
  final double windDirection;
  final double windSpeed;
  final bool isDark;

  ModernCompassPainter(
    this.windDirection,
    this.windSpeed, {
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Draw dashed circle
    final dashedCirclePaint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.4)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    _drawDashedCircle(canvas, center, radius, dashedCirclePaint);

    // Draw center glow effect
    final glowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final glowRadius = math.min(size.width, size.height) * 0.25;
    final glowShader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: glowRadius));

    glowPaint.shader = glowShader;
    canvas.drawCircle(center, glowRadius, glowPaint);

    // Draw wind direction arrow
    final arrowPaint =
        Paint()
          ..color = isDark ? Colors.white : Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final angle = (windDirection - 90) * math.pi / 180;
    final arrowStart = Offset(
      center.dx - radius * 0.6 * math.cos(angle),
      center.dy - radius * 0.6 * math.sin(angle),
    );
    final arrowEnd = Offset(
      center.dx + radius * 0.6 * math.cos(angle),
      center.dy + radius * 0.6 * math.sin(angle),
    );

    canvas.drawLine(arrowStart, arrowEnd, arrowPaint);

    // Draw arrow head
    final arrowHeadPaint =
        Paint()
          ..color = isDark ? Colors.white : Colors.black
          ..style = PaintingStyle.fill;

    final arrowHeadSize = math.min(size.width, size.height) * 0.04;
    final arrowHeadAngle1 = angle + math.pi * 0.8;
    final arrowHeadAngle2 = angle - math.pi * 0.8;

    final arrowHead1 = Offset(
      arrowEnd.dx - arrowHeadSize * math.cos(arrowHeadAngle1),
      arrowEnd.dy - arrowHeadSize * math.sin(arrowHeadAngle1),
    );
    final arrowHead2 = Offset(
      arrowEnd.dx - arrowHeadSize * math.cos(arrowHeadAngle2),
      arrowEnd.dy - arrowHeadSize * math.sin(arrowHeadAngle2),
    );

    final arrowHeadPath =
        Path()
          ..moveTo(arrowEnd.dx, arrowEnd.dy)
          ..lineTo(arrowHead1.dx, arrowHead1.dy)
          ..lineTo(arrowHead2.dx, arrowHead2.dy)
          ..close();

    canvas.drawPath(arrowHeadPath, arrowHeadPaint);

    // Draw small circle at the back of arrow
    final backCirclePaint =
        Paint()
          ..color = isDark ? Colors.white : Colors.black
          ..style = PaintingStyle.fill;

    final backCircleRadius = math.min(size.width, size.height) * 0.02;
    canvas.drawCircle(arrowStart, backCircleRadius, backCirclePaint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final dashLength = 8.0;
    final dashSpace = 6.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * math.pi) / dashCount;
      final endAngle = startAngle + (dashLength / circumference) * 2 * math.pi;

      final startX = center.dx + radius * math.cos(startAngle);
      final startY = center.dy + radius * math.sin(startAngle);
      final endX = center.dx + radius * math.cos(endAngle);
      final endY = center.dy + radius * math.sin(endAngle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

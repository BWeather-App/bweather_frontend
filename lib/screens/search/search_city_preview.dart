import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/settings_provider.dart';
import 'package:flutter_cuaca/services/weather_service.dart';
import 'package:flutter_cuaca/services/favorite_service.dart';
import './widgets/weather_action_button.dart';

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
  int _selectedIndex = 1; // default: hari ini (index 1)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city = ModalRoute.of(context)?.settings.arguments as String?;
    if (city != null && city != currentCity) {
      currentCity = city;
      _selectedIndex = 1;
      fetchWeather(city);
      checkIfFavorite(city);
    }
  }

  Future<void> fetchWeather(String cityName) async {
    setState(() => _isLoading = true);

    try {
      final data = await WeatherService.instance.getWeatherByCity(cityName);
      if (mounted) {
        setState(() => weatherData = data);
      }
    } on WeatherApiException catch (e) {
      if (mounted) _showSnackBar(e.userMessage, isError: true);
    } catch (e) {
      debugPrint('Fetch weather error: $e');
      if (mounted) _showSnackBar('Gagal ambil data cuaca', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> checkIfFavorite(String fullName) async {
    final result = await FavoriteService.isFavorite(fullName);
    if (mounted) setState(() => isFavorite = result);
  }

  Future<void> addToFavorite() async {
    if (weatherData == null || currentCity == null) return;

    try {
      final location = weatherData!['location'];
      final cityData = {
        'name': location['city'] ?? currentCity,
        'full': currentCity,
        'lat': location['lat'].toString(),
        'lon': location['lon'].toString(),
      };

      final added = await FavoriteService.addFavorite(cityData);
      if (mounted) {
        if (added) {
          setState(() => isFavorite = true);
          _showSnackBar('${cityData['name']} ditambahkan ke favorit');
        } else {
          _showSnackBar('Favorit penuh (maks ${FavoriteService.maxFavorites} kota)', isError: true);
        }
      }
    } catch (e) {
      debugPrint("Error adding to favorite: $e");
      if (mounted) _showSnackBar('Gagal menambahkan ke favorit', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: isDark ? Colors.white : AppColors.darkBackground,
              size: 18,
            ),
            const SizedBox(width: AppDimensions.spaceS),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.searchInput(context),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        backgroundColor: isError
            ? (isDark ? Colors.red.shade900 : Colors.red.shade100)
            : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(AppDimensions.spaceL),
      ),
    );
  }

  List<Map<String, dynamic>> _buildForecastItems() {
    final weather = weatherData!['weather'];
    final keys = ['kemarin', 'hari_ini', 'besok', 'lusa', 'hari_ke_3'];
    final result = <Map<String, dynamic>>[];

    for (final key in keys) {
      final dayData = weather[key] as List?;
      if (dayData == null || dayData.isEmpty) continue;

      final midDay = dayData[dayData.length ~/ 2];
      final waktuStr = midDay?['waktu'] ?? '';
      final parsed = DateTime.tryParse(waktuStr) ?? DateTime.now();
      final label = DateFormat.E('id_ID').format(parsed).toUpperCase();
      final tanggal = DateFormat('dd/MM').format(parsed);
      final suhu = (midDay?['suhu'] as num?)?.toDouble() ?? 0;
      final description = WeatherIcons.getDescriptionFromMap({
        'weather': midDay,
      });

      result.add({
        'label': label,
        'tanggal': tanggal,
        'suhu': suhu,
        'description': description,
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    List<Map<String, dynamic>> forecastItems = [];
    List<double> suhuList = [];

    if (weatherData != null) {
      forecastItems = _buildForecastItems();
      suhuList = forecastItems.map((e) => (e['suhu'] as num).toDouble()).toList();
    }

    if (_selectedIndex >= forecastItems.length) _selectedIndex = 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          currentCity ?? "",
          style: AppTextStyles.locationCity(context),
        ),
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: textPrimary))
          : weatherData == null
              ? Center(
                  child: Text(
                    "Tidak ada data",
                    style: AppTextStyles.cardDescription(context),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppDimensions.cardPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.spaceL),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 320,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground(context),
                              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                              border: Border.all(color: AppColors.cardBorder(context)),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceL,
                              vertical: AppDimensions.spaceXL,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildDayRow(context, forecastItems, isDark, textPrimary, textSecondary, settings),
                                const SizedBox(height: AppDimensions.spaceXL),
                                Expanded(
                                  child: _buildChart(context, forecastItems, suhuList, textPrimary, settings),
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

  Widget _buildDayRow(
    BuildContext context,
    List<Map<String, dynamic>> items,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    SettingsProvider settings,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isToday = index == 1;
        final isSelected = index == _selectedIndex;
        final iconPath = WeatherIcons.getAsset(
          item['description'] as String,
          isDark: isDark,
        );

        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: SizedBox(
            width: 56,
            child: Column(
              children: [
                Text(
                  item['label'] as String,
                  style: AppTextStyles.forecastDay(context).copyWith(
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isToday || isSelected ? textPrimary : textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  item['tanggal'] as String,
                  style: AppTextStyles.forecastDay(context).copyWith(
                    color: isSelected ? textPrimary : textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Image.asset(
                  iconPath,
                  width: AppDimensions.iconWeatherForecast,
                  height: AppDimensions.iconWeatherForecast,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  "${settings.convertTemp(item['suhu'] as num).round()}°",
                  style: AppTextStyles.forecastTemp(context).copyWith(
                    color: isSelected ? textPrimary : textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<Map<String, dynamic>> items,
    List<double> suhuList,
    Color textPrimary,
    SettingsProvider settings,
  ) {
    if (items.length < 2) {
      return Center(
        child: Text("Grafik tidak tersedia", style: AppTextStyles.cardDescription(context)),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final curveColor = isDark ? Colors.white : AppColors.darkBackground;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final step = w / (items.length - 1);
        final minT = suhuList.reduce((a, b) => a < b ? a : b) - 2;
        final maxT = suhuList.reduce((a, b) => a > b ? a : b) + 2;

        double yForTemp(double t) {
          if (maxT == minT) return h / 2;
          return 10 + (h - 20) * (1 - (t - minT) / (maxT - minT));
        }

        final points = List.generate(
          items.length,
          (i) => Offset(i * step, yForTemp(suhuList[i])),
        );

        return GestureDetector(
          onTapUp: (details) {
            final x = details.localPosition.dx;
            int nearest = 0;
            double minDist = double.infinity;
            for (int i = 0; i < points.length; i++) {
              final dist = (points[i].dx - x).abs();
              if (dist < minDist) {
                minDist = dist;
                nearest = i;
              }
            }
            setState(() => _selectedIndex = nearest);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(w, h),
                painter: _ForecastLinePainter(
                  points: points,
                  selectedIndex: _selectedIndex,
                  curveColor: curveColor,
                ),
              ),
              // Temperature label di atas titik terpilih
              if (_selectedIndex < items.length)
                Positioned(
                  left: points[_selectedIndex].dx - 22,
                  top: points[_selectedIndex].dy - 40,
                  width: 44,
                  child: Text(
                    '${settings.convertTemp(suhuList[_selectedIndex]).round()}${settings.unitSymbol}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardValue(context).copyWith(fontSize: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ForecastLinePainter extends CustomPainter {
  final List<Offset> points;
  final int selectedIndex;
  final Color curveColor;

  _ForecastLinePainter({
    required this.points,
    required this.selectedIndex,
    required this.curveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Smooth curve
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final mid = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = curveColor.withValues(alpha: 0.6)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw dots
    for (int i = 0; i < points.length; i++) {
      if (i == selectedIndex) {
        canvas.drawCircle(
          points[i], 6,
          Paint()..color = curveColor.withValues(alpha: 0.15)..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          points[i], 6,
          Paint()..color = curveColor..strokeWidth = 2..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawCircle(
          points[i], 3,
          Paint()..color = curveColor.withValues(alpha: 0.4)..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ForecastLinePainter old) =>
      old.selectedIndex != selectedIndex || old.curveColor != curveColor;
}

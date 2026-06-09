// lib/screens/home/widgets/favorite_weather_view.dart
//
// Tampilan cuaca untuk kota favorit.
// Diekstrak dari fungsi buildFavoriteWeatherView() di weather_home.dart
// yang sebelumnya adalah top-level function (bukan widget class).
//
// PERUBAHAN:
//   ❌ Sebelum: top-level function, terima isLight/textColor/cardColor sebagai param
//   ❌ Sebelum: WeatherModel.getIconAsset() & getWeatherDescription() langsung
//   ✅ Sesudah: StatelessWidget, ambil warna dari AppColors
//   ✅ Sesudah: WeatherIcons dari constants

import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'weather_detail_sheet.dart';
import 'weather_main_view.dart';

class FavoriteWeatherView extends StatelessWidget {
  final Map<String, dynamic> cityWeather;
  final bool isDarkMode;

  const FavoriteWeatherView({
    Key? key,
    required this.cityWeather,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weather = cityWeather['weather'] ?? {};
    final current = weather['cuaca_saat_ini'] ?? {};
    final cityInfo = cityWeather['city_info'] ?? {};

    // Data kosong
    if (current.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.textPrimary(context),
              size: 48,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Data cuaca tidak tersedia',
              style: AppTextStyles.emptyTitle(context),
            ),
            Text(
              'untuk ${cityInfo['full'] ?? 'kota favorit'}',
              style: AppTextStyles.emptySubtitle(context),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        WeatherMainView(weather: current, isDarkMode: isDarkMode),

        // Detail sheet
        DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.25,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return WeatherDetailSheet(
              scrollController: scrollController,
              weatherData: cityWeather,
              isLight: !isDarkMode,
              cardColor: AppColors.cardBackgroundHome(context),
            );
          },
        ),
      ],
    );
  }
}

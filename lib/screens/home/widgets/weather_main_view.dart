import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/settings_provider.dart';

class WeatherMainView extends StatelessWidget {
  final Map<String, dynamic> weather;
  final bool isDarkMode;

  const WeatherMainView({
    Key? key,
    required this.weather,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final description = WeatherIcons.getDescriptionFromMap(weather);
    final iconPath = WeatherIcons.getAsset(description, isDark: isDarkMode);
    final suhu = settings.convertTemp(weather['suhu'] ?? 0).round();
    final angin = weather['kecepatan_angin'] ?? '-';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon cuaca
          Image.asset(
            iconPath,
            width: AppDimensions.iconWeatherMain,
            height: AppDimensions.iconWeatherMainHeight,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppDimensions.spaceS),

          // Suhu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$suhu', style: AppTextStyles.temperatureLarge(context)),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  settings.unitSymbol,
                  style: AppTextStyles.temperatureUnit(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceS),

          // Deskripsi cuaca
          Text(
            description,
            style: AppTextStyles.weatherDescription(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceXL),

          // Info angin
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: AppColors.textPrimary(context),
                size: AppDimensions.iconInfo,
              ),
              const SizedBox(width: AppDimensions.spaceS),
              Text('Angin', style: AppTextStyles.infoRow(context)),
              const SizedBox(width: AppDimensions.spaceS),
              Text('$angin m/s', style: AppTextStyles.infoRow(context)),
            ],
          ),
        ],
      ),
    );
  }
}

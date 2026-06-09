// lib/screens/home/widgets/weekly_forecast_row.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/settings_provider.dart';
import 'package:intl/intl.dart';

class WeeklyForecastRow extends StatelessWidget {
  final Map<String, dynamic>? weather;

  const WeeklyForecastRow({Key? key, this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weather == null) return const SizedBox.shrink();
    final settings = context.watch<SettingsProvider>();

    final forecasts = [
      weather!['kemarin'] ?? [],
      weather!['hari_ini'] ?? [],
      weather!['besok'] ?? [],
      weather!['lusa'] ?? [],
      weather!['hari_ke_3'] ?? [],
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final dayData = forecasts[index] as List?;

        if (dayData == null || dayData.isEmpty) {
          return Column(
            children: [
              Text('--', style: AppTextStyles.forecastDay(context)),
              const SizedBox(height: AppDimensions.spaceS),
              Icon(
                Icons.help_outline,
                color: AppColors.textSecondary(context),
                size: 24,
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Text('--${settings.unitSymbol}', style: AppTextStyles.forecastTemp(context)),
            ],
          );
        }

        final midDayData = dayData[dayData.length ~/ 2];
        final waktuStr = midDayData?['waktu'] ?? '';
        final parsedDate = DateTime.tryParse(waktuStr) ?? DateTime.now();
        final weekday = DateFormat.E('id_ID').format(parsedDate).toUpperCase();
        final isToday = parsedDate.day == DateTime.now().day;
        final temp = settings.convertTemp(midDayData?['suhu'] ?? 0).round();
        final description = WeatherIcons.getDescriptionFromMap({
          'weather': midDayData,
        });
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final iconPath = WeatherIcons.getAsset(description, isDark: isDark);

        return Column(
          children: [
            Text(
              weekday,
              style:
                  isToday
                      ? AppTextStyles.forecastDayToday(context)
                      : AppTextStyles.forecastDay(context),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Image.asset(
              iconPath,
              width: AppDimensions.iconWeatherForecast,
              height: AppDimensions.iconWeatherForecast,
              fit: BoxFit.contain,
              color: AppColors.icon(context),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text('$temp${settings.unitSymbol}', style: AppTextStyles.forecastTemp(context)),
          ],
        );
      }),
    );
  }
}

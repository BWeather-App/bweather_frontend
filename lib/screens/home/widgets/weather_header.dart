import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/settings_provider.dart';

class WeatherHeader extends StatelessWidget {
  final Map<String, dynamic>? location;
  final bool isLight;
  final VoidCallback onAddCity;
  final VoidCallback onToggleTheme;

  const WeatherHeader({
    super.key,
    required this.location,
    required this.isLight,
    required this.onAddCity,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.headerPaddingH,
        vertical: AppDimensions.headerPaddingV,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.add, color: AppColors.icon(context)),
              onPressed: onAddCity,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location?['city'] != null && location?['region'] != null
                    ? "${location!['city']}, ${location!['region']}"
                    : "Memuat lokasi...",
                style: AppTextStyles.locationCity(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceXS),
              Text(
                location?['country']?.toUpperCase() ?? "",
                style: AppTextStyles.locationCountry(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isLight ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.icon(context),
                  ),
                  onPressed: onToggleTheme,
                ),
                GestureDetector(
                  onTap: () => settings.toggleUnit(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.cardBackground(context),
                      border: Border.all(color: AppColors.cardBorder(context)),
                    ),
                    child: Text(
                      settings.unitSymbol,
                      style: AppTextStyles.forecastDay(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'dart:ui';

import 'uv_index_card.dart';
import 'feels_like_card.dart';
import 'sun_path_card.dart';
import 'humidity_card.dart';
import 'wind_direction_card.dart';
import 'rain_chance_card.dart';
import 'weekly_forecast_row.dart';
import 'hourly_forecast_chart.dart';

class WeatherDetailSheet extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, dynamic>? weatherData;
  final bool isLight;
  final Color cardColor;

  const WeatherDetailSheet({
    Key? key,
    required this.scrollController,
    required this.weatherData,
    required this.isLight,
    required this.cardColor,
  }) : super(key: key);

  Map<String, dynamic>? get _current =>
      weatherData?['weather']?['cuaca_saat_ini'];

  Map<String, dynamic>? get _weather =>
      weatherData?['weather'] as Map<String, dynamic>?;

  List? get _todayData => _weather?['hari_ini'] as List?;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.cardPadding,
            vertical: AppDimensions.spaceL,
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
        Center(
          child: Icon(Icons.keyboard_arrow_up, color: AppColors.icon(context)),
        ),
        const SizedBox(height: AppDimensions.cardPadding),

        WeeklyForecastRow(weather: _weather),
        const SizedBox(height: AppDimensions.spaceL),

        HourlyForecastChart(todayData: _todayData),
        const SizedBox(height: AppDimensions.spaceL),

        _buildWeatherGrid(),
      ],
    );
  }

  Widget _buildWeatherGrid() {
    return Column(
      children: [
        SizedBox(
          height: AppDimensions.cardRowHeight,
          child: Row(
            children: [
              Expanded(child: UvIndexCard(current: _current)),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(child: FeelsLikeCard(current: _current)),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceS),
        SizedBox(
          height: AppDimensions.cardRowHeight,
          child: Row(
            children: [
              Expanded(child: SunPathCard(todayData: _todayData)),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(child: HumidityCard(current: _current)),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceS),
        SizedBox(
          height: AppDimensions.cardRowHeight,
          child: Row(
            children: [
              Expanded(child: WindDirectionCard(current: _current)),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(child: RainChanceCard(current: _current)),
            ],
          ),
        ),
      ],
    );
  }
}

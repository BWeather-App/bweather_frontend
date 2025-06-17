// weather_detail_sheet.dart
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_cuaca/route.dart';
import 'dart:ui';

class WeatherDetailSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> forecastList;
  final Map<String, dynamic> current;
  final bool isLight;
  final Color cardColor;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(String?) formatTime;
  final String Function(dynamic, bool) getIconAsset;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ListView(
            controller: scrollController,
            children: const [
              Center(
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white70),
              ),
              SizedBox(height: 16),
              // WeeklyForecast(),
              
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

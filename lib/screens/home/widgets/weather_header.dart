// weather_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class WeatherHeader extends StatelessWidget {
  final Map<String, dynamic> weather;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(dynamic, bool) getIconAsset;
  final bool isLight;

  const WeatherHeader({
    super.key,
    required this.weather,
    required this.getWeatherDescription,
    required this.getIconAsset,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final mainCondition = weather['main'] ?? WeatherModel.getWeatherDescription(weather);

    return Column(
      children: [
        const SizedBox(height: 30),
        Image.asset(
          WeatherModel.getIconAsset(mainCondition, !isLight),
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${(weather['suhu'] ?? 0).round()}",
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
          WeatherModel.getWeatherDescription((weather)),
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
              "${weather['kecepatan_angin'] ?? '-'} m/s",
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

Widget buildFavoriteWeatherView(
  Map<String, dynamic> cityWeather, {
  required bool isLight,
  required Color textColor,
  required Color cardColor,
  required String Function(int) formatTimeFromTimestamp,
}) {
  final current = cityWeather['current'] ?? {};
  final cuacaSaatIni = current['cuaca_saat_ini'] ?? {};
  final suhu = cuacaSaatIni['suhu'];
  final kecepatanAngin = cuacaSaatIni['kecepatan_angin'];

  final description = WeatherModel.getWeatherDescription(cityWeather);
  final mainCondition = cityWeather['main'] ?? description;

  return SizedBox.expand(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: SingleChildScrollView(
          // ✅ Jaga supaya aman overflow dan tidak bentrok gesture
          physics:
              const NeverScrollableScrollPhysics(), // ✅ Supaya nggak ganggu PageView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mainCondition != null)
                Image.asset(
                  WeatherModel.getIconAsset(mainCondition, !isLight),
                  width: 80,
                  height: 70,
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suhu != null ? "${(suhu as num).round()}" : "--",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "°C",
                      style: TextStyle(color: textColor, fontSize: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: textColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.air, color: textColor, size: 24),
                  const SizedBox(width: 8),
                  Text("Angin", style: TextStyle(color: textColor)),
                  const SizedBox(width: 8),
                  Text(
                    kecepatanAngin != null ? "$kecepatanAngin m/s" : "- m/s",
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

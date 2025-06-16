// widgets/weekly_forecast.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_cuaca/route.dart';

class WeeklyForecast extends StatelessWidget {
  final List<Map<String, dynamic>> forecastList;
  final bool isLight;
  final String Function(Map<String, dynamic>) getWeatherDescription;
  final String Function(dynamic, bool) getIconAsset;

  const WeeklyForecast({
    super.key,
    required this.forecastList,
    required this.isLight,
    required this.getWeatherDescription,
    required this.getIconAsset,
  });

  @override
  Widget build(BuildContext context) {
    final _ = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white70;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            forecastList.map<Widget>((day) {
              final time =
                  DateTime.tryParse(day['waktu'] ?? '') ?? DateTime.now();
              final weekday = DateFormat.E('id_ID').format(time).toUpperCase();
              final temp = "${(day['suhu'] ?? 0).round()}°";
              final condition = day['main'] ?? getWeatherDescription(day);
              final icon = getIconAsset(condition, !isLight);
              final isToday = DateTime.now().day == time.day;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      color: isToday ? Colors.white : subTextColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Image.asset(icon, width: 28, height: 28),
                  const SizedBox(height: 4),
                  Text(
                    temp,
                    style: TextStyle(
                      color: isToday ? Colors.white : subTextColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class _WeatherDay extends StatefulWidget {
  final Widget iconWidget;
  final String day;
  final String temp;
  final bool selected;
  final bool isLight;

  const _WeatherDay({
    required this.iconWidget,
    required this.day,
    required this.temp,
    required this.selected,
    required this.isLight,
  });

  @override
  State<_WeatherDay> createState() => _WeatherDayState();
}

class _WeatherDayState extends State<_WeatherDay> {
  @override
  Widget build(BuildContext context) {
    final textColor = widget.isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = widget.isLight ? Colors.black54 : Colors.white70;

    return Column(
      children: [
        Text(
          widget.day,
          style: TextStyle(
            color: widget.selected ? textColor : subTextColor,
            fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        widget.iconWidget,
        const SizedBox(height: 4),
        Text(
          widget.temp,
          style: TextStyle(
            color: widget.selected ? textColor : subTextColor,
            fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

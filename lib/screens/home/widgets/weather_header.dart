import 'package:flutter/material.dart';

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
    final Color iconColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final textColor = iconColor;
    final Color subTextColor = isLight ? Colors.black54 : Colors.white54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.add, color: iconColor),
                onPressed: onAddCity,
              ),
              Text(
                location?['name'] ?? "Memuat lokasi...",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location?['country'] ?? "",
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: Icon(
                  isLight ? Icons.dark_mode : Icons.light_mode,
                  color: iconColor,
                ),
                onPressed: onToggleTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

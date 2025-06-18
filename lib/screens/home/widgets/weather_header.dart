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

    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Row(
    //         children: [
    //           IconButton(
    //             icon: Icon(Icons.add, color: iconColor),
    //             onPressed: onAddCity,
    //           ),
    //           Text(
    //             location?['name'] ?? "Memuat lokasi...",
    //             style: TextStyle(
    //               color: textColor,
    //               fontWeight: FontWeight.bold,
    //               fontSize: 16,
    //             ),
    //           ),
    //           const SizedBox(height: 2),
    //           Text(
    //             location?['country'] ?? "",
    //             style: TextStyle(
    //               color: subTextColor,
    //               fontSize: 10,
    //               letterSpacing: 2,
    //             ),
    //           ),
    //           IconButton(
    //             icon: Icon(
    //               isLight ? Icons.dark_mode : Icons.light_mode,
    //               color: iconColor,
    //             ),
    //             onPressed: onToggleTheme,
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Add City button (kiri)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.add, color: iconColor),
              onPressed: onAddCity,
            ),
          ),

          // Lokasi di tengah
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location?['city'] != null && location?['region'] != null
                    ? "${location?['city']}, ${location?['region']}"
                    : "Memuat lokasi...",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                location?['country']?.toUpperCase() ?? "",
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          // Toggle Theme button (kanan)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                isLight ? Icons.dark_mode : Icons.light_mode,
                color: iconColor,
              ),
              onPressed: onToggleTheme,
            ),
          ),
        ],
      ),
    );
  }
}

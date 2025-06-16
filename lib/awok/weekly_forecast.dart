import 'package:flutter/material.dart';

class WeeklyForecast extends StatelessWidget {
  final int selectedIndex;

  const WeeklyForecast({Key? key, this.selectedIndex = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> weeklyData = [
      {'day': 'SEN', 'icon': Icons.water_drop, 'temp': 27},
      {'day': 'SEL', 'icon': Icons.wb_cloudy, 'temp': 28},
      {'day': 'RAB', 'icon': Icons.flash_on, 'temp': 15},
      {'day': 'KAM', 'icon': Icons.wb_sunny, 'temp': 23},
      {'day': 'JUM', 'icon': Icons.cloud, 'temp': 25},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weeklyData.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final item = weeklyData[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['day'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(item['icon'], color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  '${item['temp']}°',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSelected ? 20 : 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
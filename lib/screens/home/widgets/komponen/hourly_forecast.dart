import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const HourlyForecast({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF323247),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ramalan 24 Jam", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final hour = data[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(hour['time'], style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 4),
                      Icon(Icons.nightlight, color: Colors.white),
                      const SizedBox(height: 4),
                      Text('${hour['temp']}°', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
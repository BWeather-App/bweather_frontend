// weather_info_grid.dart
import 'package:flutter/material.dart';
import 'sun_path_chart.dart';

class WeatherInfoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String value;
  final String subtitle;

  const WeatherInfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 32,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class WeatherInfoGrid extends StatelessWidget {
  const WeatherInfoGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const WeatherInfoCard(
          icon: Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 28),
          title: "UV Index",
          value: "3",
          subtitle: "Sedang sepanjang siang",
        ),
        const WeatherInfoCard(
          icon: Icon(Icons.thermostat, color: Colors.redAccent, size: 28),
          title: "Terasa Seperti",
          value: "25°C",
          subtitle: "Suhu yang terasa di kulit",
        ),
        // Sun Path chart sebagai WeatherInfoCard
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 32,
          child: const WeatherInfoCard(
            icon: SizedBox(height: 60, child: SunPathChart()),
            title: "",
            value: "",
            subtitle: "Sunrise",
          ),
        ),
        const WeatherInfoCard(
          icon: Icon(Icons.water_drop, color: Colors.blueAccent, size: 28),
          title: "Kelembapan",
          value: "58%",
          subtitle: "Semakin tinggi, makin lembap terasa",
        ),
        const WeatherInfoCard(
          icon: Icon(Icons.navigation, color: Colors.greenAccent, size: 28),
          title: "Arah Angin",
          value: "U",
          subtitle: "Angin dari Utara",
        ),
        const WeatherInfoCard(
          icon: Icon(Icons.cloud_queue, color: Colors.cyan, size: 28),
          title: "Peluang Hujan",
          value: "76%",
          subtitle: "Kemungkinan hujan ringan",
        ),
      ],
    );
  }
}

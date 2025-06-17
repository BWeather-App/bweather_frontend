import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class TemperatureCard extends StatelessWidget {
  final int temp;
  const TemperatureCard({super.key, required this.temp});

  @override
  Widget build(BuildContext context) {
    return InfoCardComponent(
      icon: Icons.thermostat,
      label: "Terasa Seperti",
      value: temp.toString(),
      unit: "°C",
      subtitle: "Suhu yang terasa oleh tubuh. Bukan suhu sebenarnya.",
    );
  }
}
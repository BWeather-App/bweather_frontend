import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class WindDirectionCard extends StatelessWidget {
  final String direction;
  final int speed;
  const WindDirectionCard({super.key, required this.direction, required this.speed});

  @override
  Widget build(BuildContext context) {
    return InfoCardComponent(
      icon: Icons.explore,
      label: "Arah Angin",
      value: speed.toString(),
      unit: "km/j",
      subtitle: "Berdasarkan kompas: $direction",
    );
  }
}
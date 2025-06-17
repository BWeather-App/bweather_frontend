import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class ChanceOfRainCard extends StatelessWidget {
  final int percent;
  const ChanceOfRainCard({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return InfoCardComponent(
      icon: Icons.umbrella_outlined,
      label: "Peluang Hujan",
      value: percent.toString(),
      unit: "%",
      subtitle: "Kemungkinan turun hujan.",
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class HumidityCard extends StatelessWidget {
  final int value;
  const HumidityCard({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return InfoCardComponent(
      icon: Icons.water_drop_outlined,
      label: "Kelembaban",
      value: value.toString(),
      unit: "%",
      subtitle: "Persentase uap air di udara.",
    );
  }
}
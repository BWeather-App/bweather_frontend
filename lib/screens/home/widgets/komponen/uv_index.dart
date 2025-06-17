import 'package:flutter/material.dart';
import 'package:flutter_cuaca/route.dart';

class UVIndexCard extends StatelessWidget {
  final int value;
  const UVIndexCard({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return InfoCardComponent(
      icon: Icons.wb_sunny_outlined,
      label: "UV Index",
      value: value.toString(),
      unit: "Sedang",
      subtitle: "Sedang sepanjang hari ini.",
    );
  }
}

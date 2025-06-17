import 'package:flutter/material.dart';

class WeatherActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const WeatherActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          icon: Icon(icon, color: Colors.white),
          label: const Text(""), // kosong karena hanya pakai ikon
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
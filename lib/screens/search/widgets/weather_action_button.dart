import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';

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
        Ink(
          decoration: const ShapeDecoration(
            color: AppColors.actionButton,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: AppColors.icon(context)),
            onPressed: onPressed,
            iconSize: 28,
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceS),
        Text(label, style: TextStyle(color: AppColors.textPrimary(context))),
      ],
    );
  }
}
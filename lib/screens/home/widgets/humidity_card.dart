// lib/screens/home/widgets/humidity_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';

class HumidityCard extends StatelessWidget {
  final Map<String, dynamic>? current;

  const HumidityCard({Key? key, this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final humidity = current?['kelembapan']?.round() ?? 87;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.cardBorder(context),
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: AppColors.icon(context),
                size: AppDimensions.iconCard,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text('Kelembaban', style: AppTextStyles.cardLabel(context)),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text('$humidity%', style: AppTextStyles.cardValue(context)),
          const Spacer(),
          Text(
            humidity > 70
                ? 'Kelembaban tinggi,\nterasa lebih panas'
                : 'Kelembaban dalam\nkondisi normal',
            style: AppTextStyles.cardDescription(context),
          ),
        ],
      ),
    );
  }
}

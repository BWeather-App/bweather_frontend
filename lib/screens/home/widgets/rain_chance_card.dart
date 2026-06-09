// lib/screens/home/widgets/rain_chance_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';

class RainChanceCard extends StatelessWidget {
  final Map<String, dynamic>? current;

  const RainChanceCard({Key? key, this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rainChance = current?['peluang_hujan']?.round() ?? 74;

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
                Icons.umbrella_outlined,
                color: AppColors.icon(context),
                size: AppDimensions.iconCard,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text(
                'Kemungkinan Hujan',
                style: AppTextStyles.cardLabel(context),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text('$rainChance%', style: AppTextStyles.cardValue(context)),
          const Spacer(),
          Text(
            rainChance > 70
                ? 'Kemungkinan besar\nhujan, bawa payung'
                : rainChance > 30
                ? 'Kemungkinan hujan\nringan'
                : 'Kemungkinan kecil\nhujan',
            style: AppTextStyles.cardDescription(context),
          ),
        ],
      ),
    );
  }
}

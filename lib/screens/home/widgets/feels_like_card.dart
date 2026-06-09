// lib/screens/home/widgets/feels_like_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/settings_provider.dart';

class FeelsLikeCard extends StatelessWidget {
  final Map<String, dynamic>? current;

  const FeelsLikeCard({Key? key, this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final feelsLike = settings.convertTemp(current?['terasa_seperti'] ?? 26).round();

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
                Icons.thermostat_outlined,
                color: AppColors.icon(context),
                size: AppDimensions.iconCard,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text('Terasa Seperti', style: AppTextStyles.cardLabel(context)),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text('$feelsLike${settings.unitSymbol}', style: AppTextStyles.cardValue(context)),
          const Spacer(),
          Text(
            'Suhu yang dirasakan\ndengan faktor angin',
            style: AppTextStyles.cardDescription(context),
          ),
        ],
      ),
    );
  }
}

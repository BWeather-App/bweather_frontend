// lib/screens/home/widgets/sun_path_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/helpers/time_helper.dart';
import 'painters/sun_path_painter.dart';

class SunPathCard extends StatelessWidget {
  final List? todayData;

  const SunPathCard({Key? key, this.todayData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String sunrise = '05:46';
    String sunset = '17:27';

    if (todayData != null && todayData!.isNotEmpty) {
      sunrise = TimeHelper.formatFromString(
        todayData!.first['matahari_terbit'],
      );
      sunset = TimeHelper.formatFromString(
        todayData!.first['matahari_terbenam'],
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.wb_twilight,
                color: AppColors.icon(context),
                size: AppDimensions.iconCard,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text('Jalur Matahari', style: AppTextStyles.cardLabel(context)),
            ],
          ),

          // ── Canvas kurva matahari ────────────────────────────────────────
          // Diberi lebih banyak ruang (Expanded) agar proporsional seperti Figma
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spaceS,
              ),
              child: CustomPaint(
                painter: SunPathPainter(
                  sunrise: sunrise,
                  sunset: sunset,
                  isDark: isDark,
                ),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),

          // ── Teks bawah: hanya "Sunrise XX.XX" seperti Figma ─────────────
          Text(
            'Sunrise $sunrise',
            style: AppTextStyles.cardDescription(context),
          ),
        ],
      ),
    );
  }
}

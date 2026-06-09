// lib/screens/home/widgets/uv_index_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';

class UvIndexCard extends StatelessWidget {
  final Map<String, dynamic>? current;

  const UvIndexCard({Key? key, this.current}) : super(key: key);

  String _getUVDescription(double uv) {
    if (uv < 3) return 'Rendah';
    if (uv < 6) return 'Sedang';
    if (uv < 8) return 'Tinggi';
    if (uv < 11) return 'Sangat Tinggi';
    return 'Ekstrem';
  }

  String _getUVAdvice(double uv) {
    if (uv < 3) return 'Aman untuk beraktivitas';
    if (uv < 6) return 'Sedang sepanjang hari';
    if (uv < 8) return 'Gunakan pelindung';
    return 'Hindari paparan langsung';
  }

  double _getIndicatorPosition(double uv) {
    if (uv <= 2) return uv / 10.0;
    if (uv <= 5) return 0.2 + ((uv - 2) / 10.0);
    if (uv <= 7) return 0.5 + ((uv - 5) / 10.0);
    if (uv <= 10) return 0.7 + ((uv - 7) / 10.0);
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final uvIndex = current?['indeks_uv']?.toDouble() ?? 2.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotFill = isDark ? Colors.white : AppColors.darkBackground;
    final dotBorder = isDark ? Colors.white70 : Colors.black54;

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
          // Label
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: AppColors.icon(context),
                size: AppDimensions.iconCard,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text('UV Index', style: AppTextStyles.cardLabel(context)),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Nilai
          Text(
            uvIndex.round().toString(),
            style: AppTextStyles.cardValue(context),
          ),
          const SizedBox(height: AppDimensions.spaceXS),

          // Level
          Text(
            _getUVDescription(uvIndex),
            style: AppTextStyles.cardLabel(context),
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Gradient bar
          SizedBox(
            height: 18,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final indicatorPos =
                    _getIndicatorPosition(uvIndex) * constraints.maxWidth;
                return Stack(
                  children: [
                    Positioned(
                      top: 7,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: AppColors.uvGradient,
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: indicatorPos - 9,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: dotFill,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dotBorder,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          const Spacer(),

          // Saran
          Text(
            _getUVAdvice(uvIndex),
            style: AppTextStyles.cardDescription(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

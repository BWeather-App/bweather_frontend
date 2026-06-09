// lib/screens/home/widgets/wind_direction_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'dart:math' as math;

class WindDirectionCard extends StatelessWidget {
  final Map<String, dynamic>? current;

  const WindDirectionCard({Key? key, this.current}) : super(key: key);

  String _getWindDirectionText(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'U';
    if (degrees >= 22.5 && degrees < 67.5) return 'TL';
    if (degrees >= 67.5 && degrees < 112.5) return 'T';
    if (degrees >= 112.5 && degrees < 157.5) return 'TG';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'BD';
    if (degrees >= 247.5 && degrees < 292.5) return 'B';
    if (degrees >= 292.5 && degrees < 337.5) return 'BL';
    return 'S';
  }

  @override
  Widget build(BuildContext context) {
    final windDirection = current?['arah_angin']?.toDouble() ?? 180.0;
    final windSpeed = current?['kecepatan_angin']?.toDouble() ?? 18.0;
    final dirText = _getWindDirectionText(windDirection);
    final double compassSize = AppDimensions.compassSize;

    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeFolder = isDark ? 'dark' : 'light';

    // Konversi arah angin ke radian.
    final double arrowRadian = windDirection * (math.pi / 180);

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
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.air,
                color: AppColors.icon(context),
                size: AppDimensions.iconCard,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text('Arah Angin', style: AppTextStyles.cardLabel(context)),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // ── Kompas Menggunakan Stack ──────────────────────────────
          Expanded(
            child: Center(
              child: SizedBox(
                width: compassSize,
                height: compassSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // LAYER 1: Lingkaran Putus-putus
                    SvgPicture.asset(
                      'assets/icons/$themeFolder/Ellipse 17.svg',
                      width: compassSize,
                      height: compassSize,
                      fit: BoxFit.contain,
                    ),

                    // LAYER 2: Label U, T, S, B — mepet ke dalam Ellipse 17
                    Align(
                      alignment: const Alignment(0, -0.94), // U — atas
                      child: Text(
                        'U',
                        style: AppTextStyles.compassDirection(context),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.94), // S — bawah
                      child: Text(
                        'S',
                        style: AppTextStyles.compassDirection(context),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.72, 0), // T — kanan
                      child: Text(
                        'T',
                        style: AppTextStyles.compassDirection(context),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.72, 0), // B — kiri
                      child: Text(
                        'B',
                        style: AppTextStyles.compassDirection(context),
                      ),
                    ),

                    // LAYER 3: Panah Arah (di belakang Ellipse 18)
                    Transform.rotate(
                      angle: arrowRadian,
                      child: SvgPicture.asset(
                        'assets/icons/$themeFolder/Arrow 1.svg',
                        width: compassSize,
                        height: compassSize,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // LAYER 4: Ellipse 18 — inner circle (di depan arrow, alas angka)
                    SvgPicture.asset(
                      'assets/icons/$themeFolder/Ellipse 18.svg',
                      width: compassSize * 0.40,
                      height: compassSize * 0.40,
                      fit: BoxFit.contain,
                    ),

                    // LAYER 5: Teks Angka Kecepatan (Paling depan, pas di tengah Ellipse 18)
                    SizedBox(
                      width: compassSize * 0.40,
                      height: compassSize * 0.40,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${windSpeed.round()}',
                              style: AppTextStyles.windSpeed(context).copyWith(
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -6),
                              child: Text(
                                'm/s',
                                style: AppTextStyles.windUnit(context).copyWith(
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Ringkasan arah di bawah ────────────────────────────────────
          const SizedBox(height: AppDimensions.spaceS),
          Center(
            child: Text(
              '$dirText ${windSpeed.round()} m/s',
              style: AppTextStyles.windSummary(context),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground(context),
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                color: AppColors.icon(context),
                size: 40,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Ups!',
              style: AppTextStyles.cardValue(context).copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              message,
              style: AppTextStyles.cardDescription(context).copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spaceL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXL,
                    vertical: AppDimensions.spaceM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

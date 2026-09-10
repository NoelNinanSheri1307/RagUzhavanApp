import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ApiStatusBadge extends StatelessWidget {
  final String? baseUrl;
  final bool isUsingMockFallback;
  final String? lastError;

  const ApiStatusBadge({
    super.key,
    this.baseUrl,
    this.isUsingMockFallback = false,
    this.lastError,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = baseUrl != null && baseUrl!.isNotEmpty;

    Color badgeBg;
    Color badgeBorder;
    Color textColor;
    String statusText;

    if (!hasUrl) {
      badgeBg = AppColors.primaryMuted.withValues(alpha: 0.15);
      badgeBorder = AppColors.primaryMuted.withValues(alpha: 0.5);
      textColor = AppColors.primary;
      statusText = 'PROTOTYPE DEMO MODE (LOCAL MOCK REPOSITORY)';
    } else if (isUsingMockFallback) {
      badgeBg = AppColors.warningText.withValues(alpha: 0.12);
      badgeBorder = AppColors.warningText.withValues(alpha: 0.5);
      textColor = AppColors.warningText;
      statusText = 'REMOTE API UNREACHABLE — FALLBACK MOCK ACTIVE';
    } else {
      badgeBg = AppColors.accentGreen.withValues(alpha: 0.15);
      badgeBorder = AppColors.accentGreen.withValues(alpha: 0.5);
      textColor = AppColors.accentGreen;
      statusText = 'LIVE RAG ENGINE: $baseUrl';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        border: Border.all(color: badgeBorder),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusText,
              style: AppTypography.monoCaption.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

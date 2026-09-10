import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PublicSourceBadge extends StatelessWidget {
  final String sourceKey;
  final String title;
  final String category;

  const PublicSourceBadge({
    super.key,
    required this.sourceKey,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderBright, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppColors.straw.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.straw, width: 0.8),
            ),
            child: Text(
              sourceKey.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.straw,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.paper,
                ),
              ),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 10.0,
                  color: AppColors.foregroundSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

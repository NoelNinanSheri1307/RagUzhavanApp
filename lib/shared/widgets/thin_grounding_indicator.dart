import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ThinGroundingIndicator extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final String label;

  const ThinGroundingIndicator({
    super.key,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.leaf,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'INDEX: $score / 1.00 ($pct%)',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.straw,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Thin scientific bar
          Stack(
            children: [
              Container(
                height: 3.0,
                width: double.infinity,
                color: AppColors.surfaceHighlight,
              ),
              FractionallySizedBox(
                widthFactor: score.clamp(0.0, 1.0),
                child: Container(
                  height: 3.0,
                  color: AppColors.leaf,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

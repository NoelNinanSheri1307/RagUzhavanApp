import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/evidence_source.dart';

class EvidenceDetailDialog extends StatelessWidget {
  final EvidenceSource source;

  const EvidenceDetailDialog({
    super.key,
    required this.source,
  });

  static void show(BuildContext context, EvidenceSource source) {
    showDialog(
      context: context,
      builder: (context) => EvidenceDetailDialog(source: source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted.withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.primaryMuted),
                      ),
                      child: Text(
                        source.documentType.toUpperCase(),
                        style: AppTypography.monoCaption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSecondary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Source Title
                Text(
                  source.title,
                  style: AppTypography.headingMedium.copyWith(
                    color: textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Author & Institute
                Text(
                  'Author / Institute: ${source.authorOrInstitute}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentSoil,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 16),

                // Grid of Key Evidence Metadata (4-box metadata grid)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 400;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildMetaBox(
                          label: 'PUBLICATION DATE',
                          value: source.publicationDate,
                          icon: Icons.calendar_today_outlined,
                          width: isCompact ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                        ),
                        _buildMetaBox(
                          label: 'RETRIEVED / FETCH DATE',
                          value: source.retrievedDate,
                          icon: Icons.history_outlined,
                          width: isCompact ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                        ),
                        _buildMetaBox(
                          label: 'DATA AGE / STALENESS',
                          value: '${source.datasetAgeDays} days old',
                          icon: Icons.timer_outlined,
                          width: isCompact ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                          textPrimary: source.datasetAgeDays > 120 ? AppColors.warningText : textPrimary,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                        ),
                        _buildMetaBox(
                          label: 'REGION APPLICABILITY',
                          value: source.region,
                          icon: Icons.place_outlined,
                          width: isCompact ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                        ),
                        _buildMetaBox(
                          label: 'CROP APPLICABILITY',
                          value: source.cropApplicability,
                          icon: Icons.grass_outlined,
                          width: constraints.maxWidth,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Excerpt Block
                Text(
                  'VERIFIED ADVISORY EXCERPT',
                  style: AppTypography.monoCaption.copyWith(
                    color: textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF181613) : const Color(0xFFF9F7F1),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    source.excerpt,
                    style: AppTypography.editorialBody.copyWith(
                      color: textPrimary,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (source.excerptTamil.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181613) : const Color(0xFFF9F7F1),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      source.excerptTamil,
                      style: AppTypography.editorialBody.copyWith(
                        color: textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Bottom Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          source.isVerified ? Icons.check_circle_outline : Icons.help_outline,
                          size: 16,
                          color: source.isVerified ? AppColors.accentGreen : AppColors.warningText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          source.isVerified ? 'VERIFIED PUBLIC SOURCE' : 'UNVERIFIED ENTRY',
                          style: AppTypography.monoCaption.copyWith(
                            color: source.isVerified ? AppColors.accentGreen : AppColors.warningText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Confidence Score: ${(source.confidenceScore * 100).toStringAsFixed(0)}%',
                      style: AppTypography.monoCaption.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBox({
    required String label,
    required String value,
    required IconData icon,
    required double width,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentSoil),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.monoCaption.copyWith(
                    color: textSecondary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

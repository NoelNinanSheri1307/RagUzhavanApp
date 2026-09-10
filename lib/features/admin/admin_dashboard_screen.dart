import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('adminHeader'),
        subtitle: 'District Advisory Monitoring & Research Freshness Audit',
        showBackButton: true,
        onBack: () => context.go('/farmer'),
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/admin'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAdminMetricCard(
                        title: l10n.text('registeredFarmers'),
                        value: '1,428',
                        subtext: '+32 enrolled this week',
                        color: AppColors.straw,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAdminMetricCard(
                        title: l10n.text('queriesProcessed'),
                        value: '384',
                        subtext: '88% grounded evidence rate',
                        color: AppColors.field,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAdminMetricCard(
                        title: l10n.text('outdatedDataAlerts'),
                        value: '2 Districts',
                        subtext: 'Ramanathapuram > 180 days',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                FieldNotebookCard(
                  title: 'FARMER JURISDICTION DIRECTORY',
                  subtitle: 'Inspect registered farmer records and crop allocations across districts',
                  tagText: 'DATABASE AUDIT',
                  tagColor: AppColors.leaf,
                  trailing: ElevatedButton(
                    onPressed: () => context.go('/admin/farmers'),
                    child: Text(l10n.text('navFarmers')),
                  ),
                  child: const Text(
                    'Access complete directory of enrolled farmers in Thanjavur, Coimbatore, Ramanathapuram, and Madurai districts.',
                    style: TextStyle(fontSize: 13.0, color: AppColors.foregroundMuted),
                  ),
                ),
                const SizedBox(height: 20),

                FieldNotebookCard(
                  title: 'DISTRICT RESEARCH FRESHNESS AUDIT',
                  subtitle: 'Monitoring university bulletin publication age by region',
                  tagText: 'DATA AGE MONITORS',
                  tagColor: AppColors.field,
                  child: Column(
                    children: [
                      _buildAuditRow(
                        district: 'Thanjavur (Cauvery Delta)',
                        crop: 'Paddy / Kuruvai',
                        latestBulletin: 'TNAU-CPG-2025/RICE-BLAST',
                        ageDays: 14,
                        isFresh: true,
                      ),
                      const Divider(height: 16),
                      _buildAuditRow(
                        district: 'Coimbatore (Western Zone)',
                        crop: 'Cotton / MCU-5',
                        latestBulletin: 'CICR-BULLETIN-2025/COTTON',
                        ageDays: 8,
                        isFresh: true,
                      ),
                      const Divider(height: 16),
                      _buildAuditRow(
                        district: 'Ramanathapuram (Coastal Dry)',
                        crop: 'Groundnut / TMV-7',
                        latestBulletin: 'TNAU-DRYLAND-BULLETIN-2024',
                        ageDays: 194,
                        isFresh: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminMetricCard({
    required String title,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontFootlight,
              fontSize: 24.0,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAuditRow({
    required String district,
    required String crop,
    required String latestBulletin,
    required int ageDays,
    required bool isFresh,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                district,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.paper),
              ),
              const SizedBox(height: 2),
              Text(
                '$crop · $latestBulletin',
                style: const TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isFresh ? AppColors.successBg : AppColors.errorBg,
            border: Border.all(color: isFresh ? AppColors.field : AppColors.error),
          ),
          child: Text(
            isFresh ? '$ageDays DAYS OLD' : '$ageDays DAYS (OUTDATED)',
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              color: isFresh ? AppColors.leaf : AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

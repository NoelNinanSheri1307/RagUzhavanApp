import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/public_source_badge.dart';
import '../../shared/widgets/soil_texture_painter.dart';
import '../../shared/animations/editorial_transitions.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SoilTextureBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top editorial masthead
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: AppColors.straw.withValues(alpha: 0.15),
                                border: Border.all(color: AppColors.straw, width: 1.0),
                              ),
                              child: const Text(
                                'RAG',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.straw,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'RagUzhavan',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFootlight,
                            fontSize: 22.0,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          ),
                          child: Text(l10n.text('login')),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => localeNotifier.toggleLanguage(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              border: Border.all(color: AppColors.borderBright),
                            ),
                            child: Text(
                              isTamil ? 'EN' : 'தமிழ்',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.straw,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          EditorialSlideUp(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                border: Border.all(color: AppColors.field),
                              ),
                              child: Text(
                                'TAMIL NADU REGIONAL AGRICULTURAL INTELLIGENCE'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.leaf,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          EditorialSlideUp(
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              isTamil
                                  ? 'சிதறிய விவசாயத் தகவல்களைத் துல்லியமான ஆதாரப் பரிந்துரைகளாக இணைக்கிறது'
                                  : 'Connecting Fragmented Agricultural Evidence to Practical Farmer Decisions',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFootlight,
                                fontSize: 34.0,
                                height: 1.15,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          EditorialSlideUp(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              l10n.text('landingProblemSub'),
                              style: const TextStyle(
                                fontSize: 15.0,
                                height: 1.55,
                                color: AppColors.foregroundMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Narrative Progression Steps
                          Text(
                            'PROBLEM TO SOLUTION NARRATIVE',
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.straw,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 650;
                              return Flex(
                                direction: isWide ? Axis.horizontal : Axis.vertical,
                                children: [
                                  _buildNarrativeStep(l10n.text('narrativeStep1'), 'Fragmented IMD, Mandi & Soil Cards', isWide),
                                  _buildArrow(isWide),
                                  _buildNarrativeStep(l10n.text('narrativeStep2'), 'State → District → Block Scope', isWide),
                                  _buildArrow(isWide),
                                  _buildNarrativeStep(l10n.text('narrativeStep3'), 'TNAU & ICAR Verified Bulletins', isWide),
                                  _buildArrow(isWide),
                                  _buildNarrativeStep(l10n.text('narrativeStep4'), 'Deterministic Spray & Irrigation Rules', isWide),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 30),

                          // Public Datasets Editorially Presented
                          Text(
                            l10n.text('publicSourcesTitle'),
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.straw,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              PublicSourceBadge(sourceKey: 'IMD', title: 'India Meteorological Dept', category: 'Precipitation & Humidity Telemetry'),
                              PublicSourceBadge(sourceKey: 'Agmarknet', title: 'Agricultural Marketing Net', category: 'Daily Commodity Mandi Prices'),
                              PublicSourceBadge(sourceKey: 'Soil Health', title: 'Soil Health Card Portal', category: 'NPK & pH Field Micro-Nutrients'),
                              PublicSourceBadge(sourceKey: 'data.gov.in', title: 'Open Government Data', category: 'District Crop Acreage & Yields'),
                              PublicSourceBadge(sourceKey: 'State Dept', title: 'Tamil Nadu Agri Advisories', category: 'Weekly Pest Outbreak Alerts'),
                              PublicSourceBadge(sourceKey: 'ICAR / SAU', title: 'TNAU Crop Calendars', category: 'Deterministic Extension Protocols'),
                            ],
                          ),

                          const SizedBox(height: 36),

                          // System Capabilities Overview Card
                          FieldNotebookCard(
                            title: 'REGIONAL RAG PIPELINE & EVIDENCE ENGINE',
                            subtitle: 'Verified extension literature and vector store retrieval',
                            tagText: 'SYSTEM ARCHITECTURE',
                            tagColor: AppColors.field,
                            child: const Text(
                              'RagUzhavan connects verified agricultural research bulletins from Tamil Nadu Agricultural University (TNAU) and ICAR to authenticated farmers with hands-free speech and on-device translation.',
                              style: TextStyle(fontSize: 13.0, color: AppColors.foregroundMuted, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrativeStep(String stepTitle, String sub, bool isWide) {
    final widget = Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepTitle,
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: AppColors.straw),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundMuted),
          ),
        ],
      ),
    );

    if (isWide) return Expanded(child: widget);
    return SizedBox(width: double.infinity, child: widget);
  }

  Widget _buildArrow(bool isWide) {
    if (isWide) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Icon(Icons.arrow_forward, size: 14, color: AppColors.foregroundSubtle),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Icon(Icons.arrow_downward, size: 14, color: AppColors.foregroundSubtle),
    );
  }
}


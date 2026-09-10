import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/animations/editorial_transitions.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                      Container(
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
                      const SizedBox(width: 8),
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
                            localeNotifier.languageCode == 'ta' ? 'EN' : 'தமிழ்',
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

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        EditorialSlideUp(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              border: Border.all(color: AppColors.field),
                            ),
                            child: Text(
                              'CAUVERY DELTA & TAMIL NADU REGIONAL SCOPE'.toUpperCase(),
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
                            localeNotifier.languageCode == 'ta'
                                ? 'மண்டலம் மற்றும் பருவம் சார்ந்த ஆதாரப்பூர்வ வேளாண் அறிவுத்திறன்'
                                : 'Region-Aware & Season-Grounded Agricultural Intelligence',
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
                            localeNotifier.languageCode == 'ta'
                                ? 'விவசாயிகள் தங்கள் மாவட்டம், மண் வகை மற்றும் பயிர் பருவத்திற்குரிய கேள்விகளை அமைத்து, பல்கலைக்கழக ஆராய்ச்சிகளிலிருந்து சரிபார்க்கப்பட்ட சான்றுகளுடன் துல்லியமான பதில்களைப் பெறலாம்.'
                                : 'Helping farmers ask time-sensitive agricultural questions and receive answers strictly grounded in district crop advisories, verified research bulletins, dataset freshness metrics, and zero speculative hallucinations.',
                            style: const TextStyle(
                              fontSize: 15.0,
                              height: 1.55,
                              color: AppColors.foregroundMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Action cards
                        EditorialSlideUp(
                          delay: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.go('/farmer'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(l10n.text('askQuestion')),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),
                        const Divider(),
                        const SizedBox(height: 24),

                        // 3 Architectural Highlights
                        Text(
                          'SYSTEM ARCHITECTURE & CORE CAPABILITIES',
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.straw,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            return Flex(
                              direction: isWide ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFeatureBox(
                                  title: '1. District Grounding',
                                  description:
                                      'Answers are retrieved exclusively for Thanjavur, Coimbatore, Ramanathapuram, and Madurai agro-climatic zones.',
                                  isWide: isWide,
                                ),
                                if (isWide) const SizedBox(width: 14) else const SizedBox(height: 14),
                                _buildFeatureBox(
                                  title: '2. Publication Citations',
                                  description:
                                      'Every response lists publishing institutes (TNAU, ICAR, TRRI), release dates, confidence score, and record age in days.',
                                  isWide: isWide,
                                ),
                                if (isWide) const SizedBox(width: 14) else const SizedBox(height: 14),
                                _buildFeatureBox(
                                  title: '3. Low Bandwidth SMS',
                                  description:
                                      'Built for 2G rural fields with 1.1 KB compressed packet summaries and offline sync queueing.',
                                  isWide: isWide,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 36),

                        // Scenarios Try-Out Box
                        FieldNotebookCard(
                          title: 'Demo Mock Scenarios Inspector',
                          subtitle: 'Simulate key hackathon grounding behaviors',
                          tagText: 'RAG TESTBED',
                          tagColor: AppColors.field,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select a pre-built agricultural scenario to test evidence drawers, missing-context prompts, or data staleness banners:',
                                style: TextStyle(fontSize: 13.0, color: AppColors.foregroundMuted),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => context.go('/farmer/response?scenario=grounded'),
                                    child: const Text('1. Grounded Response (Rice Blast)'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => context.go('/farmer/response?scenario=clarification'),
                                    child: const Text('2. Missing Context Prompt (Cotton)'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => context.go('/farmer/response?scenario=no_data'),
                                    child: const Text('3. No Current Data (Groundnut)'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => context.go('/farmer/response?scenario=tamil_grounded'),
                                    child: const Text('4. Tamil Grounded Response (தமிழ்)'),
                                  ),
                                ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBox({
    required String title,
    required String description,
    required bool isWide,
  }) {
    final widget = Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontFootlight,
              fontSize: 16.0,
              color: AppColors.paper,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.foregroundMuted,
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Expanded(child: widget);
    }
    return widget;
  }
}

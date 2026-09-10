import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/repositories/mock_rag_repository.dart';
import '../../data/models/field_sensor_data.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/scientific_telemetry_bar.dart';
import '../../shared/animations/editorial_transitions.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final RagRepository _repository = MockRagRepository();
  FieldSensorData? _sensorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    final data = await _repository.fetchFieldSensorData('thanjavur_budalur');
    if (mounted) {
      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final authService = Provider.of<AuthService>(context);
    final farmer = authService.currentFarmer;
    final isTamil = localeNotifier.languageCode == 'ta';

    return Scaffold(
      appBar: EditorialHeader(
        title: isTamil ? 'விவசாயி அறிக்கை பலகை' : 'Farmer Intelligence Dashboard',
        subtitle: '${farmer?.district ?? "Thanjavur"} · Budalur Block · ${farmer?.agroZone ?? "Cauvery Delta Zone"}',
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active District & Block Scope Banner
                EditorialFadeIn(
                  child: FieldNotebookCard(
                    title: farmer != null ? 'FARMER PROFILE: ${farmer.name.toUpperCase()}' : 'ACTIVE FIELD SCOPE',
                    subtitle: isTamil
                        ? 'மாநிலம்: தமிழ்நாடு | மாவட்டம்: தஞ்சாவூர் | வட்டாரம்: பூதலூர்'
                        : 'State: Tamil Nadu | District: Thanjavur | Block: Budalur',
                    tagText: 'LIVE FIELD SCOPE',
                    tagColor: AppColors.field,
                    trailing: TextButton(
                      onPressed: () => context.go('/farmer/region'),
                      child: Text(
                        l10n.text('selectRegion'),
                        style: const TextStyle(fontSize: 11.0, color: AppColors.straw),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildContextTag(isTamil ? 'மண்: வண்டல் & களிமண்' : 'Soil: Alluvial Clay'),
                            _buildContextTag(isTamil ? 'பருவம்: குறுவை 2025' : 'Season: Kuruvai 2025'),
                            _buildContextTag(isTamil ? 'நிலம்: ${farmer?.landSizeAcres ?? 4.5} ஏக்கர்' : 'Land: ${farmer?.landSizeAcres ?? 4.5} Acres'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Telemetry
                if (_isLoading || _sensorData == null)
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    color: AppColors.surface,
                    child: Text(l10n.text('loading'), style: const TextStyle(color: AppColors.foregroundMuted)),
                  )
                else
                  EditorialSlideUp(
                    delay: const Duration(milliseconds: 100),
                    child: ScientificTelemetryBar(
                      sensorData: _sensorData!,
                      currentLocale: localeNotifier.languageCode,
                    ),
                  ),
                const SizedBox(height: 20),

                // Primary Question Section: "What can I ask RagUzhavan?"
                EditorialSlideUp(
                  delay: const Duration(milliseconds: 200),
                  child: FieldNotebookCard(
                    title: l10n.text('whatCanIAskTitle'),
                    subtitle: 'Select an agricultural query category anchored in official regional datasets',
                    tagText: 'QUERY SYSTEM',
                    tagColor: AppColors.straw,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAskCategoryTile(
                          category: l10n.text('askCategoryIrrigation'),
                          question: l10n.text('sampleIrrigation'),
                          icon: Icons.water_drop_outlined,
                          onTap: () => context.go('/farmer/ask'),
                        ),
                        const Divider(height: 16),
                        _buildAskCategoryTile(
                          category: l10n.text('askCategorySowing'),
                          question: l10n.text('sampleSowing'),
                          icon: Icons.calendar_today_outlined,
                          onTap: () => context.go('/farmer/ask'),
                        ),
                        const Divider(height: 16),
                        _buildAskCategoryTile(
                          category: l10n.text('askCategoryAttention'),
                          question: l10n.text('sampleAttention'),
                          icon: Icons.warning_amber_outlined,
                          onTap: () => context.go('/farmer/ask'),
                        ),
                        const Divider(height: 16),
                        _buildAskCategoryTile(
                          category: l10n.text('askCategoryAdvisory'),
                          question: l10n.text('sampleAdvisory'),
                          icon: Icons.article_outlined,
                          onTap: () => context.go('/farmer/ask'),
                        ),
                        const Divider(height: 16),
                        _buildAskCategoryTile(
                          category: l10n.text('askCategoryMandi'),
                          question: l10n.text('sampleMandi'),
                          icon: Icons.storefront_outlined,
                          onTap: () => context.go('/farmer/ask'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/farmer/ask'),
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
                ),
                const SizedBox(height: 24),

                // Grounded Evaluation Scenarios
                Text(
                  isTamil ? 'ஆதாரப்பூர்வ மேலாண்மை காட்சிகள்' : 'GROUNDED AGRICULTURAL EVALUATIONS',
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.straw,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'நெல் குலை நோய் மேலாண்மை (பூதலூர்)' : 'Rice Blast Fungicide Protocol (Budalur Block)',
                  district: 'Thanjavur · Budalur · Samba Paddy',
                  badge: 'Grounded Evidence (3 Citations)',
                  badgeColor: AppColors.field,
                  scenarioKey: 'grounded',
                ),
                const SizedBox(height: 10),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'இடம் குறிப்பிடப்படாத கேள்வி (கேள்வி தெளிவு)' : 'Unspecified Field Location (Clarification Flow)',
                  district: 'District & Block missing',
                  badge: 'Location Clarification Needed',
                  badgeColor: AppColors.warning,
                  scenarioKey: 'clarification_location',
                ),
                const SizedBox(height: 10),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'கடலாடி வட்டாரம் - தற்போதைய தரவு இல்லை' : 'No Current Data for Block (Kadaladi Block)',
                  district: 'Ramanathapuram · Kadaladi · Groundnut',
                  badge: 'No Data for Block (>194 Days)',
                  badgeColor: AppColors.error,
                  scenarioKey: 'no_data',
                ),
                const SizedBox(height: 10),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'தமிழ் ஆவண சான்று மேலாண்மை' : 'Tamil Native Grounded Advisory',
                  district: 'தஞ்சாவூர் · பூதலூர் · நெல்',
                  badge: 'தமிழ் ஆவணம் (TNAU 2025)',
                  badgeColor: AppColors.leaf,
                  scenarioKey: 'tamil_grounded',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderBright),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.0, color: AppColors.paper),
      ),
    );
  }

  Widget _buildAskCategoryTile({
    required String category,
    required String question,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.straw, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.leaf,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '"$question"',
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: AppColors.paper,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.foregroundSubtle),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioRow({
    required BuildContext context,
    required String title,
    required String district,
    required String badge,
    required Color badgeColor,
    required String scenarioKey,
  }) {
    return FieldNotebookCard(
      onTap: () => context.go('/farmer/response?scenario=$scenarioKey'),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFootlight,
                    fontSize: 16.0,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  district,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              border: Border.all(color: badgeColor, width: 1.0),
            ),
            child: Text(
              badge.toUpperCase(),
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.foregroundSubtle, size: 18),
        ],
      ),
    );
  }
}

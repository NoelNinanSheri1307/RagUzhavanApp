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
    final data = await _repository.fetchFieldSensorData('thanjavur_01');
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
        subtitle: '${farmer?.district ?? "Thanjavur"} · ${farmer?.agroZone ?? "Cauvery Delta Zone"}',
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
                // Active District Context Banner
                EditorialFadeIn(
                  child: FieldNotebookCard(
                    title: farmer != null ? 'FARMER RECORD: ${farmer.name.toUpperCase()}' : 'ACTIVE DISTRICT SCOPE',
                    subtitle: isTamil
                        ? 'மாவட்ட நிர்வாக வரம்பு: ${farmer?.district ?? "தஞ்சாவூர்"} | முதன்மைப் பயிர்: நெல்'
                        : 'District Jurisdiction: ${farmer?.district ?? "Thanjavur"} | Crop: Paddy (Kuruvai)',
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
                        Row(
                          children: [
                            _buildContextTag(isTamil ? 'மண்: வண்டல் & களிமண்' : 'Soil: Alluvial Clay'),
                            const SizedBox(width: 8),
                            _buildContextTag(isTamil ? 'பருவம்: குறுவை 2025' : 'Season: Kuruvai 2025'),
                            const SizedBox(width: 8),
                            _buildContextTag(isTamil ? 'நிலம்: ${farmer?.landSizeAcres ?? 4.5} ஏக்கர்' : 'Land: ${farmer?.landSizeAcres ?? 4.5} Acres'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Scientific Sensor Telemetry Readout
                if (_isLoading || _sensorData == null)
                  Container(
                    height: 90,
                    alignment: Alignment.center,
                    color: AppColors.surface,
                    child: Text(l10n.text('loading'), style: const TextStyle(color: AppColors.foregroundMuted)),
                  )
                else
                  EditorialSlideUp(
                    delay: const Duration(milliseconds: 150),
                    child: ScientificTelemetryBar(
                      sensorData: _sensorData!,
                      currentLocale: localeNotifier.languageCode,
                    ),
                  ),
                const SizedBox(height: 20),

                // Primary Query Action Hero Box
                EditorialSlideUp(
                  delay: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      border: Border.all(color: AppColors.straw, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline, color: AppColors.straw, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.text('askHeader'),
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFootlight,
                                  fontSize: 20.0,
                                  color: AppColors.foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.text('askSubheader'),
                          style: const TextStyle(fontSize: 13.0, color: AppColors.foregroundMuted, height: 1.45),
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
                                const Icon(Icons.send_outlined, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Grounding Scenarios Test Matrix
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
                  title: isTamil ? 'நெல் குலை நோய் மேலாண்மை' : 'Rice Blast Fungicide Protocol',
                  district: 'Thanjavur · Paddy',
                  badge: 'Grounded Evidence (3 Citations)',
                  badgeColor: AppColors.field,
                  scenarioKey: 'grounded',
                ),
                const SizedBox(height: 10),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'பருத்தி காய் புழு - வடிகால் விவரம் தேவை' : 'Cotton Bollworm - Drainage Clarification',
                  district: 'Coimbatore · Cotton',
                  badge: 'Missing Context Prompt',
                  badgeColor: AppColors.warning,
                  scenarioKey: 'clarification',
                ),
                const SizedBox(height: 10),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'நிலக்கடலை அசுவினி தாக்குதல் (பழைய தரவு)' : 'Groundnut Dryland Pest - Data Staleness',
                  district: 'Ramanathapuram · Groundnut',
                  badge: 'No Current Data (>180 Days)',
                  badgeColor: AppColors.error,
                  scenarioKey: 'no_data',
                ),
                const SizedBox(height: 10),

                _buildScenarioRow(
                  context: context,
                  title: isTamil ? 'தமிழ் ஆவண சான்று மேலாண்மை' : 'Tamil Native Grounded Advisory',
                  district: 'தஞ்சாவூர் · நெல்',
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

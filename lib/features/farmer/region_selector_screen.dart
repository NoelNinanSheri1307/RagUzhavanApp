import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../data/models/region.dart';
import '../../data/models/field_sensor_data.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/repositories/mock_rag_repository.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/scientific_telemetry_bar.dart';

class RegionSelectorScreen extends StatefulWidget {
  const RegionSelectorScreen({super.key});

  @override
  State<RegionSelectorScreen> createState() => _RegionSelectorScreenState();
}

class _RegionSelectorScreenState extends State<RegionSelectorScreen> {
  final RagRepository _repository = MockRagRepository();
  List<Region> _regions = [];
  Region? _selectedRegion;
  FieldSensorData? _sensorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    final list = await _repository.fetchSupportedRegions();
    if (list.isNotEmpty) {
      _selectedRegion = list.first;
      final sensor = await _repository.fetchFieldSensorData(list.first.id);
      if (mounted) {
        setState(() {
          _regions = list;
          _sensorData = sensor;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectRegion(Region region) async {
    setState(() => _isLoading = true);
    final sensor = await _repository.fetchFieldSensorData(region.id);
    if (mounted) {
      setState(() {
        _selectedRegion = region;
        _sensorData = sensor;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('regionHeader'),
        showBackButton: true,
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer/region'),
      body: _isLoading && _regions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.straw))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          border: Border.all(color: AppColors.straw, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.explore_outlined, color: AppColors.straw, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isTamil
                                    ? 'எல்லைத் தேர்வு: தேர்ந்தெடுக்கப்பட்ட மாவட்டம் மற்றும் வட்டாரம் மட்டுமே ஆதார ஆவணப் பெறுகையைத் தீர்மானிக்கிறது.'
                                    : 'EVIDENCE BOUNDARY: Region selection strictly bounds which university extension bulletins and weather records can be retrieved.',
                                style: const TextStyle(fontSize: 12.0, color: AppColors.paper, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        l10n.text('regionHeader').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.straw,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _regions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final reg = _regions[index];
                          final isSelected = _selectedRegion?.id == reg.id;
                          final distName = isTamil ? reg.districtNameTamil : reg.districtName;
                          final blockName = isTamil ? reg.blockNameTamil : reg.blockName;

                          return FieldNotebookCard(
                            onTap: () => _selectRegion(reg),
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: isSelected ? AppColors.straw : AppColors.foregroundSubtle,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'STATE: ${reg.stateName.toUpperCase()} · DISTRICT: ${distName.toUpperCase()}',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.leaf,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'BLOCK: ${blockName.toUpperCase()} BLOCK',
                                            style: const TextStyle(
                                              fontFamily: 'FootlightMTLight',
                                              fontSize: 17.0,
                                              color: AppColors.foreground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                      decoration: BoxDecoration(
                                        color: reg.hasActiveStationData ? AppColors.successBg : AppColors.errorBg,
                                        border: Border.all(color: reg.hasActiveStationData ? AppColors.field : AppColors.error),
                                      ),
                                      child: Text(
                                        reg.hasActiveStationData ? 'ACTIVE DATA' : 'NO CURRENT DATA',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: reg.hasActiveStationData ? AppColors.leaf : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSelected) ...[
                                  const Divider(height: 16),
                                  _buildDetailRow(label: l10n.text('agroZone'), value: reg.agroClimaticZone),
                                  const SizedBox(height: 4),
                                  _buildDetailRow(label: l10n.text('soilType'), value: reg.dominantSoilType),
                                  const SizedBox(height: 4),
                                  _buildDetailRow(label: l10n.text('primarySeason'), value: reg.primarySeason),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      if (_selectedRegion != null) ...[
                        if (_sensorData != null)
                          ScientificTelemetryBar(
                            sensorData: _sensorData!,
                            currentLocale: localeNotifier.languageCode,
                          ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_selectedRegion!.hasActiveStationData) {
                                context.go('/farmer/response?scenario=no_data');
                              } else {
                                context.go('/farmer/ask');
                              }
                            },
                            child: Text(
                              isTamil
                                  ? 'இந்த வட்டாரத்திற்கான கேள்வியைச் சமர்ப்பிக்க'
                                  : 'Formulate Query for ${_selectedRegion!.districtName} (${_selectedRegion!.blockName} Block)',
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.foregroundSubtle),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.paper),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

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
import '../../shared/animations/editorial_transitions.dart';

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
                      Text(
                        isTamil ? 'தமிழ்நாடு மாவட்ட வேளாண் அதிகார எல்லைகள்' : 'TAMIL NADU DISTRICT JURISDICTIONS',
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.straw,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _regions.map((reg) {
                            final isSelected = _selectedRegion?.id == reg.id;
                            final name = isTamil ? reg.districtNameTamil : reg.districtName;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: ChoiceChip(
                                label: Text(name),
                                selected: isSelected,
                                onSelected: (_) => _selectRegion(reg),
                                selectedColor: AppColors.straw,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  fontSize: 13.0,
                                  color: isSelected ? AppColors.background : AppColors.paper,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                side: const BorderSide(color: AppColors.borderBright),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_selectedRegion != null) ...[
                        EditorialFadeIn(
                          key: ValueKey(_selectedRegion!.id),
                          child: FieldNotebookCard(
                            title: '${_selectedRegion!.districtName.toUpperCase()} DISTRICT',
                            subtitle: _selectedRegion!.agroClimaticZone,
                            tagText: 'AGRO SCOPE',
                            tagColor: AppColors.leaf,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                  label: l10n.text('agroZone'),
                                  value: _selectedRegion!.agroClimaticZone,
                                ),
                                const Divider(height: 16),
                                _buildDetailRow(
                                  label: l10n.text('soilType'),
                                  value: _selectedRegion!.dominantSoilType,
                                ),
                                const Divider(height: 16),
                                _buildDetailRow(
                                  label: l10n.text('primarySeason'),
                                  value: _selectedRegion!.primarySeason,
                                ),
                                const Divider(height: 16),
                                _buildDetailRow(
                                  label: 'GEO COORDINATES',
                                  value: '${_selectedRegion!.latitude}° N, ${_selectedRegion!.longitude}° E',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_sensorData != null)
                          ScientificTelemetryBar(
                            sensorData: _sensorData!,
                            currentLocale: localeNotifier.languageCode,
                          ),
                        const SizedBox(height: 20),

                        FieldNotebookCard(
                          title: l10n.text('activeAlerts'),
                          subtitle: 'Real-time meteorological & pest monitoring alerts',
                          tagText: 'AGRO ALERTS',
                          tagColor: AppColors.warning,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAlertItem(
                                title: isTamil ? 'குறுவை பருவ மழைப்பொழிவு எச்சரிக்கை' : 'Cauvery Delta Canal Flow Advisory',
                                detail: isTamil
                                    ? 'காவேரி மேலணையிலிருந்து தண்ணீர் திறப்பு அதிகரிக்கப்பட்டுள்ளது. வடிகால் வாய்க்கால்களை தூர்வாரவும்.'
                                    : 'Mettur reservoir release maintained at 12,000 cusecs. Clear field drainage channels.',
                                date: 'Updated 2 hours ago',
                              ),
                              const Divider(height: 20),
                              _buildAlertItem(
                                title: isTamil ? 'இலை சுருட்டுப் புழு கவனிப்பு எச்சரிக்கை' : 'Leaf Folder Pest Monitoring',
                                detail: isTamil
                                    ? 'இரவு நேர அதிக ஈரப்பதம் காரணமாக இலை சுருட்டுப் புழு தாக்குதல் சாத்தியம்.'
                                    : 'High ambient humidity (>82%) elevates leaf folder vulnerability in late tillering stage.',
                                date: 'Updated 1 day ago',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/farmer/ask'),
                            child: Text(isTamil ? 'இந்த மாவட்டத்திற்கான கேள்வி கேட்க' : 'Formulate Query for ${_selectedRegion!.districtName}'),
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
          style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: AppColors.foregroundSubtle),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: AppColors.paper),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem({required String title, required String detail, required String date}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.foreground),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: const TextStyle(fontSize: 12.5, color: AppColors.foregroundMuted, height: 1.4),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(fontSize: 10.5, color: AppColors.foregroundSubtle),
        ),
      ],
    );
  }
}

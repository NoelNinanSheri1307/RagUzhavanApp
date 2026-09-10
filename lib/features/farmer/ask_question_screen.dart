import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _queryController = TextEditingController(
    text: 'What is the recommended fungicide treatment for rice blast in Thanjavur clay soil during Kuruvai season?',
  );
  String _selectedCrop = 'Paddy / Rice';
  String _growthStage = 'Tillering Phase';
  String _irrigationType = 'Canal-fed Alluvial';
  String _season = 'Kuruvai (June-Sept)';
  bool _isLowBandwidthMode = false;
  bool _isSubmitting = false;

  final List<String> _presetQueries = const [
    'What is the recommended treatment for rice blast in Thanjavur clay soil during Kuruvai season?',
    'How to manage cotton bollworm pest attack in Coimbatore black cotton soil?',
    'Are there recent advisories for groundnut aphid control in Ramanathapuram dryland zone?',
    'தஞ்சாவூர் குறுவை நெல் குலை நோய் தடுப்பு மருந்துகள் யாவை?',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('askHeader'),
        showBackButton: true,
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer/ask'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldNotebookCard(
                  title: 'AGRICULTURAL ENQUIRY FORM',
                  subtitle: 'Specify question and field parameters for grounded retrieval',
                  tagText: 'RAG QUERY FORM',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('askHeader').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _queryController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.foreground,
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.text('questionPlaceholder'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'FIELD PARAMETERS (DISTRICT: THANJAVUR)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.leaf,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildParameterDropdown(
                              label: l10n.text('cropNameLabel'),
                              value: _selectedCrop,
                              items: const [
                                'Paddy / Rice',
                                'Cotton',
                                'Groundnut',
                                'Blackgram',
                              ],
                              onChanged: (val) => setState(() => _selectedCrop = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildParameterDropdown(
                              label: l10n.text('growthStageLabel'),
                              value: _growthStage,
                              items: const [
                                'Nursery Stage',
                                'Tillering Phase',
                                'Panicle Initiation',
                                'Grain Filling',
                              ],
                              onChanged: (val) => setState(() => _growthStage = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildParameterDropdown(
                              label: l10n.text('irrigationLabel'),
                              value: _irrigationType,
                              items: const [
                                'Canal-fed Alluvial',
                                'Borewell / Tube well',
                                'Rainfed Dryland',
                                'Drip Fertigation',
                              ],
                              onChanged: (val) => setState(() => _irrigationType = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildParameterDropdown(
                              label: l10n.text('cropSeason'),
                              value: _season,
                              items: const [
                                'Kuruvai (June-Sept)',
                                'Samba (Aug-Jan)',
                                'Thaladi (Oct-Feb)',
                                'Navarai (Dec-May)',
                              ],
                              onChanged: (val) => setState(() => _season = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cell_tower, color: AppColors.straw, size: 18),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.text('lowBandwidthHeader'),
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.paper),
                                    ),
                                    Text(
                                      isTamil ? '2G குறுஞ்செய்தி வழி சுருக்கப்பட்ட தரவு' : 'Compress payload for 2G / SMS transmission',
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.foregroundSubtle),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: _isLowBandwidthMode,
                              activeThumbColor: AppColors.straw,
                              onChanged: (val) => setState(() => _isLowBandwidthMode = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(l10n.text('loading')),
                                  ],
                                )
                              : Row(
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
                const SizedBox(height: 20),

                FieldNotebookCard(
                  title: l10n.text('presetQueries'),
                  subtitle: 'Tap to load sample regional questions',
                  tagText: 'PRESETS',
                  tagColor: AppColors.field,
                  child: Column(
                    children: _presetQueries.map((query) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _queryController.text = query;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.subdirectory_arrow_right, color: AppColors.straw, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  query,
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.paper),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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

  Widget _buildParameterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w600, color: AppColors.foregroundMuted),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: AppColors.surfaceElevated,
          isExpanded: true,
          style: const TextStyle(fontSize: 12.5, color: AppColors.foreground),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final text = _queryController.text.toLowerCase();

    String scenario = 'grounded';
    if (text.contains('cotton') || text.contains('clarify') || text.contains('bollworm')) {
      scenario = 'clarification';
    } else if (text.contains('groundnut') || text.contains('no data') || text.contains('aphid')) {
      scenario = 'no_data';
    } else if (text.contains('தமிழ்') || text.contains('குறுவை')) {
      scenario = 'tamil_grounded';
    }

    if (_isLowBandwidthMode) {
      context.go('/farmer/low-bandwidth');
    } else {
      context.go('/farmer/response?scenario=$scenario');
    }
  }
}

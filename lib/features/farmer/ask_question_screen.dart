import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/services/speech_to_text_service.dart';
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
    text: 'Should I irrigate my paddy field this week in Budalur block?',
  );

  final SpeechToTextService _sttService = AppSpeechToTextService();
  bool _isListening = false;
  String? _sttError;

  String _district = 'Thanjavur';
  String _block = 'Budalur';
  String _selectedCrop = 'Paddy / Rice';
  String _growthStage = 'Tillering Phase';
  String _irrigationType = 'Canal-fed Alluvial';
  String _season = 'Kuruvai (June-Sept)';
  bool _isLowBandwidthMode = false;
  bool _isSubmitting = false;

  final List<String> _presetQueries = const [
    'Should I irrigate my paddy field this week in Budalur block?',
    'What is the recommended fungicide treatment for rice blast in Thanjavur clay soil?',
    'How to manage cotton bollworm attack in Thondamuthur block, Coimbatore?',
    'Are there recent groundnut advisories for Kadaladi block in Ramanathapuram?',
    'தஞ்சாவூர் பூதலூர் வட்டார நெல் குலை நோய் தடுப்பு மருந்துகள் யாவை?',
  ];

  Future<void> _toggleSpeechToText() async {
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    final lang = localeNotifier.languageCode;

    if (_isListening) {
      await _sttService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _sttError = null;
      });
      await _sttService.startListening(
        languageCode: lang,
        onResult: (text) {
          setState(() {
            _queryController.text = text;
          });
        },
        onError: (err) {
          setState(() {
            _isListening = false;
            _sttError = err;
          });
        },
      );
      setState(() {
        _isListening = _sttService.isListening;
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
                  subtitle: 'Specify natural-language question and field context parameters',
                  tagText: 'RAG QUERY FORM',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.text('askHeader').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.foregroundSubtle,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _toggleSpeechToText,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? AppColors.errorBg
                                    : AppColors.surfaceHighlight,
                                border: Border.all(
                                  color: _isListening ? AppColors.error : AppColors.straw,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isListening ? Icons.mic : Icons.mic_none,
                                    size: 14,
                                    color: _isListening ? AppColors.error : AppColors.straw,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isListening
                                        ? (isTamil ? 'பேசுகிறீர்கள்...' : 'LISTENING...')
                                        : (isTamil ? 'குரல் உள்ளீடு' : 'VOICE INPUT'),
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: _isListening ? AppColors.error : AppColors.straw,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_sttError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _sttError!,
                          style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundMuted),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _queryController,
                        maxLines: 4,
                        style: const TextStyle(color: AppColors.foreground, fontSize: 14.0),
                        decoration: InputDecoration(
                          hintText: l10n.text('questionPlaceholder'),
                          hintStyle: const TextStyle(color: AppColors.foregroundSubtle, fontSize: 13.0),
                          fillColor: AppColors.surfaceHighlight,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 12),

                      Text(
                        l10n.text('fieldContextGroup').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 500;

                          Widget buildPair(Widget first, Widget second) {
                            if (isCompact) {
                              return Column(
                                children: [
                                  first,
                                  const SizedBox(height: 12),
                                  second,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: first),
                                const SizedBox(width: 12),
                                Expanded(child: second),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              buildPair(
                                _buildParameterDropdown(
                                  label: l10n.text('districtContext'),
                                  value: _district,
                                  items: const ['Thanjavur', 'Coimbatore', 'Ramanathapuram', 'Madurai', 'Omit District (Test Clarification)'],
                                  onChanged: (val) => setState(() {
                                    _district = val!;
                                    if (_district == 'Coimbatore') _block = 'Thondamuthur';
                                    if (_district == 'Ramanathapuram') _block = 'Kadaladi';
                                    if (_district == 'Madurai') _block = 'Thiruparankundram';
                                    if (_district == 'Thanjavur') _block = 'Budalur';
                                    if (_district.contains('Omit')) _block = 'Omit Block';
                                  }),
                                ),
                                _buildParameterDropdown(
                                  label: l10n.text('blockContext'),
                                  value: _block,
                                  items: const ['Budalur', 'Thondamuthur', 'Kadaladi', 'Thiruparankundram', 'Omit Block'],
                                  onChanged: (val) => setState(() => _block = val!),
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildPair(
                                _buildParameterDropdown(
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
                                _buildParameterDropdown(
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
                              const SizedBox(height: 12),
                              buildPair(
                                _buildParameterDropdown(
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
                                _buildParameterDropdown(
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
                          );
                        },
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
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.cell_tower, color: AppColors.straw, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.text('lowBandwidthHeader'),
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.paper),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          isTamil ? '2G குறுஞ்செய்தி வழி சுருக்கப்பட்ட தரவு (50 KB Max)' : 'Compress payload for 2G / SMS transmission (50 KB Limit)',
                                          style: const TextStyle(fontSize: 10.5, color: AppColors.foregroundSubtle),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                    Flexible(
                                      child: Text(
                                        l10n.text('askQuestion'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
    if (_district.contains('Omit') || _block.contains('Omit') || text.contains('clarify location')) {
      scenario = 'clarification_location';
    } else if (_district == 'Ramanathapuram' || _block == 'Kadaladi' || text.contains('kadaladi')) {
      scenario = 'no_data';
    } else if (_selectedCrop.contains('Cotton') || text.contains('cotton')) {
      scenario = 'clarification_cotton';
    } else if (text.contains('தமிழ்') || text.contains('நெல்')) {
      scenario = 'tamil_grounded';
    }

    if (_isLowBandwidthMode) {
      context.go('/farmer/low-bandwidth');
    } else {
      context.go('/farmer/response?scenario=$scenario');
    }
  }
}

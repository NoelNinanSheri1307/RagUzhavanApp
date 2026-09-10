import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/services/speech_to_text_service.dart';
import '../../data/repositories/rag_repository.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class AskQuestionScreen extends StatefulWidget {
  final int? sessionId;

  const AskQuestionScreen({super.key, this.sessionId});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  late final TextEditingController _queryController;
  late final SpeechToTextService _sttService;

  // Sensor Mode Input Controllers
  final TextEditingController _waterLevelCtrl = TextEditingController(text: '5.2 cm');
  final TextEditingController _tempCtrl = TextEditingController(text: '30.6 C');
  final TextEditingController _humidityCtrl = TextEditingController(text: '82%');
  final TextEditingController _soilMoistureCtrl = TextEditingController(text: '44.5%');
  final TextEditingController _nitrogenCtrl = TextEditingController(text: '156 ppm');
  final TextEditingController _phCtrl = TextEditingController(text: '6.8');
  final TextEditingController _lightCtrl = TextEditingController(text: '32k lx');

  bool _isListening = false;
  String? _sttError;
  bool _isSubmitting = false;
  String _selectedMode = 'normal'; // 'normal' | 'metrics' | 'sensor'
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _sttService = AppSpeechToTextService();
    _currentSessionId = widget.sessionId;
  }

  @override
  void dispose() {
    _queryController.dispose();
    _waterLevelCtrl.dispose();
    _tempCtrl.dispose();
    _humidityCtrl.dispose();
    _soilMoistureCtrl.dispose();
    _nitrogenCtrl.dispose();
    _phCtrl.dispose();
    _lightCtrl.dispose();
    _sttService.stopListening();
    super.dispose();
  }

  Future<void> _toggleSpeechToText() async {
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    final isTamil = localeNotifier.languageCode == 'ta';

    if (_isListening) {
      await _sttService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _sttError = null;
      });

      await _sttService.startListening(
        languageCode: isTamil ? 'ta' : 'en',
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
    }
  }

  Future<void> _handleSubmit() async {
    final text = _queryController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    final ragRepo = Provider.of<RagRepository>(context, listen: false);

    try {
      int activeSid = _currentSessionId ?? 0;
      if (activeSid <= 0) {
        final newSession = await ragRepo.createSession();
        activeSid = newSession?.id ?? 1;
      }

      Map<String, dynamic>? sensorsPayload;
      if (_selectedMode == 'sensor') {
        sensorsPayload = {
          'water_level': _waterLevelCtrl.text.trim(),
          'temperature': _tempCtrl.text.trim(),
          'humidity': _humidityCtrl.text.trim(),
          'soil_moisture': _soilMoistureCtrl.text.trim(),
          'nitrogen': _nitrogenCtrl.text.trim(),
          'ph': _phCtrl.text.trim(),
          'light': _lightCtrl.text.trim(),
        };
      }

      final response = await ragRepo.askQuestion(
        sessionId: activeSid,
        question: text,
        mode: _selectedMode,
        sensors: sensorsPayload,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        context.go('/farmer/response?session_id=$activeSid&msg_id=${response.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _sttError = 'Failed to send query: $e';
        });
      }
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
                  title: 'AGRICULTURAL RAG QUERY FORM',
                  subtitle: 'Submit natural-language question directly to Railway backend vector pipeline',
                  tagText: 'LIVE RAG QUERY',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selector Bar
                      const Text(
                        'SELECT RAG OPERATING MODE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.straw,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildModeChip('normal', 'NORMAL', 'Standard RAG Search'),
                          const SizedBox(width: 8),
                          _buildModeChip('metrics', 'METRICS', 'Region Slot Clarification'),
                          const SizedBox(width: 8),
                          _buildModeChip('sensor', 'SENSOR', 'Telemetry Augmented'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Question Header & Speech Button
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
                                color: _isListening ? AppColors.errorBg : AppColors.surfaceHighlight,
                                border: Border.all(color: _isListening ? AppColors.error : AppColors.straw),
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
                          style: const TextStyle(fontSize: 11.0, color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Natural Language Query Input
                      TextField(
                        controller: _queryController,
                        maxLines: 4,
                        style: const TextStyle(color: AppColors.foreground, fontSize: 14.0),
                        decoration: InputDecoration(
                          hintText: isTamil
                              ? 'உங்கள் விவசாயக் கேள்வியைக் குறிப்பிடவும் (எ.கா. பூதலூர் வட்டாரத்தில் நெல் குலை நோய்க்கு என்ன மருந்து தெளிக்க வேண்டும்?)'
                              : 'Specify agricultural question (e.g. Should I apply fungicide for Leaf Blast in Budalur block?)',
                          hintStyle: const TextStyle(color: AppColors.foregroundSubtle, fontSize: 13.0),
                          fillColor: AppColors.surfaceHighlight,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sensor Mode Telemetry Controls (Shown only when sensor mode is active)
                      if (_selectedMode == 'sensor') ...[
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            border: Border.all(color: AppColors.straw),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TELEMETRY READINGS (SENT IN PAYLOAD TO RAG PIPELINE)',
                                style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.straw),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildSensorField('Water Level', _waterLevelCtrl),
                                  _buildSensorField('Temp (°C)', _tempCtrl),
                                  _buildSensorField('Humidity (%)', _humidityCtrl),
                                  _buildSensorField('Moisture (%)', _soilMoistureCtrl),
                                  _buildSensorField('Nitrogen (ppm)', _nitrogenCtrl),
                                  _buildSensorField('Soil pH', _phCtrl),
                                  _buildSensorField('Light (lx)', _lightCtrl),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
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
                                        l10n.text('askQuestion').toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(String modeKey, String label, String tooltip) {
    final isSelected = _selectedMode == modeKey;
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: ChoiceChip(
          label: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.background : AppColors.foreground,
              ),
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.straw,
          backgroundColor: AppColors.surfaceHighlight,
          shape: const RoundedRectangleBorder(side: BorderSide(color: AppColors.border)),
          onSelected: (val) => setState(() => _selectedMode = modeKey),
        ),
      ),
    );
  }

  Widget _buildSensorField(String label, TextEditingController ctrl) {
    return SizedBox(
      width: 110,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 12.0, color: AppColors.paper, fontFamily: 'monospace'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10.0, color: AppColors.foregroundSubtle),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          filled: true,
          fillColor: AppColors.surface,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

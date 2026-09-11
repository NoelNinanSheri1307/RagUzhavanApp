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
import '../../shared/widgets/soil_texture_painter.dart';

class AskQuestionScreen extends StatefulWidget {
  final int? sessionId;

  const AskQuestionScreen({super.key, this.sessionId});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  late final TextEditingController _queryController;
  late final SpeechToTextService _sttService;

  bool _isListening = false;
  String? _sttError;
  bool _isSubmitting = false;
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

      final response = await ragRepo.askQuestion(
        sessionId: activeSid,
        question: text,
        mode: 'normal',
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
      body: SoilTextureBackground(
        child: SingleChildScrollView(
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

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.straw,
                              foregroundColor: AppColors.background,
                            ),
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
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            l10n.text('askQuestion').toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                          ),
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
      ),
    );
  }
}


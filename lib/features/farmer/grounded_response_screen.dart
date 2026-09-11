import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../core/services/translation_service.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/models/chat_message_model.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/soil_texture_painter.dart';
import '../../shared/animations/editorial_transitions.dart';

class GroundedResponseScreen extends StatefulWidget {
  final int? sessionId;

  const GroundedResponseScreen({super.key, this.sessionId});

  @override
  State<GroundedResponseScreen> createState() => _GroundedResponseScreenState();
}

class _GroundedResponseScreenState extends State<GroundedResponseScreen> {
  late final TextToSpeechService _ttsService;
  late final AppTranslationService _translationService;

  bool _isLoading = true;
  List<ChatMessageModel> _messages = [];
  bool _isSpeaking = false;
  String? _ttsError;

  bool _isTranslating = false;
  bool _isTranslated = false;
  String? _translatedText;

  @override
  void initState() {
    super.initState();
    _ttsService = AppTextToSpeechService();
    _translationService = AppTranslationService();
    _fetchSessionMessages();
  }

  @override
  void dispose() {
    _ttsService.stop();
    _translationService.close();
    super.dispose();
  }

  Future<void> _fetchSessionMessages() async {
    final sid = widget.sessionId ?? 1;
    final ragRepo = Provider.of<RagRepository>(context, listen: false);
    try {
      final list = await ragRepo.getSessionMessages(sid);
      setState(() {
        _messages = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSpeechPlayback(String textToSpeak) async {
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);

    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() {
        _isSpeaking = true;
        _ttsError = null;
      });

      await _ttsService.speak(
        textToSpeak,
        languageCode: localeNotifier.languageCode,
        onError: (err) {
          if (mounted) {
            setState(() {
              _isSpeaking = false;
              _ttsError = err;
            });
          }
        },
      );
    }
  }

  Future<void> _toggleTranslation(String originalText) async {
    if (_isTranslated) {
      setState(() => _isTranslated = false);
      return;
    }

    if (_translatedText != null) {
      setState(() => _isTranslated = true);
      return;
    }

    setState(() => _isTranslating = true);

    final translated = await _translationService.translateText(
      text: originalText,
      sourceLanguage: 'en',
      targetLanguage: 'ta',
    );

    if (mounted) {
      setState(() {
        _translatedText = translated;
        _isTranslating = false;
        _isTranslated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // Latest assistant response message
    final lastAssistantMsg = _messages.lastWhere(
      (m) => m.role == 'assistant',
      orElse: () => ChatMessageModel(
        id: 0,
        role: 'assistant',
        content: 'No response available for this session.',
        createdAt: DateTime.now(),
      ),
    );

    final displayAnswer = _isTranslated && _translatedText != null
        ? _translatedText!
        : lastAssistantMsg.content;

    return Scaffold(
      appBar: EditorialHeader(
        title: 'GROUNDED RAG ADVISORY',
        subtitle: 'Railway Vector Corpus Response',
        showBackButton: true,
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer'),
      body: SoilTextureBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.straw))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Audio TTS & Translation Action Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => _toggleSpeechPlayback(displayAnswer),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: _isSpeaking ? AppColors.errorBg : AppColors.surfaceHighlight,
                                  border: Border.all(color: _isSpeaking ? AppColors.error : AppColors.straw),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isSpeaking ? Icons.stop : Icons.volume_up_outlined,
                                      size: 16,
                                      color: _isSpeaking ? AppColors.error : AppColors.straw,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isSpeaking ? 'STOP AUDIO' : 'LISTEN TO ADVISORY',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: _isSpeaking ? AppColors.error : AppColors.straw,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _isTranslating ? null : () => _toggleTranslation(lastAssistantMsg.content),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: _isTranslated ? AppColors.successBg : AppColors.surfaceHighlight,
                                  border: Border.all(color: _isTranslated ? AppColors.field : AppColors.straw),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.translate, size: 16, color: AppColors.leaf),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isTranslating
                                          ? 'TRANSLATING...'
                                          : (_isTranslated ? 'SHOW ORIGINAL (EN)' : 'TRANSLATE (தமிழ்)'),
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.leaf,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_ttsError != null) ...[
                          const SizedBox(height: 6),
                          Text(_ttsError!, style: const TextStyle(fontSize: 11.0, color: AppColors.error)),
                        ],
                        const SizedBox(height: 16),

                        // Grounded Advisory Text Card
                        EditorialSlideUp(
                          delay: const Duration(milliseconds: 100),
                          child: FieldNotebookCard(
                            title: 'GROUNDED RECOMMENDATION',
                            subtitle: 'Generated from verified extension literature and vector store passages',
                            tagText: 'RAG ADVISORY',
                            tagColor: AppColors.leaf,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayAnswer,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: AppColors.foreground,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHighlight,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    'Timestamp: ${lastAssistantMsg.createdAt.toString().split(".").first}',
                                    style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.foregroundSubtle),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Model Reasoning Trace (If available from backend)
                        if (lastAssistantMsg.reasoning != null && lastAssistantMsg.reasoning!.isNotEmpty) ...[
                          EditorialSlideUp(
                            delay: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                border: Border.all(color: AppColors.straw),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MODEL REASONING TRACE',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.straw,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    lastAssistantMsg.reasoning!,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'monospace',
                                      color: AppColors.paper,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Cited Sources Section from Chroma Vector Store
                        if (lastAssistantMsg.sources != null && lastAssistantMsg.sources!.isNotEmpty) ...[
                          EditorialSlideUp(
                            delay: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.article_outlined, color: AppColors.straw, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'CITED SOURCES (${lastAssistantMsg.sources!.length})',
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontFootlight,
                                          fontSize: 16.0,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: lastAssistantMsg.sources!.length,
                                    separatorBuilder: (context, index) => const Divider(height: 16),
                                    itemBuilder: (context, index) {
                                      final src = lastAssistantMsg.sources![index] as Map<String, dynamic>;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            src['title']?.toString() ?? 'Document',
                                            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: AppColors.paper),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '"${src["snippet"] ?? ""}"',
                                            style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic, color: AppColors.foregroundSubtle),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Bottom Navigation Actions
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/farmer/ask'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('ASK ANOTHER QUESTION'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.straw,
                              side: const BorderSide(color: AppColors.straw),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}


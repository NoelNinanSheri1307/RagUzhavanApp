import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/rag_response.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/repositories/mock_rag_repository.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/evidence_drawer.dart';
import '../../shared/animations/editorial_transitions.dart';

class GroundedResponseScreen extends StatefulWidget {
  final String scenarioKey;

  const GroundedResponseScreen({
    super.key,
    required this.scenarioKey,
  });

  @override
  State<GroundedResponseScreen> createState() => _GroundedResponseScreenState();
}

class _GroundedResponseScreenState extends State<GroundedResponseScreen> {
  final RagRepository _repository = MockRagRepository();
  RagResponse? _response;
  bool _isLoading = true;
  final Map<String, String> _clarificationAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadResponse();
  }

  @override
  void didUpdateWidget(covariant GroundedResponseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scenarioKey != widget.scenarioKey) {
      _loadResponse();
    }
  }

  Future<void> _loadResponse() async {
    setState(() => _isLoading = true);
    final locale = Provider.of<LocaleNotifier>(context, listen: false).languageCode;
    final res = await _repository.fetchPresetScenarioResponse(widget.scenarioKey, language: locale);
    if (mounted) {
      setState(() {
        _response = res;
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
        title: l10n.text('responseHeader'),
        subtitle: _response != null
            ? '${_response!.districtName} · ${_response!.cropName}'
            : 'Grounded Assessment',
        showBackButton: true,
        onBack: () => context.go('/farmer'),
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer/response'),
      body: _isLoading || _response == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.straw),
                  const SizedBox(height: 16),
                  Text(l10n.text('loading'), style: const TextStyle(color: AppColors.foregroundMuted)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorialSlideUp(
                        child: _buildStatusBanner(_response!, l10n, isTamil),
                      ),
                      const SizedBox(height: 16),

                      EditorialSlideUp(
                        delay: const Duration(milliseconds: 100),
                        child: FieldNotebookCard(
                          title: isTamil ? 'அறிவியல் வேளாண் வழிகாட்டுதல்' : 'AGRICULTURAL EXTENSION ADVISORY',
                          subtitle: 'Anchored in official district research bulletins',
                          tagText: _response!.status == ResponseStatus.grounded ? 'GROUNDED' : 'UNGROUNDED',
                          tagColor: _response!.status == ResponseStatus.grounded
                              ? AppColors.field
                              : AppColors.warning,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTamil && _response!.responseTextTamil.isNotEmpty
                                    ? _response!.responseTextTamil
                                    : _response!.responseText,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  height: 1.6,
                                  color: AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormatter.formatTimestamp(_response!.timestamp, locale: localeNotifier.languageCode),
                                    style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundSubtle),
                                  ),
                                  Text(
                                    DateFormatter.formatDataAge(_response!.averageDataAgeDays, locale: localeNotifier.languageCode),
                                    style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: AppColors.straw),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_response!.status == ResponseStatus.clarificationNeeded) ...[
                        EditorialSlideUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildClarificationCard(_response!, l10n, isTamil),
                        ),
                        const SizedBox(height: 16),
                      ],

                      EditorialSlideUp(
                        delay: const Duration(milliseconds: 300),
                        child: EvidenceDrawer(
                          response: _response!,
                          locale: localeNotifier.languageCode,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SWITCH MOCK TEST SCENARIO',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.straw, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildScenarioChip('grounded', 'Grounded (Paddy)', widget.scenarioKey == 'grounded'),
                                _buildScenarioChip('clarification', 'Clarification (Cotton)', widget.scenarioKey == 'clarification'),
                                _buildScenarioChip('no_data', 'No Data (Groundnut)', widget.scenarioKey == 'no_data'),
                                _buildScenarioChip('tamil_grounded', 'Tamil Advisory (தமிழ்)', widget.scenarioKey == 'tamil_grounded'),
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
    );
  }

  Widget _buildStatusBanner(RagResponse res, AppLocalizations l10n, bool isTamil) {
    Color bg;
    Color border;
    IconData icon;
    String statusText;

    switch (res.status) {
      case ResponseStatus.grounded:
        bg = AppColors.successBg;
        border = AppColors.field;
        icon = Icons.verified_outlined;
        statusText = l10n.text('statusGrounded');
        break;
      case ResponseStatus.clarificationNeeded:
        bg = AppColors.warningBg;
        border = AppColors.warning;
        icon = Icons.help_outline;
        statusText = l10n.text('statusClarification');
        break;
      case ResponseStatus.noData:
        bg = AppColors.errorBg;
        border = AppColors.error;
        icon = Icons.warning_amber_rounded;
        statusText = l10n.text('statusNoData');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 1.0)),
      child: Row(
        children: [
          Icon(icon, color: border, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: border,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Text(
            '${res.districtName} (${res.cropName})',
            style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildClarificationCard(RagResponse res, AppLocalizations l10n, bool isTamil) {
    return FieldNotebookCard(
      title: isTamil ? 'கூடுதல் விவரங்களை அளிக்கவும்' : 'FIELD CONTEXT CLARIFICATION',
      subtitle: l10n.text('clarificationPrompt'),
      tagText: 'ACTION REQUIRED',
      tagColor: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...res.clarificationQuestions.map((q) {
            final qText = isTamil && q.questionTextTamil.isNotEmpty ? q.questionTextTamil : q.questionText;
            final opts = isTamil && q.optionsTamil.isNotEmpty ? q.optionsTamil : q.options;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    qText,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.paper),
                  ),
                  const SizedBox(height: 8),
                  ...opts.map((opt) {
                    final isSelected = _clarificationAnswers[q.id] == opt;
                    return InkWell(
                      onTap: () => setState(() => _clarificationAnswers[q.id] = opt),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceHighlight : AppColors.surface,
                          border: Border.all(color: isSelected ? AppColors.straw : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.straw : AppColors.foregroundSubtle,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Text(opt, style: TextStyle(fontSize: 12.5, color: isSelected ? AppColors.straw : AppColors.paper)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _response = RagResponse(
                        id: 'RESP-CLARIFIED-02',
                        queryId: res.queryId,
                        responseText:
                            'Grounded Cotton Bollworm Protocol for Coimbatore (Well-drained Vertisols): Spray Chlorantraniliprole 18.5 SC @ 0.3 ml/L water. Deploy 5 pheromone traps per acre. Ref: CICR-BULLETIN-2025/COTTON-BOLLWORM',
                        responseTextTamil:
                            'கோயம்புத்தூர் கரிசல் மண் நிலத்திற்கான பருத்தி காய் புழு மேலாண்மை: குளோரான்ட்ரினிலிப்ரோல் 18.5 SC (0.3 மி.லி/லிட்டர்) தெளிக்கவும். ஏக்கருக்கு 5 இனக்கவர்ச்சி பொறிகளை வைக்கவும்.',
                        language: res.language,
                        isGrounded: true,
                        status: ResponseStatus.grounded,
                        districtName: res.districtName,
                        cropName: res.cropName,
                        averageDataAgeDays: 5,
                        timestamp: DateTime.now(),
                        evidenceSources: const [],
                        clarificationQuestions: const [],
                      );
                      _isLoading = false;
                    });
                  }
                });
              },
              child: Text(l10n.text('submit')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(String key, String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() {
        context.go('/farmer/response?scenario=$key');
      }),
      selectedColor: AppColors.straw,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 11.5,
        color: isSelected ? AppColors.background : AppColors.paper,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      side: const BorderSide(color: AppColors.borderBright),
    );
  }
}

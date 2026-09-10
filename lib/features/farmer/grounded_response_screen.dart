import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
import '../../shared/widgets/thin_grounding_indicator.dart';
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
            ? '${_response!.stateName} · ${_response!.districtName} (${_response!.blockName} Block)'
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
                      // Status Banner
                      EditorialSlideUp(
                        child: _buildStatusBanner(_response!, l10n, isTamil),
                      ),
                      const SizedBox(height: 16),

                      // First Class NO DATA state
                      if (_response!.status == ResponseStatus.noData) ...[
                        EditorialSlideUp(
                          child: Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              border: Border.all(color: AppColors.error, width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.block, color: AppColors.error, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.text('statusNoData'),
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.error,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.text('noDataExplanation'),
                                  style: const TextStyle(fontSize: 13.5, color: AppColors.paper, height: 1.5),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'SELECTED BLOCK: ${_response!.blockName.toUpperCase()} BLOCK',
                                      style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundMuted),
                                    ),
                                    Text(
                                      DateFormatter.formatDataAge(_response!.averageDataAgeDays, locale: localeNotifier.languageCode),
                                      style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w700, color: AppColors.warning),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        // Thin Grounding Indicator Bar
                        EditorialSlideUp(
                          delay: const Duration(milliseconds: 50),
                          child: ThinGroundingIndicator(
                            score: _response!.groundingScore,
                            label: l10n.text('secGrounding'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Structured Non-ChatGPT Response Grid
                        EditorialSlideUp(
                          delay: const Duration(milliseconds: 100),
                          child: FieldNotebookCard(
                            title: 'DETERMINISTIC AGRICULTURAL ADVISORY',
                            subtitle: '${_response!.districtName} District · ${_response!.blockName} Block · ${_response!.cropName} (${_response!.growthStage})',
                            tagText: 'RULE EVALUATED',
                            tagColor: AppColors.field,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // RECOMMENDATION
                                _buildStructuredSection(
                                  label: l10n.text('secRecommendation'),
                                  text: isTamil && _response!.recommendationSummaryTamil.isNotEmpty
                                      ? _response!.recommendationSummaryTamil
                                      : _response!.recommendationSummary,
                                  color: AppColors.straw,
                                  isHeadline: true,
                                ),
                                const Divider(height: 20),

                                // WHAT TO DO
                                _buildStructuredSection(
                                  label: l10n.text('secWhatToDo'),
                                  text: isTamil && _response!.whatToDoTamil.isNotEmpty
                                      ? _response!.whatToDoTamil
                                      : _response!.whatToDo,
                                  color: AppColors.paper,
                                ),
                                const Divider(height: 20),

                                // WHEN & HOW MUCH
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isCompact = constraints.maxWidth < 450;
                                    return isCompact
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildStructuredSection(
                                                label: l10n.text('secWhen'),
                                                text: isTamil && _response!.whenToApplyTamil.isNotEmpty
                                                    ? _response!.whenToApplyTamil
                                                    : _response!.whenToApply,
                                                color: AppColors.leaf,
                                              ),
                                              const SizedBox(height: 12),
                                              _buildStructuredSection(
                                                label: l10n.text('secHowMuch'),
                                                text: isTamil && _response!.howMuchAmountTamil.isNotEmpty
                                                    ? _response!.howMuchAmountTamil
                                                    : _response!.howMuchAmount,
                                                color: AppColors.straw,
                                              ),
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: _buildStructuredSection(
                                                  label: l10n.text('secWhen'),
                                                  text: isTamil && _response!.whenToApplyTamil.isNotEmpty
                                                      ? _response!.whenToApplyTamil
                                                      : _response!.whenToApply,
                                                  color: AppColors.leaf,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: _buildStructuredSection(
                                                  label: l10n.text('secHowMuch'),
                                                  text: isTamil && _response!.howMuchAmountTamil.isNotEmpty
                                                      ? _response!.howMuchAmountTamil
                                                      : _response!.howMuchAmount,
                                                  color: AppColors.straw,
                                                ),
                                              ),
                                            ],
                                          );
                                  },
                                ),
                                const Divider(height: 20),

                                // WHY RATIONALE
                                _buildStructuredSection(
                                  label: l10n.text('secWhy'),
                                  text: isTamil && _response!.whyReasonTamil.isNotEmpty
                                      ? _response!.whyReasonTamil
                                      : _response!.whyReason,
                                  color: AppColors.foregroundMuted,
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHighlight,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RULE PROVENANCE: ${_response!.ruleId}',
                                        style: const TextStyle(fontSize: 10.0, fontFamily: 'monospace', color: AppColors.straw),
                                      ),
                                      Text(
                                        DateFormatter.formatDataAge(_response!.averageDataAgeDays, locale: localeNotifier.languageCode),
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.leaf),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Clarification Form if needed
                      if (_response!.status == ResponseStatus.clarificationNeeded) ...[
                        EditorialSlideUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildClarificationCard(_response!, l10n, isTamil),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Evidence Drawer & Citations Panel
                      EditorialSlideUp(
                        delay: const Duration(milliseconds: 300),
                        child: EvidenceDrawer(
                          response: _response!,
                          locale: localeNotifier.languageCode,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Test Scenarios Switcher
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
                              'TESTBED SCENARIO LAUNCHER',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.straw, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildScenarioChip('grounded', 'Grounded Paddy (Budalur)', widget.scenarioKey == 'grounded'),
                                _buildScenarioChip('clarification_location', 'Missing Location Clarification', widget.scenarioKey == 'clarification_location'),
                                _buildScenarioChip('no_data', 'No Data for Block (Kadaladi)', widget.scenarioKey == 'no_data'),
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

  Widget _buildStructuredSection({
    required String label,
    required String text,
    required Color color,
    bool isHeadline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w700,
            color: AppColors.foregroundSubtle,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: isHeadline ? AppTheme.fontFootlight : null,
            fontSize: isHeadline ? 18.0 : 13.5,
            color: color,
            height: isHeadline ? 1.25 : 1.45,
          ),
        ),
      ],
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 500;
          return isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: border, size: 18),
                        const SizedBox(width: 8),
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
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'TIED TO LOCATION: ${res.districtName.toUpperCase()} · ${res.blockName.toUpperCase()} BLOCK',
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: AppColors.straw,
                      ),
                    ),
                  ],
                )
              : Row(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'LOCATION: ${res.districtName} (${res.blockName} Block)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          color: AppColors.straw,
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildClarificationCard(RagResponse res, AppLocalizations l10n, bool isTamil) {
    return FieldNotebookCard(
      title: l10n.text('clarificationNeededHeader'),
      subtitle: l10n.text('missingContextPrompt'),
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
                        id: 'RESP-CLARIFIED-SUCCESS',
                        queryId: res.queryId,
                        responseText:
                            'Grounded Advisory for Thanjavur (Budalur block): Spray Tricyclazole 75% WP @ 0.6 g/L water. Maintain 50 kg/ha Potash split dosing.',
                        responseTextTamil:
                            'தஞ்சாவூர் பூதலூர் வட்டாரத்திற்குரிய ஆவணப் பரிந்துரை: ட்ரைசைக்ளசோல் 75% WP (0.6 கிராம்/லிட்டர்) தெளிக்கவும்.',
                        recommendationSummary: 'Tricyclazole 75% WP @ 0.6 g/L spray with Potash topdressing.',
                        recommendationSummaryTamil: 'ட்ரைசைக்ளசோல் 75% WP (0.6 கிராம்/லிட்டர்) தெளிப்பு.',
                        whatToDo: 'Apply foliar spray at first blast lesion appearance.',
                        whatToDoTamil: 'முதல் நோய் அறிகுறி கண்டவுடன் தெளிக்கவும்.',
                        whenToApply: 'Morning hours (7:00 AM - 10:00 AM) on dry foliage.',
                        whenToApplyTamil: 'காலை 7:00 - 10:00 மணிக்குள் இலை உலர்வாக இருக்கும்போது.',
                        howMuchAmount: '0.6 g/L water (500 g/ha) + 50 kg/ha MOP.',
                        howMuchAmountTamil: '0.6 கிராம்/லிட்டர் + 50 கிலோ பொட்டாஷ்.',
                        whyReason: 'Cauvery Delta clay soils under high humidity require triazole systemic protection.',
                        whyReasonTamil: 'காவேரி டெல்டா நிலங்களில் ட்ரைசைக்ளசோல் 92.4% பாதுகாப்பு அளிக்கிறது.',
                        groundingScore: 0.94,
                        ruleId: 'RULE-TNAU-BLAST-01',
                        citedProvenance: 'TNAU Crop Production Guide 2025',
                        language: res.language,
                        isGrounded: true,
                        status: ResponseStatus.grounded,
                        stateName: 'Tamil Nadu',
                        districtName: 'Thanjavur',
                        blockName: 'Budalur',
                        cropName: 'Paddy / Rice',
                        growthStage: 'Tillering Phase',
                        season: 'Kuruvai 2025',
                        averageDataAgeDays: 14,
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

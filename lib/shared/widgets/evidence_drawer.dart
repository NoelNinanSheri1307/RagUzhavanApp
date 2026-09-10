import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/evidence_source.dart';
import '../../data/models/rag_response.dart';
import '../animations/editorial_transitions.dart';

class EvidenceDrawer extends StatefulWidget {
  final RagResponse response;
  final String locale;

  const EvidenceDrawer({
    super.key,
    required this.response,
    required this.locale,
  });

  @override
  State<EvidenceDrawer> createState() => _EvidenceDrawerState();
}

class _EvidenceDrawerState extends State<EvidenceDrawer> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.response.status == ResponseStatus.noData) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 1.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Text(
                  l10n.text('statusNoData'),
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.text('noDataExplanation'),
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.foreground,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              DateFormatter.formatDataAge(widget.response.averageDataAgeDays, locale: widget.locale),
              style: const TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      );
    }

    final sources = widget.response.evidenceSources;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.article_outlined, color: AppColors.straw, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${l10n.text('evidenceCount')}: ${sources.length}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFootlight,
                        fontSize: 16.0,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      border: Border.all(color: AppColors.field),
                    ),
                    child: Text(
                      DateFormatter.formatDataAge(widget.response.averageDataAgeDays, locale: widget.locale),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.leaf,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.foregroundMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          UnfoldCard(
            isExpanded: _isExpanded,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14.0),
              itemCount: sources.length,
              separatorBuilder: (context, index) => const Divider(height: 20.0),
              itemBuilder: (context, index) {
                final source = sources[index];
                return _buildEvidenceItem(source, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(EvidenceSource source, AppLocalizations l10n) {
    final excerptText = widget.locale == 'ta' && source.excerptTamil.isNotEmpty
        ? source.excerptTamil
        : source.excerpt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                source.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                  height: 1.3,
                ),
              ),
            ),
            if (source.isVerified)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.field),
                ),
                child: Text(
                  widget.locale == 'ta' ? 'உறுதி செய்யப்பட்டது' : 'VERIFIED',
                  style: const TextStyle(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.leaf,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              source.authorOrInstitute,
              style: const TextStyle(
                fontSize: 11.0,
                color: AppColors.straw,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(' · ', style: TextStyle(color: AppColors.foregroundSubtle)),
            Text(
              '${l10n.text('publicationDate')}: ${source.publicationDate}',
              style: const TextStyle(
                fontSize: 11.0,
                color: AppColors.foregroundMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            color: AppColors.surfaceHighlight,
            border: Border(left: BorderSide(color: AppColors.straw, width: 2.0)),
          ),
          child: Text(
            '"$excerptText"',
            style: const TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: AppColors.paper,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormatter.formatConfidence(source.confidenceScore, locale: widget.locale),
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.foregroundSubtle,
              ),
            ),
            Text(
              'REF: ${source.urlOrRef}',
              style: const TextStyle(
                fontSize: 10.0,
                fontFamily: 'monospace',
                color: AppColors.foregroundSubtle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

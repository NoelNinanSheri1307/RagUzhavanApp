import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../data/models/rag_query.dart';
import '../../data/models/crop_context.dart';
import '../../data/models/low_bandwidth_message.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/repositories/mock_rag_repository.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/animations/editorial_transitions.dart';

class LowBandwidthScreen extends StatefulWidget {
  const LowBandwidthScreen({super.key});

  @override
  State<LowBandwidthScreen> createState() => _LowBandwidthScreenState();
}

class _LowBandwidthScreenState extends State<LowBandwidthScreen> {
  final RagRepository _repository = MockRagRepository();
  final _smsController = TextEditingController(
    text: 'Rice blast spray Budalur block Thanjavur Kuruvai paddy',
  );
  LowBandwidthMessage? _lastMessage;
  bool _isTransmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

    final payloadKb = _lastMessage?.payloadSizeKb ?? 1.8;
    final maxKb = _lastMessage?.maxConstraintKb ?? 50.0;
    final pctUsed = (payloadKb / maxKb).clamp(0.0, 1.0);

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('lowBandwidthHeader'),
        showBackButton: true,
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer/low-bandwidth'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 50 KB Engineering Constraint Metric Box
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    border: Border.all(color: AppColors.straw, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cell_tower, color: AppColors.straw, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.text('exchangeSize').toUpperCase(),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.straw, letterSpacing: 0.8),
                              ),
                            ],
                          ),
                          Text(
                            '${payloadKb.toStringAsFixed(1)} KB / ${maxKb.toStringAsFixed(1)} KB',
                            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppColors.leaf),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar for 50 KB Limit
                      Stack(
                        children: [
                          Container(height: 4, width: double.infinity, color: AppColors.surfaceHighlight),
                          FractionallySizedBox(
                            widthFactor: pctUsed,
                            child: Container(height: 4, color: AppColors.leaf),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.text('constraintLimit'),
                        style: const TextStyle(fontSize: 10.5, color: AppColors.foregroundSubtle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SMS Form Card
                FieldNotebookCard(
                  title: '2G SMS PACKET GATEWAY SIMULATOR',
                  subtitle: l10n.text('lowBandwidthSubheader'),
                  tagText: 'SMS GATEWAY',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('questionPlaceholder').toUpperCase(),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _smsController,
                        style: const TextStyle(fontSize: 13.5, color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'Enter query for SMS compression',
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isTransmitting ? null : _sendSmsQuery,
                          child: _isTransmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background)),
                                    SizedBox(width: 8),
                                    Text('Compressing to 1.8 KB payload...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(l10n.text('sendSmsQuery')),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.send, size: 16),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SMS Thread View
                if (_lastMessage != null) ...[
                  EditorialSlideUp(
                    child: FieldNotebookCard(
                      title: 'RECEIVED SMS THREAD',
                      subtitle: 'Packet ID: ${_lastMessage!.id}',
                      tagText: 'SMS DELIVERED (1.8 KB)',
                      tagColor: AppColors.leaf,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSmsBubble(
                            label: 'RECOMMENDATION',
                            content: isTamil ? _lastMessage!.recommendationTamil : _lastMessage!.recommendation,
                            color: AppColors.paper,
                          ),
                          const SizedBox(height: 10),
                          _buildSmsBubble(
                            label: l10n.text('essentialReason'),
                            content: isTamil ? _lastMessage!.essentialReasonTamil : _lastMessage!.essentialReason,
                            color: AppColors.straw,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SOURCE: ${_lastMessage!.citedSource}',
                                style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.foregroundMuted),
                              ),
                              Text(
                                'PUB: ${_lastMessage!.publicationDate} (${_lastMessage!.dataAgeDays}d old)',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.leaf),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                FieldNotebookCard(
                  title: 'OFFLINE TRANSMISSION SPECS',
                  subtitle: 'Architectural breakdown of low-bandwidth engine',
                  tagText: 'TECHNICAL DEEP DIVE',
                  tagColor: AppColors.field,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSpecItem(
                        title: '1. Binary Message Compression',
                        desc: 'Queries are encoded with 8-bit district IDs and crop enums reducing packet overhead from 4.5 KB to 1.8 KB.',
                      ),
                      const Divider(height: 16),
                      _buildSpecItem(
                        title: '2. Offline Store & Forward',
                        desc: 'When cellular connection drops, queries are persisted locally and synced automatically when connection recovers.',
                      ),
                      const Divider(height: 16),
                      _buildSpecItem(
                        title: '3. 50 KB Maximum Constraint',
                        desc: 'Strict upper limit ensures compatibility with rural GSM SMS gateways and 2G EDGE cellular towers.',
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

  Widget _buildSmsBubble({required String label, required String content, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        border: Border(left: BorderSide(color: color, width: 2.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle, letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: color, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem({required String title, required String desc}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: AppColors.paper)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 12.0, color: AppColors.foregroundMuted, height: 1.4)),
      ],
    );
  }

  Future<void> _sendSmsQuery() async {
    setState(() => _isTransmitting = true);
    final query = RagQuery(
      id: 'QUERY-SMS-${DateTime.now().millisecondsSinceEpoch}',
      questionText: _smsController.text,
      language: Provider.of<LocaleNotifier>(context, listen: false).languageCode,
      regionId: 'thanjavur_budalur',
      cropContext: const CropContext(
        cropName: 'Paddy',
        growthStage: 'Tillering',
        irrigationType: 'Canal',
        soilPH: '6.8',
        moistureLevel: 'High',
        season: 'Kuruvai',
      ),
      timestamp: DateTime.now(),
      isLowBandwidth: true,
    );

    final msg = await _repository.sendLowBandwidthQuery(query);
    if (mounted) {
      setState(() {
        _lastMessage = msg;
        _isTransmitting = false;
      });
    }
  }
}

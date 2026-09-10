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
    text: 'Rice blast fungicide Thanjavur Kuruvai clay soil',
  );
  LowBandwidthMessage? _lastMessage;
  bool _isTransmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

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
                FieldNotebookCard(
                  title: 'COMPRESSED SMS PACKET ENGINE',
                  subtitle: l10n.text('lowBandwidthSubheader'),
                  tagText: '2G / SMS MODE',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.signal_cellular_alt_1_bar, color: AppColors.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isTamil ? 'அலைவரிசை நிலை: 2G / SMS வழி இயங்குகிறது' : 'Network Link: 2G / Edge SMS Gateway Active',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.warning),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.straw),
                            ),
                            child: const Text(
                              'PAYLOAD: 1.1 KB',
                              style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700, color: AppColors.straw),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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
                                    Text('Compressing & Enqueuing SMS...'),
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

                if (_lastMessage != null) ...[
                  EditorialSlideUp(
                    child: FieldNotebookCard(
                      title: 'TRANSMITTED SMS DIGEST',
                      subtitle: 'ID: ${_lastMessage!.id}',
                      tagText: 'SMS DELIVERED',
                      tagColor: AppColors.leaf,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${l10n.text('payloadSize')}: ${_lastMessage!.payloadSizeKb} KB',
                                style: const TextStyle(fontSize: 11.0, color: AppColors.straw),
                              ),
                              Text(
                                '${l10n.text('queueStatus')}: ${_lastMessage!.queueStatus.toUpperCase()}',
                                style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w700, color: AppColors.leaf),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHighlight,
                              border: Border.all(color: AppColors.borderBright),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'COMPRESSED SMS RESPONSE:',
                                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isTamil && _lastMessage!.compressedSummaryTamil.isNotEmpty
                                      ? _lastMessage!.compressedSummaryTamil
                                      : _lastMessage!.compressedSummary,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13.0,
                                    color: AppColors.paper,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
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
                        desc: 'Queries are encoded with 8-bit district IDs and crop enums reducing packet overhead from 4.5 KB to 1.1 KB.',
                      ),
                      const Divider(height: 16),
                      _buildSpecItem(
                        title: '2. Offline Store & Forward',
                        desc: 'When cellular connection drops, queries are persisted locally and synced automatically when connection recovers.',
                      ),
                      const Divider(height: 16),
                      _buildSpecItem(
                        title: '3. Citation Hash References',
                        desc: 'Full document citations are replaced with compact TNAU/ICAR registry hashes for offline verification.',
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
      regionId: 'thanjavur_01',
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

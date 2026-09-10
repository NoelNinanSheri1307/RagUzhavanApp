import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  bool _guardrailsEnabled = true;
  List<dynamic> _sources = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final settings = await apiService.getAdminSettings();
      final sourcesList = await apiService.getSources();

      if (mounted) {
        setState(() {
          if (settings != null && settings['guardrails_enabled'] != null) {
            _guardrailsEnabled = settings['guardrails_enabled'] as bool;
          }
          if (sourcesList != null) {
            _sources = sourcesList;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleGuardrails(bool newValue) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _guardrailsEnabled = newValue;
    });

    try {
      await apiService.updateAdminSettings(newValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guardrails set to: ${newValue ? "ENABLED" : "DISABLED"}'),
            backgroundColor: newValue ? AppColors.leaf : AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update guardrails: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditorialHeader(
        title: 'ADMIN KNOWLEDGE BASE CONTROL',
        subtitle: 'Railway RAG Retrieval System Settings & Ingested Document Management',
        showBackButton: true,
        onBack: () => context.go('/farmer'),
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/admin'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.straw))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Real System Metrics
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 600;
                          if (isCompact) {
                            return Column(
                              children: [
                                _buildAdminMetricCard(
                                  title: 'INGESTED SOURCES',
                                  value: '${_sources.length}',
                                  subtext: 'Chroma Vector Documents',
                                  color: AppColors.straw,
                                ),
                                const SizedBox(height: 10),
                                _buildAdminMetricCard(
                                  title: 'RETRIEVAL GUARDRAILS',
                                  value: _guardrailsEnabled ? 'ACTIVE' : 'DISABLED',
                                  subtext: 'Strict agricultural filtering',
                                  color: _guardrailsEnabled ? AppColors.field : AppColors.warning,
                                ),
                                const SizedBox(height: 10),
                                _buildAdminMetricCard(
                                  title: 'VECTOR PIPELINE',
                                  value: 'ONLINE',
                                  subtext: 'Railway Backend Live',
                                  color: AppColors.leaf,
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: _buildAdminMetricCard(
                                  title: 'INGESTED SOURCES',
                                  value: '${_sources.length}',
                                  subtext: 'Chroma Vector Documents',
                                  color: AppColors.straw,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAdminMetricCard(
                                  title: 'RETRIEVAL GUARDRAILS',
                                  value: _guardrailsEnabled ? 'ACTIVE' : 'DISABLED',
                                  subtext: 'Strict agricultural filtering',
                                  color: _guardrailsEnabled ? AppColors.field : AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAdminMetricCard(
                                  title: 'VECTOR PIPELINE',
                                  value: 'ONLINE',
                                  subtext: 'Railway Backend Live',
                                  color: AppColors.leaf,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // System Guardrails Toggle Card (PATCH /admin/settings)
                      FieldNotebookCard(
                        title: 'RAG GUARDRAILS & RETRIEVAL SETTINGS (PATCH /admin/settings)',
                        subtitle: 'Control evidence grounding enforcement for all user agricultural queries',
                        tagText: 'SYSTEM POLICY',
                        tagColor: AppColors.straw,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enforce Agricultural Evidence Guardrails',
                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.paper),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'When enabled, non-agricultural queries are filtered out with strict evidence verification.',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _guardrailsEnabled,
                              onChanged: _toggleGuardrails,
                              activeThumbColor: AppColors.straw,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ingested Sources Management (GET /sources)
                      FieldNotebookCard(
                        title: 'INGESTED KNOWLEDGE BASE SOURCES (GET /sources)',
                        subtitle: 'Document corpus used for retrieval grounding in RAG queries',
                        tagText: 'CHROMA DB SOURCES',
                        tagColor: AppColors.leaf,
                        trailing: ElevatedButton(
                          onPressed: () => context.go('/admin/farmers'),
                          child: const Text('MANAGE SOURCES'),
                        ),
                        child: _sources.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  'No ingested documents currently in backend vector store.',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.foregroundMuted),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sources.length > 4 ? 4 : _sources.length,
                                separatorBuilder: (context, index) => const Divider(height: 16),
                                itemBuilder: (context, index) {
                                  final src = _sources[index];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              src['name']?.toString() ?? src['title']?.toString() ?? 'Knowledge Document #${src['id']}',
                                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.paper),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Chunks: ${src['chunk_count'] ?? src['chunks'] ?? 12} · Category: ${src['category'] ?? "Extension Bulletin"}',
                                              style: const TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.successBg,
                                          border: Border.all(color: AppColors.field),
                                        ),
                                        child: const Text(
                                          'INDEXED',
                                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.leaf),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Knowledge Graph Link
                      FieldNotebookCard(
                        title: 'VISUAL KNOWLEDGE GRAPH (GET /sources/graph)',
                        subtitle: 'Interactive node graph connecting agricultural sources, topics, and crop categories',
                        tagText: 'GRAPH VISUALIZER',
                        tagColor: AppColors.field,
                        trailing: ElevatedButton(
                          onPressed: () => context.go('/graph'),
                          child: const Text('OPEN GRAPH'),
                        ),
                        child: const Text(
                          'Explore entity relations, citations, and structural cross-links within the agricultural knowledge base.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.foregroundMuted),
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

  Widget _buildAdminMetricCard({
    required String title,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontFootlight,
              fontSize: 24.0,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(fontSize: 11.0, color: AppColors.foregroundMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


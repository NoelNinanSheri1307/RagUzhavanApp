import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class AdminFarmersScreen extends StatefulWidget {
  const AdminFarmersScreen({super.key});

  @override
  State<AdminFarmersScreen> createState() => _AdminFarmersScreenState();
}

class _AdminFarmersScreenState extends State<AdminFarmersScreen> {
  List<dynamic> _sources = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final list = await apiService.getSources();
      if (mounted) {
        setState(() {
          _sources = list ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load sources from Railway backend: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSource(int id, String name) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Delete Source Document?', style: TextStyle(color: AppColors.paper)),
        content: Text('Are you sure you want to remove "$name" from Chroma DB vector store?', style: const TextStyle(color: AppColors.foregroundMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deleteSource(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document "$name" removed successfully.'), backgroundColor: AppColors.leaf),
          );
          _loadSources();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete document: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditorialHeader(
        title: 'Knowledge Bulletins',
        subtitle: 'Verified agricultural bulletins & research documents',
        showBackButton: true,
        onBack: () => context.go('/admin'),
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/admin/farmers'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.straw))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'VERIFIED AGRICULTURE BULLETINS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.leaf,
                              letterSpacing: 1.0,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.straw),
                            onPressed: _loadSources,
                            tooltip: 'Refresh Corpus',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.paper)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      FieldNotebookCard(
                        title: 'Verified Document Corpus (${_sources.length})',
                        subtitle: 'Official university bulletins powering grounded farming recommendations',
                        tagText: 'BULLETINS',
                        tagColor: AppColors.straw,
                        child: _sources.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: Text(
                                    'No knowledge documents ingested in the backend.',
                                    style: TextStyle(fontSize: 13, color: AppColors.foregroundMuted),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sources.length,
                                separatorBuilder: (context, index) => const Divider(height: 24, thickness: 1),
                                itemBuilder: (context, index) {
                                  final src = _sources[index];
                                  final id = src['id'] is int ? src['id'] as int : int.tryParse(src['id']?.toString() ?? '0') ?? 0;
                                  final name = src['name']?.toString() ?? src['title']?.toString() ?? 'Knowledge Document #$id';
                                  final chunkCount = src['chunk_count'] ?? src['chunks'] ?? 12;
                                  final category = src['category']?.toString() ?? 'Extension Bulletin';

                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceHighlight,
                                          border: Border.all(color: AppColors.straw),
                                        ),
                                        child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.straw, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontFamily: AppTheme.fontFootlight,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.foreground,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ID: $id · Chunks: $chunkCount · Category: $category',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontFamily: 'monospace',
                                                color: AppColors.foregroundSubtle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () => _deleteSource(id, name),
                                        tooltip: 'Remove Document',
                                      ),
                                    ],
                                  );
                                },
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
}


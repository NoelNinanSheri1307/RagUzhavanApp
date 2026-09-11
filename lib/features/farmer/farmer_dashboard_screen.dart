import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/models/chat_session_model.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/soil_texture_painter.dart';
import '../../shared/widgets/agricultural_easter_eggs.dart';
import '../../shared/animations/editorial_transitions.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  bool _isLoadingSessions = true;
  bool _isMonsoonActive = false;
  List<ChatSessionModel> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoadingSessions = true);
    final ragRepo = Provider.of<RagRepository>(context, listen: false);
    try {
      final list = await ragRepo.getSessions();
      setState(() {
        _sessions = list;
        _isLoadingSessions = false;
      });
    } catch (_) {
      setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _handleNewSession() async {
    final ragRepo = Provider.of<RagRepository>(context, listen: false);
    final newSession = await ragRepo.createSession();
    if (mounted && newSession != null) {
      context.go('/farmer/ask?session_id=${newSession.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final l10n = AppLocalizations.of(context);
    final farmer = authService.currentFarmer;

    return MonsoonOverlay(
      isMonsoonActive: _isMonsoonActive,
      onCloseMonsoon: () => setState(() => _isMonsoonActive = false),
      child: Scaffold(
        appBar: EditorialHeader(
          title: authService.isAdmin ? 'ADMIN OVERVIEW' : l10n.text('farmerDashboardTitle'),
          subtitle: farmer != null
              ? '${farmer.state} · ${farmer.district} (${farmer.block} Block) · ${farmer.crops.join(", ")}'
              : 'Region-Aware Agricultural Intelligence',
          onTriggerMonsoon: () {
            setState(() => _isMonsoonActive = !_isMonsoonActive);
          },
        ),
        bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer'),
        body: SoilTextureBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Scope Summary Card
                    EditorialSlideUp(
                      delay: const Duration(milliseconds: 100),
                      child: GestureDetector(
                        onLongPress: () => SoilHealthDiagnosticDialog.show(context),
                        child: FieldNotebookCard(
                          title: 'FARMER INTELLIGENCE SCOPE',
                          subtitle: farmer != null
                              ? 'State: ${farmer.state} · District: ${farmer.district} · Block: ${farmer.block}'
                              : 'Active Agro-Climatic Scope',
                          tagText: 'LIVE FIELD SCOPE',
                          tagColor: AppColors.leaf,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Primary Crop: ${farmer?.crops.isNotEmpty == true ? farmer!.crops.first : "Paddy / Rice"}',
                                      style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: AppColors.paper),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Agro Zone: ${farmer?.agroZone ?? "Cauvery Delta"} · Season: ${farmer?.season ?? "Kuruvai"}',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.grass, size: 20, color: AppColors.straw),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Action Button: New RAG Query
                    EditorialSlideUp(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 52),
                        child: ElevatedButton.icon(
                          onPressed: _handleNewSession,
                          icon: const Icon(Icons.add_comment_outlined, size: 20),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              l10n.text('askQuestion'),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.straw,
                            foregroundColor: AppColors.background,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            shape: const RoundedRectangleBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Real Chat Sessions Section
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.chat_bubble_outline, color: AppColors.straw, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'ACTIVE RAG CHAT SESSIONS',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFootlight,
                                        fontSize: 16.0,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: AppColors.straw, size: 18),
                                  onPressed: _fetchSessions,
                                  tooltip: 'Refresh Sessions',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (_isLoadingSessions)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(color: AppColors.straw),
                                ),
                              )
                            else if (_sessions.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighlight,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Text(
                                  'No chat sessions created yet. Tap "ASK RAGUZHAVAN QUESTION" above to start asking agricultural questions grounded in Railway backend vector data.',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.foregroundMuted, height: 1.4),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sessions.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final session = _sessions[index];
                                  return InkWell(
                                    onTap: () => context.go('/farmer/ask?session_id=${session.id}'),
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceHighlight,
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.article_outlined, color: AppColors.leaf, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  session.title,
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.paper,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Session #${session.id} · ${session.createdAt.toString().split(".").first}',
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    fontFamily: 'monospace',
                                                    color: AppColors.foregroundSubtle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.foregroundMuted, size: 18),
                                            onPressed: () async {
                                              final ragRepo = Provider.of<RagRepository>(context, listen: false);
                                              await ragRepo.deleteSession(session.id);
                                              _fetchSessions();
                                            },
                                            tooltip: 'Delete Session',
                                          ),
                                          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.straw),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
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
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/config/app_config.dart';
import '../../data/services/auth_service.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    const config = AppConfig();
    _apiUrlController.text = config.apiBaseUrl;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final authService = Provider.of<AuthService>(context);
    const config = AppConfig();
    final isTamil = localeNotifier.languageCode == 'ta';

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('navSettings'),
        showBackButton: true,
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer/settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldNotebookCard(
                  title: l10n.text('language'),
                  subtitle: 'Switch application-wide UI text language',
                  tagText: 'LOCALIZATION',
                  tagColor: AppColors.straw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTamil ? 'தற்போது: தமிழ் (Tamil)' : 'Current: English',
                            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.paper),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isTamil ? 'அனைத்து முகப்பு உரைகளும் தமிழில் மாறும்' : 'All UI text, navigation, and badges rendered in English',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => localeNotifier.toggleLanguage(),
                        child: Text(l10n.text('switchLanguage')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                FieldNotebookCard(
                  title: 'BACKEND INTEGRATION CONFIG (DIO HUB)',
                  subtitle: 'Single source of truth for RAG backend integration',
                  tagText: 'ARCHITECTURE',
                  tagColor: AppColors.field,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: config.isMockMode ? AppColors.warningBg : AppColors.successBg,
                              border: Border.all(color: config.isMockMode ? AppColors.warning : AppColors.field),
                            ),
                            child: Text(
                              config.isMockMode ? 'MOCK MODE ACTIVE' : 'REMOTE DIO CONNECTED',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: config.isMockMode ? AppColors.warning : AppColors.leaf,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.text('mockModeNotice'),
                              style: const TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        l10n.text('apiEndpoint').toUpperCase(),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _apiUrlController,
                        style: const TextStyle(fontSize: 13.0, fontFamily: 'monospace', color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'e.g. https://raguzhavan-backend.up.railway.app',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Note: When API_BASE_URL is empty, ApiRagRepository automatically falls back to MockRagRepository. Backend integration can be enabled instantly by providing the Railway URL.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.foregroundSubtle, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                FieldNotebookCard(
                  title: 'PORTAL ROLE SWITCHER',
                  subtitle: 'Switch between Farmer and Admin interface modes',
                  tagText: 'MOCK ROLE',
                  tagColor: AppColors.leaf,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURRENT ROLE: ${authService.role.name.toUpperCase()}',
                        style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: AppColors.straw),
                      ),
                      Row(
                        children: [
                          if (!authService.isAdmin)
                            OutlinedButton(
                              onPressed: () {
                                authService.switchRole(UserRole.admin);
                                context.go('/admin');
                              },
                              child: const Text('Switch to Admin'),
                            )
                          else
                            OutlinedButton(
                              onPressed: () {
                                authService.switchRole(UserRole.farmer);
                                context.go('/farmer');
                              },
                              child: const Text('Switch to Farmer'),
                            ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              authService.logout();
                              context.go('/login');
                            },
                            child: Text(l10n.text('logout'), style: const TextStyle(color: AppColors.error)),
                          ),
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
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/config/app_config.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/soil_texture_painter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiUrlController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _cropController = TextEditingController();

  bool _isLoadingProfile = false;
  bool _isSavingProfile = false;
  String? _profileMessage;

  @override
  void initState() {
    super.initState();
    const config = AppConfig();
    _apiUrlController.text = config.apiBaseUrl;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.currentFarmer != null) {
      _fullNameController.text = authService.currentFarmer!.name;
      _phoneController.text = authService.currentFarmer!.phone;
      _districtController.text = authService.currentFarmer!.district;
      _cropController.text = authService.currentFarmer!.crops.isNotEmpty
          ? authService.currentFarmer!.crops.join(', ')
          : 'Paddy';
    }

    if (!apiService.hasBaseUrl) return;

    setState(() => _isLoadingProfile = true);
    try {
      final userMap = await apiService.getCurrentUser();
      if (userMap != null && mounted) {
        setState(() {
          if (userMap['full_name'] != null) _fullNameController.text = userMap['full_name'];
          if (userMap['phone'] != null) _phoneController.text = userMap['phone'];
          if (userMap['district'] != null) _districtController.text = userMap['district'];
          if (userMap['primary_crop'] != null) _cropController.text = userMap['primary_crop'];
        });
      }
    } catch (_) {
      // Keep existing local defaults if disconnected
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _saveUserProfile() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _isSavingProfile = true;
      _profileMessage = null;
    });

    final name = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final district = _districtController.text.trim();
    final cropStr = _cropController.text.trim();
    final cropsList = cropStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // Update local app state immediately
    authService.updateFarmerDetails(
      name: name,
      phone: phone,
      district: district,
      crops: cropsList.isNotEmpty ? cropsList : ['Paddy / Rice'],
    );

    try {
      if (apiService.hasBaseUrl) {
        await apiService.updateUserProfile({
          'full_name': name,
          'phone': phone,
          'district': district,
          'primary_crop': cropStr,
        });
        if (mounted) {
          setState(() {
            _profileMessage = '✓ Profile synced with backend!';
            _isSavingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _profileMessage = '✓ Profile updated successfully!';
            _isSavingProfile = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _profileMessage = '✓ Profile updated successfully!';
          _isSavingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final authService = Provider.of<AuthService>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('navSettings'),
        showBackButton: true,
      ),
      bottomNavigationBar: const EditorialNavBar(currentPath: '/farmer/settings'),
      body: SoilTextureBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  FieldNotebookCard(
                    title: 'Farmer Profile',
                    subtitle: 'Update your registered agricultural profile details',
                    tagText: 'PROFILE',
                    tagColor: AppColors.leaf,
                    child: _isLoadingProfile
                        ? const Center(child: CircularProgressIndicator(color: AppColors.straw))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FULL NAME',
                                style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.foregroundSubtle),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _fullNameController,
                                style: const TextStyle(fontSize: 13.5, color: AppColors.foreground),
                                decoration: const InputDecoration(hintText: 'Enter full name'),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PHONE NUMBER',
                                          style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.foregroundSubtle),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: _phoneController,
                                          style: const TextStyle(fontSize: 13.5, color: AppColors.foreground),
                                          decoration: const InputDecoration(hintText: '+91...'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'DISTRICT',
                                          style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.foregroundSubtle),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: _districtController,
                                          style: const TextStyle(fontSize: 13.5, color: AppColors.foreground),
                                          decoration: const InputDecoration(hintText: 'e.g. Thanjavur'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Text(
                                'PRIMARY CROP',
                                style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.foregroundSubtle),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _cropController,
                                style: const TextStyle(fontSize: 13.5, color: AppColors.foreground),
                                decoration: const InputDecoration(hintText: 'e.g. Paddy / Rice'),
                              ),
                              const SizedBox(height: 16),

                              if (_profileMessage != null) ...[
                                Text(
                                  _profileMessage!,
                                  style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: AppColors.leaf),
                                ),
                                const SizedBox(height: 12),
                              ],

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSavingProfile ? null : _saveUserProfile,
                                  child: _isSavingProfile
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                                        )
                                      : const Text('Save Profile'),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Language Selector
                  FieldNotebookCard(
                    title: l10n.text('language'),
                    subtitle: 'Switch application-wide UI text language',
                    tagText: 'LOCALIZATION',
                    tagColor: AppColors.straw,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 450;
                        return Flex(
                          direction: isCompact ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                            if (isCompact) const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => localeNotifier.toggleLanguage(),
                              child: Text(l10n.text('switchLanguage')),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Backend integration config
                  FieldNotebookCard(
                    title: 'System Connection',
                    subtitle: 'Connection settings for regional agricultural intelligence',
                    tagText: 'SYSTEM',
                    tagColor: AppColors.field,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                border: Border.all(color: AppColors.field),
                              ),
                              child: const Text(
                                'LOCAL RAG DATABASE',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.leaf,
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
                            hintText: 'e.g. https://backend-production-e510.up.railway.app',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Base URL connects to Railway production deployment. All RAG sessions, questions, graph nodes, and settings sync live with this service.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.foregroundSubtle, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account / Auth Status
                  FieldNotebookCard(
                    title: 'PORTAL ROLE & SESSION',
                    subtitle: 'Logged in session parameters',
                    tagText: 'AUTH',
                    tagColor: AppColors.leaf,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 480;
                        return Flex(
                          direction: isCompact ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CURRENT ROLE: ${authService.role.name.toUpperCase()}',
                              style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: AppColors.straw),
                            ),
                            if (isCompact) const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
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
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/auth_service.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/field_notebook_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '+91 98421 88321');
  final _pinController = TextEditingController(text: '1234');
  UserRole _selectedRole = UserRole.farmer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('loginHeader'),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                FieldNotebookCard(
                  title: 'PORTAL AUTHENTICATION',
                  subtitle: 'Select access mode for frontend state simulation',
                  tagText: 'MOCK ACCESS',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACCESS LEVEL',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _selectedRole = UserRole.farmer),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _selectedRole == UserRole.farmer
                                    ? AppColors.surfaceHighlight
                                    : AppColors.surface,
                                side: BorderSide(
                                  color: _selectedRole == UserRole.farmer
                                      ? AppColors.straw
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                l10n.text('roleFarmer'),
                                style: TextStyle(
                                  color: _selectedRole == UserRole.farmer
                                      ? AppColors.straw
                                      : AppColors.foregroundMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _selectedRole = UserRole.admin),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _selectedRole == UserRole.admin
                                    ? AppColors.surfaceHighlight
                                    : AppColors.surface,
                                side: BorderSide(
                                  color: _selectedRole == UserRole.admin
                                      ? AppColors.straw
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                l10n.text('roleAdmin'),
                                style: TextStyle(
                                  color: _selectedRole == UserRole.admin
                                      ? AppColors.straw
                                      : AppColors.foregroundMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        l10n.text('usernamePlaceholder').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'Enter phone number',
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        l10n.text('passwordPlaceholder').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'Enter PIN',
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            authService.switchRole(_selectedRole);
                            if (_selectedRole == UserRole.admin) {
                              context.go('/admin');
                            } else {
                              context.go('/farmer');
                            }
                          },
                          child: Text(l10n.text('login')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(
                            l10n.text('register'),
                            style: const TextStyle(color: AppColors.leaf, fontSize: 12.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

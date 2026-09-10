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
  final _usernameController = TextEditingController(text: 'farmer1');
  final _passwordController = TextEditingController(text: 'password123');
  UserRole _selectedRole = UserRole.farmer;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter username and password');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.login(
        username: username,
        password: password,
        role: _selectedRole,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          if (_selectedRole == UserRole.admin) {
            context.go('/admin');
          } else {
            context.go('/farmer');
          }
        } else {
          setState(() => _errorMessage = 'Invalid username or password');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceAll('ApiException: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('loginHeader'),
        showBackButton: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/landing');
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 56,
                          width: 56,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.grass, color: AppColors.straw, size: 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'RagUzhavan',
                        style: TextStyle(
                          fontFamily: 'FootlightMTLight',
                          fontSize: 26.0,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Region-Aware Agricultural Intelligence System',
                        style: TextStyle(fontSize: 11.5, color: AppColors.foregroundMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FieldNotebookCard(
                  title: 'PORTAL AUTHENTICATION (POST /token)',
                  subtitle: 'Sign in to access your agricultural RAG sessions and advisory',
                  tagText: 'OAUTH2 AUTH',
                  tagColor: AppColors.straw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACCESS ROLE',
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

                      const Text(
                        'USERNAME OR PHONE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'Enter username or phone',
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foregroundSubtle,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'Enter password',
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12.0, color: AppColors.error, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleLogin,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                                )
                              : Text(l10n.text('login')),
                        ),
                      ),
                      const SizedBox(height: 14),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/farmer.dart';
import '../../data/services/auth_service.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/field_notebook_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(text: 'R. Soundararajan');
  final _phoneController = TextEditingController(text: '+91 94422 10988');
  final _acresController = TextEditingController(text: '5.5');
  String _selectedDistrict = 'Thanjavur';
  String _selectedCrop = 'Paddy';

  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim().isEmpty
        ? _phoneController.text.replaceAll(RegExp(r'\s+'), '')
        : _usernameController.text.trim();
    final password = _passwordController.text.trim().isEmpty
        ? 'password123'
        : _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please provide username and password');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    final farmer = Farmer(
      id: 'FARM-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      district: _selectedDistrict,
      block: 'Budalur',
      state: 'Tamil Nadu',
      preferredLanguage: 'ta',
      crops: [_selectedCrop],
      landSizeAcres: double.tryParse(_acresController.text) ?? 4.0,
      agroZone: 'Cauvery Delta Zone',
      season: 'Kuruvai',
      accountStatus: 'Active',
      lastActivity: DateTime.now(),
    );

    try {
      final success = await authService.registerFarmer(farmer, password: password);
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          context.go('/farmer');
        } else {
          setState(() => _errorMessage = 'Registration failed. Please try again.');
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
        title: l10n.text('register'),
        showBackButton: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/login');
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: FieldNotebookCard(
              title: 'NEW FARMER REGISTRATION (POST /register)',
              subtitle: 'Anchor your profile in official district records and vector store',
              tagText: 'ENROLLMENT',
              tagColor: AppColors.field,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('USERNAME / PHONE KEY', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: AppColors.foreground),
                    decoration: const InputDecoration(hintText: 'e.g. farmer1 or phone number'),
                  ),
                  const SizedBox(height: 14),

                  const Text('PASSWORD', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.foreground),
                    decoration: const InputDecoration(hintText: 'Enter account password'),
                  ),
                  const SizedBox(height: 14),

                  const Text('FULL NAME', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                  const SizedBox(height: 6),
                  TextField(controller: _nameController, style: const TextStyle(color: AppColors.foreground)),
                  const SizedBox(height: 14),

                  const Text('PHONE NUMBER', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                  const SizedBox(height: 6),
                  TextField(controller: _phoneController, style: const TextStyle(color: AppColors.foreground)),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DISTRICT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDistrict,
                              dropdownColor: AppColors.surfaceElevated,
                              items: const [
                                DropdownMenuItem(value: 'Thanjavur', child: Text('Thanjavur')),
                                DropdownMenuItem(value: 'Coimbatore', child: Text('Coimbatore')),
                                DropdownMenuItem(value: 'Ramanathapuram', child: Text('Ramanathapuram')),
                                DropdownMenuItem(value: 'Madurai', child: Text('Madurai')),
                              ],
                              onChanged: (val) => setState(() => _selectedDistrict = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PRIMARY CROP', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCrop,
                              dropdownColor: AppColors.surfaceElevated,
                              items: const [
                                DropdownMenuItem(value: 'Paddy', child: Text('Paddy / Rice')),
                                DropdownMenuItem(value: 'Cotton', child: Text('Cotton')),
                                DropdownMenuItem(value: 'Groundnut', child: Text('Groundnut')),
                                DropdownMenuItem(value: 'Blackgram', child: Text('Blackgram')),
                              ],
                              onChanged: (val) => setState(() => _selectedCrop = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text('LAND HOLDING (ACRES)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.foregroundSubtle)),
                  const SizedBox(height: 6),
                  TextField(controller: _acresController, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.foreground)),
                  const SizedBox(height: 20),

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
                      onPressed: _isSubmitting ? null : _handleRegister,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                            )
                          : Text(l10n.text('register')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

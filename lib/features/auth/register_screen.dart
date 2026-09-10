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
  final _nameController = TextEditingController(text: 'R. Soundararajan');
  final _phoneController = TextEditingController(text: '+91 94422 10988');
  final _acresController = TextEditingController(text: '5.5');
  String _selectedDistrict = 'Thanjavur';
  String _selectedCrop = 'Paddy';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('register'),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: FieldNotebookCard(
              title: 'NEW FARMER REGISTRATION',
              subtitle: 'Anchor your profile in official district records',
              tagText: 'ENROLLMENT',
              tagColor: AppColors.field,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final farmer = Farmer(
                          id: 'FARM-${DateTime.now().millisecondsSinceEpoch}',
                          name: _nameController.text,
                          phone: _phoneController.text,
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
                        authService.loginAsFarmer(farmer);
                        context.go('/farmer');
                      },
                      child: Text(l10n.text('register')),
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

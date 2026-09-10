import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/farmer.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/repositories/mock_rag_repository.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';

class AdminFarmersScreen extends StatefulWidget {
  const AdminFarmersScreen({super.key});

  @override
  State<AdminFarmersScreen> createState() => _AdminFarmersScreenState();
}

class _AdminFarmersScreenState extends State<AdminFarmersScreen> {
  final RagRepository _repository = MockRagRepository();
  List<Farmer> _farmers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    final list = await _repository.fetchFarmersList();
    if (mounted) {
      setState(() {
        _farmers = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('navFarmers'),
        subtitle: 'Registered Farmers & Land Holding Roster',
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
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldNotebookCard(
                        title: 'ENROLLED FARMER ROSTER',
                        subtitle: 'District agricultural records directory',
                        tagText: '${_farmers.length} RECORDS',
                        tagColor: AppColors.straw,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _farmers.length,
                          separatorBuilder: (context, index) => const Divider(height: 20),
                          itemBuilder: (context, index) {
                            final farmer = _farmers[index];
                            return _buildFarmerTile(farmer);
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

  Widget _buildFarmerTile(Farmer farmer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              farmer.name,
              style: const TextStyle(
                fontFamily: AppTheme.fontFootlight,
                fontSize: 17.0,
                color: AppColors.foreground,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.field),
              ),
              child: Text(
                '${farmer.landSizeAcres} ACRES',
                style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700, color: AppColors.leaf),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Phone: ${farmer.phone} · District: ${farmer.district} (${farmer.agroZone})',
          style: const TextStyle(fontSize: 12.0, color: AppColors.foregroundMuted),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: farmer.crops.map((crop) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                crop,
                style: const TextStyle(fontSize: 10.5, color: AppColors.straw),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

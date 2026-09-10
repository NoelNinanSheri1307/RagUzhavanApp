import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/farmer.dart';
import '../../data/repositories/rag_repository.dart';
import '../../data/repositories/mock_rag_repository.dart';
import '../../shared/widgets/editorial_header.dart';
import '../../shared/widgets/editorial_nav_bar.dart';
import '../../shared/widgets/field_notebook_card.dart';
import '../../shared/widgets/api_status_badge.dart';

class AdminFarmersScreen extends StatefulWidget {
  const AdminFarmersScreen({super.key});

  @override
  State<AdminFarmersScreen> createState() => _AdminFarmersScreenState();
}

class _AdminFarmersScreenState extends State<AdminFarmersScreen> {
  final RagRepository _repository = MockRagRepository();
  List<Farmer> _allFarmers = [];
  bool _isLoading = true;

  // Filters
  String _selectedDistrict = 'All';
  String _selectedCrop = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    final list = await _repository.fetchFarmersList();
    if (mounted) {
      setState(() {
        _allFarmers = list;
        _isLoading = false;
      });
    }
  }

  List<Farmer> get _filteredFarmers {
    return _allFarmers.where((farmer) {
      if (_selectedDistrict != 'All' && !farmer.district.contains(_selectedDistrict)) {
        return false;
      }
      if (_selectedCrop != 'All' && !farmer.crops.any((c) => c.toLowerCase().contains(_selectedCrop.toLowerCase()))) {
        return false;
      }
      if (_selectedStatus != 'All' && farmer.accountStatus != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get _districtsList {
    final dists = _allFarmers.map((f) => f.district).toSet().toList();
    dists.sort();
    return ['All', ...dists];
  }

  List<String> get _cropsList => ['All', 'Paddy / Rice', 'Cotton', 'Groundnut', 'Pulses', 'Sugarcane', 'Blackgram', 'Chilli', 'Jasmine'];

  List<String> get _statusList => ['All', 'Active', 'Pending Review', 'Flagged'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filtered = _filteredFarmers;

    return Scaffold(
      appBar: EditorialHeader(
        title: l10n.text('navFarmers'),
        subtitle: 'District Farmer Roster & Regional Status Inspection',
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
                  constraints: const BoxConstraints(maxWidth: 950),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Environment & Status Indicator
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ADMINISTRATIVE REGION ROSTER',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.leaf,
                              letterSpacing: 1.0,
                            ),
                          ),
                          ApiStatusBadge(baseUrl: ''),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Scientific Filter Toolbar
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
                          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.straw),
                                SizedBox(width: 6),
                                Text(
                                  'ROSTER FILTERS',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: AppColors.straw,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 600;
                                return isCompact
                                    ? Column(
                                        children: [
                                          _buildFilterDropdown(
                                            label: 'District',
                                            value: _selectedDistrict,
                                            items: _districtsList,
                                            onChanged: (val) => setState(() => _selectedDistrict = val!),
                                          ),
                                          const SizedBox(height: 10),
                                          _buildFilterDropdown(
                                            label: 'Crop',
                                            value: _selectedCrop,
                                            items: _cropsList,
                                            onChanged: (val) => setState(() => _selectedCrop = val!),
                                          ),
                                          const SizedBox(height: 10),
                                          _buildFilterDropdown(
                                            label: 'Status',
                                            value: _selectedStatus,
                                            items: _statusList,
                                            onChanged: (val) => setState(() => _selectedStatus = val!),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: _buildFilterDropdown(
                                              label: 'District',
                                              value: _selectedDistrict,
                                              items: _districtsList,
                                              onChanged: (val) => setState(() => _selectedDistrict = val!),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildFilterDropdown(
                                              label: 'Crop',
                                              value: _selectedCrop,
                                              items: _cropsList,
                                              onChanged: (val) => setState(() => _selectedCrop = val!),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildFilterDropdown(
                                              label: 'Status',
                                              value: _selectedStatus,
                                              items: _statusList,
                                              onChanged: (val) => setState(() => _selectedStatus = val!),
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Roster Table Card
                      FieldNotebookCard(
                        title: 'ENROLLED FARMER DIRECTORY',
                        subtitle: 'Calm regional table with verified account status and activity logs',
                        tagText: '${filtered.length} OF ${_allFarmers.length} RECORDS',
                        tagColor: AppColors.straw,
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.search_off_outlined, size: 36, color: AppColors.foregroundSubtle),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No farmer records match the selected district, crop, or status filter.',
                                        style: TextStyle(fontSize: 13, color: AppColors.foregroundMuted),
                                      ),
                                      const SizedBox(height: 16),
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedDistrict = 'All';
                                            _selectedCrop = 'All';
                                            _selectedStatus = 'All';
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.straw),
                                          foregroundColor: AppColors.straw,
                                        ),
                                        child: const Text('RESET ALL FILTERS'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const Divider(height: 24, thickness: 1),
                                itemBuilder: (context, index) {
                                  final farmer = filtered[index];
                                  return _buildScientificRow(farmer, isDark);
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

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9.0,
            fontFamily: 'monospace',
            color: AppColors.foregroundSubtle,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            color: AppColors.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(fontSize: 12.5, color: AppColors.foreground),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScientificRow(Farmer farmer, bool isDark) {
    Color statusColor;
    Color statusBg;

    switch (farmer.accountStatus) {
      case 'Active':
        statusColor = AppColors.accentGreen;
        statusBg = AppColors.accentGreen.withValues(alpha: 0.12);
        break;
      case 'Pending Review':
        statusColor = AppColors.warningText;
        statusBg = AppColors.warningText.withValues(alpha: 0.12);
        break;
      case 'Flagged':
      default:
        statusColor = const Color(0xFFD9534F);
        statusBg = const Color(0xFFD9534F).withValues(alpha: 0.12);
        break;
    }

    final timeAgo = _formatTimeAgo(farmer.lastActivity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Farmer Name & Contact
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer.name,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFootlight,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Phone: ${farmer.phone} · ID: ${farmer.id}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      color: AppColors.foregroundSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Account Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                border: Border.all(color: statusColor.withValues(alpha: 0.6)),
              ),
              child: Text(
                farmer.accountStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Region Scope & Crops Grid
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildDetailChip(
              icon: Icons.location_on_outlined,
              label: 'REGION SCOPE',
              value: '${farmer.district} · ${farmer.block} block',
            ),
            _buildDetailChip(
              icon: Icons.grass_outlined,
              label: 'CROPS & SEASON',
              value: '${farmer.crops.join(', ')} (${farmer.season})',
            ),
            _buildDetailChip(
              icon: Icons.landscape_outlined,
              label: 'LAND HOLDING',
              value: '${farmer.landSizeAcres} Acres (${farmer.agroZone})',
            ),
            _buildDetailChip(
              icon: Icons.access_time_outlined,
              label: 'LATEST ACTIVITY',
              value: timeAgo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.straw),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8.5,
                fontFamily: 'monospace',
                color: AppColors.foregroundSubtle,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.foregroundMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else {
      return '${diff.inDays} days ago (${DateFormat('MMM d').format(dt)})';
    }
  }
}

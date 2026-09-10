import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/auth_service.dart';

class EditorialNavBar extends StatelessWidget {
  final String currentPath;

  const EditorialNavBar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: l10n.text('navHome'),
              path: '/farmer',
              isSelected: currentPath == '/farmer',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.psychology_outlined,
              activeIcon: Icons.psychology,
              label: l10n.text('navAsk'),
              path: '/farmer/ask',
              isSelected: currentPath == '/farmer/ask',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.map_outlined,
              activeIcon: Icons.map,
              label: l10n.text('navRegion'),
              path: '/farmer/region',
              isSelected: currentPath == '/farmer/region',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.cell_tower_outlined,
              activeIcon: Icons.cell_tower,
              label: l10n.text('navLowBandwidth'),
              path: '/farmer/low-bandwidth',
              isSelected: currentPath == '/farmer/low-bandwidth',
            ),
            if (authService.isAdmin)
              _buildNavItem(
                context: context,
                icon: Icons.admin_panel_settings_outlined,
                activeIcon: Icons.admin_panel_settings,
                label: l10n.text('navAdmin'),
                path: '/admin',
                isSelected: currentPath.startsWith('/admin'),
              ),
            _buildNavItem(
              context: context,
              icon: Icons.tune_outlined,
              activeIcon: Icons.tune,
              label: l10n.text('navSettings'),
              path: '/farmer/settings',
              isSelected: currentPath == '/farmer/settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
    required bool isSelected,
  }) {
    final color = isSelected ? AppColors.straw : AppColors.foregroundSubtle;

    return Expanded(
      child: InkWell(
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 20),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

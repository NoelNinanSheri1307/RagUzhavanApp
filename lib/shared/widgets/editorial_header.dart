import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'language_selector.dart';

class EditorialHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const EditorialHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 8),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/AppLogo.png',
                  height: 26,
                  width: 26,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.grass, color: AppColors.straw, size: 22),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFootlight,
                      fontSize: 20.0,
                      color: AppColors.foreground,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: AppColors.foregroundMuted,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...actions!,
            const SizedBox(width: 8),
            const LanguageSelector(),
          ],
        ),
      ),
    );
  }
}

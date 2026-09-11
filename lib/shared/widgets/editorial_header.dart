import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../animations/water_trickle_widget.dart';
import 'agricultural_easter_eggs.dart';
import 'language_selector.dart';

class EditorialHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final VoidCallback? onTriggerMonsoon;

  const EditorialHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.onTriggerMonsoon,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 92.0 : 72.0);

  @override
  State<EditorialHeader> createState() => _EditorialHeaderState();
}

class _EditorialHeaderState extends State<EditorialHeader> {
  int _headerTapCount = 0;

  void _handleTitleTap() {
    setState(() {
      _headerTapCount++;
    });
    if (_headerTapCount >= 5) {
      _headerTapCount = 0;
      if (widget.onTriggerMonsoon != null) {
        widget.onTriggerMonsoon!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.paper, size: 20),
                      onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 6),
                  ] else ...[
                    GestureDetector(
                      onTap: _handleTitleTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 26,
                          width: 26,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.grass, color: AppColors.straw, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleTitleTap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFootlight,
                                    fontSize: 18.0,
                                    color: AppColors.foreground,
                                    height: 1.15,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const WigglingCropCompanion(),
                            ],
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.foregroundMuted,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (widget.actions != null) ...widget.actions!,
                  const SizedBox(width: 6),
                  const LanguageSelector(),
                ],
              ),
            ),
            const WaterTrickleWidget(height: 4.0),
          ],
        ),
      ),
    );
  }
}


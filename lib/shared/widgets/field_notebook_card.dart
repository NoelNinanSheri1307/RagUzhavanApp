import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FieldNotebookCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? tagText;
  final Color? tagColor;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Widget? trailing;

  const FieldNotebookCard({
    super.key,
    this.title,
    this.subtitle,
    this.tagText,
    this.tagColor,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Widget? headerWidget;
    if (title != null || tagText != null) {
      final List<Widget> columnChildren = [];

      if (tagText != null || trailing != null) {
        columnChildren.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tagText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: (tagColor ?? AppColors.straw).withValues(alpha: 0.15),
                    border: Border.all(color: (tagColor ?? AppColors.straw), width: 1.0),
                  ),
                  child: Text(
                    tagText!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: tagColor ?? AppColors.straw,
                      letterSpacing: 0.8,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (trailing != null)
                Flexible(
                  fit: FlexFit.loose,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: trailing!,
                  ),
                ),
            ],
          ),
        );
        if (title != null || subtitle != null) {
          columnChildren.add(const SizedBox(height: 6));
        }
      }

      if (title != null) {
        columnChildren.add(
          Text(
            title!,
            style: const TextStyle(
              fontFamily: AppTheme.fontFootlight,
              fontSize: 15.5,
              color: AppColors.foreground,
              height: 1.2,
            ),
            maxLines: 2,
            softWrap: true,
          ),
        );
      }

      if (subtitle != null) {
        if (title != null) columnChildren.add(const SizedBox(height: 2));
        columnChildren.add(
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11.0,
              color: AppColors.foregroundMuted,
              height: 1.2,
            ),
            maxLines: 2,
            softWrap: true,
          ),
        );
      }

      headerWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: columnChildren,
        ),
      );
    }

    final List<Widget> cardChildren = [];
    if (headerWidget != null) {
      cardChildren.add(headerWidget);
    }
    cardChildren.add(
      Padding(
        padding: padding,
        child: child,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: cardChildren,
        ),
      ),
    );
  }
}

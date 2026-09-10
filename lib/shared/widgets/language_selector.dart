import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final isTamil = localeNotifier.languageCode == 'ta';

    return GestureDetector(
      onTap: () => localeNotifier.toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border.all(color: AppColors.borderBright, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTamil ? 'TA' : 'EN',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: isTamil ? AppColors.straw : AppColors.leaf,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isTamil ? 'தமிழ்' : 'English',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.foregroundMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

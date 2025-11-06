import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

/// Dialog for selecting app language with flags and dynamic theme colors.
class LanguageDialog {
  static void show(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentCode = localeProvider.locale.languageCode;
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.select_language,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textStrong(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(
              context,
              code: 'es',
              label: 'Español',
              flag: 'assets/images/mexico.png',
              selected: currentCode == 'es',
              onTap: () {
                localeProvider.setLocale(const Locale('es'));
                Navigator.pop(context);
              },
            ),
            _languageOption(
              context,
              code: 'en',
              label: 'English',
              flag: 'assets/images/usa.png',
              selected: currentCode == 'en',
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to show each language option with a flag and selection indicator.
  static Widget _languageOption(
    BuildContext context, {
    required String code,
    required String label,
    required String flag,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(flag, width: 36, height: 24, fit: BoxFit.cover),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.text(context),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: AppColors.primary(context))
          : Icon(Icons.radio_button_unchecked, color: AppColors.text(context).withOpacity(0.5)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// Displays a modal dialog that allows the user to select the app language.
// This dialog interacts directly with [LocaleProvider] to update
// the application's locale dynamically, applying the selected language
// immediately without requiring a restart.

// Features:
// - Presents two language options: *Spanish (es)* and *English (en)*.
// - Highlights the currently selected language.
// - Adapts its appearance to light or dark themes.
class Dialog {
  // Displays the language selection dialog.
  static void show(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentCode = localeProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (_) {
        /* final isDark = Theme.of(context).brightness == Brightness.dark; */

        return AlertDialog(
          backgroundColor: AppColors.background(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          // === Title ===
          title: Text(
            "Selecciona un idioma",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textStrong(context),
            ),
          ),

          // === Content ===
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spanish option
              RadioListTile<String>(
                activeColor: AppColors.primary(context),
                title: Text(
                  "Español",
                  style: TextStyle(color: AppColors.text(context)),
                ),
                value: 'es',
                groupValue: currentCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('es'));
                  Navigator.pop(context);
                },
              ),

              // English option
              RadioListTile<String>(
                activeColor: AppColors.primary(context),
                title: Text(
                  "English",
                  style: TextStyle(color: AppColors.text(context)),
                ),
                value: 'en',
                groupValue: currentCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

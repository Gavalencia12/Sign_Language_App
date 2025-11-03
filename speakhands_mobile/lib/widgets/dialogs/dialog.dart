import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class Dialog {
  static void show(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentCode = localeProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: AppColors.background(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Selecciona un idioma",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textStrong(context),
            ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                activeColor: AppColors.primary(context),
                title: Text("Español",
                style: TextStyle(color: AppColors.text(context)),
                ),
                value: 'es',
                groupValue: currentCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('es'));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                activeColor: AppColors.primary(context),
                title: Text("English",
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
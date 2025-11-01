import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';

class Dialog {
  static void show(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentCode = localeProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Selecciona un idioma"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Español"),
                value: 'es',
                groupValue: currentCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('es'));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text("English"),
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

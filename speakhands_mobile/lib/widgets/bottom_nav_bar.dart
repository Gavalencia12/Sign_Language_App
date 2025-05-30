import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  /// Método estático para mostrar el diálogo de selección de idioma desde cualquier pantalla.
  static void showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.select_language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, localeProvider, const Locale('es'), 'Español', 'assets/images/mexico.png'),
            _languageOption(context, localeProvider, const Locale('en'), 'English', 'assets/images/usa.png'),
          ],
        ),
      ),
    );
  }

  /// Widget que crea una opción de idioma dentro del diálogo.
  static Widget _languageOption(BuildContext context, LocaleProvider localeProvider, Locale locale, String label, String assetPath) {
    return ListTile(
      leading: Image.asset(assetPath, height: 24, width: 36, fit: BoxFit.cover),
      title: Text(label),
      onTap: () {
        localeProvider.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    Locale currentLocale = localeProvider.locale;

    return GestureDetector(
      onTap: () => showLanguageDialog(context),
      child: Image.asset(
        currentLocale.languageCode == 'es' ? 'assets/images/mexico.png' : 'assets/images/usa.png',
        height: 24,
        width: 36,
        fit: BoxFit.cover,
      ),
    );
  }
}

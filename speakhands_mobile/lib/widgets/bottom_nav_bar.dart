import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  static void showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final loc = AppLocalizations.of(context)!;

    final Color surfaceColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color dividerColor = AppColors.text(context).withOpacity(0.1);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              loc.select_language,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _languageOption(
                  context,
                  localeProvider,
                  const Locale('es'),
                  'Español',
                  'assets/images/mexico.png',
                  textColor,
                  dividerColor,
                ),
                _languageOption(
                  context,
                  localeProvider,
                  const Locale('en'),
                  'English',
                  'assets/images/usa.png',
                  textColor,
                  dividerColor,
                ),
              ],
            ),
          ),
    );
  }

  static Widget _languageOption(
    BuildContext context,
    LocaleProvider localeProvider,
    Locale locale,
    String label,
    String assetPath,
    Color textColor,
    Color dividerColor,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Image.asset(
            assetPath,
            height: 24,
            width: 36,
            fit: BoxFit.cover,
          ),
          title: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textColor),
          ),
          onTap: () {
            localeProvider.setLocale(locale);
            Navigator.pop(context);
          },
        ),
        Divider(height: 1, color: dividerColor),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    Locale currentLocale = localeProvider.locale;

    return GestureDetector(
      onTap: () => showLanguageDialog(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: AppColors.text(context).withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            currentLocale.languageCode == 'es'
                ? 'assets/images/mexico.png'
                : 'assets/images/usa.png',
            height: 26,
            width: 38,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

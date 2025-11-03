import 'package:flutter/material.dart' hide Dialog;
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'pages/terms_and_conditions_screen.dart';
import 'pages/privacy_policy_screen.dart';
import 'pages/help_screen.dart';

// 🔹 Imports de los widgets locales
import 'widgets/section_title.dart';
import 'widgets/settings_card.dart';

// 🔹 Imports de los diálogos globales
import 'package:speakhands_mobile/widgets/dialogs/dialog.dart';
import 'package:speakhands_mobile/widgets/dialogs/modal.dart';

// 🔹 Importa tus colores globales
import 'package:speakhands_mobile/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // 🔹 Uso de colores globales dinámicos
    final Color backgroundColor = AppColors.background(context);
    final Color surfaceColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color iconColor = AppColors.text(context).withOpacity(0.85);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: "Settings"),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Sección 1 — Accesibilidad
                SectionTitle(
                  title: AppLocalizations.of(context)!.accessibility_section,
                ),
                SettingsCard(
                  children: [
                    ListTile(
                      leading: Icon(Icons.translate, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.language,
                        style: TextStyle(color: textColor,
                        fontWeight: FontWeight.w600),
                      ),
                      onTap: () => Dialog.show(context),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.brightness_6_rounded,
                        color: iconColor,
                      ),
                      title: Text(
                        'Apariencia',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        themeProvider.themeModeOption == ThemeModeOption.dark
                            ? 'Tema actual: Oscuro'
                            : themeProvider.themeModeOption ==
                                ThemeModeOption.light
                            ? 'Tema actual: Claro'
                            : 'Tema actual: Sistema',
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                      onTap: () => Modal.show(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.accessibility, color: iconColor),
                      title: Text(
                        "Accesibilidad",
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => Dialog.show(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                // Sección 2 — Ayuda e información
                SectionTitle(
                  title: AppLocalizations.of(context)!.help_information_section,
                ),
                SettingsCard(
                  children: [
                    ListTile(
                      leading: Icon(Icons.security, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.privacy_policy,
                        style: TextStyle(color: textColor),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrivacyPolicyScreen(),
                            ),
                          ),
                    ),
                    ListTile(
                      leading: Icon(Icons.library_books, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.terms_and_conditions,
                        style: TextStyle(color: textColor),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TermsAndConditionsScreen(),
                            ),
                          ),
                    ),
                    ListTile(
                      leading: Icon(Icons.help, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.help,
                        style: TextStyle(color: textColor),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

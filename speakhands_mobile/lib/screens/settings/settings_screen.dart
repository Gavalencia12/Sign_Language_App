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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(title: "Settings"),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70),
                // Sección 1 — Accesibilidad
                SectionTitle(
                  title: AppLocalizations.of(context)!.accessibility_section,
                ),
                SettingsCard(
                  children: [
                    ListTile(
                      leading: Icon(Icons.g_translate, color: textColor),
                      title: Text(
                        AppLocalizations.of(context)!.language,
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => Dialog.show(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.brightness_6_rounded),
                      title: const Text('Apariencia'),
                      subtitle: Text(
                        themeProvider.isDarkMode
                            ? 'Tema actual: Oscuro'
                            : 'Tema actual: Claro',
                      ),
                      onTap: () => Modal.show(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.accessibility, color: textColor),
                      title: Text(
                        "Accesibilidad",
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => Dialog.show(context),
                    ),
                  ],
                ),

                // Sección 2 — Ayuda e información
                SectionTitle(
                  title: AppLocalizations.of(context)!.help_information_section,
                ),
                SettingsCard(
                  children: [
                    ListTile(
                      leading: Icon(Icons.security, color: textColor),
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
                      leading: Icon(Icons.library_books, color: textColor),
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
                      leading: Icon(Icons.help, color: textColor),
                      title: Text(
                        AppLocalizations.of(context)!.help,
                        style: TextStyle(color: textColor),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HelpScreen()),
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

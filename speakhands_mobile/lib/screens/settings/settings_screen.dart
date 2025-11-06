import 'package:flutter/material.dart' hide Dialog;
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/widgets/dialogs/language_dialog.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

// Import local pages
import 'pages/terms_and_conditions_screen.dart';
import 'pages/privacy_policy_screen.dart';
import 'pages/help_screen.dart';

// Local widgets
import 'widgets/section_title.dart';
import 'widgets/settings_card.dart';

// Global dialogs
import 'package:speakhands_mobile/widgets/dialogs/dialog.dart';
import 'package:speakhands_mobile/widgets/dialogs/modal.dart';

// Global theme colors
import 'package:speakhands_mobile/theme/app_colors.dart';

// The **SettingsScreen** is where users can customize the app’s appearance,
// language, accessibility, and access legal information such as privacy policy,
// terms and conditions, or help resources.

// It leverages global providers (`ThemeProvider`, `LocaleProvider`) and
// app-wide theme colors from [AppColors].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Define adaptive theme colors
    final Color backgroundColor = AppColors.background(context);
    final Color textColor = AppColors.text(context);
    final Color iconColor = AppColors.text(context).withOpacity(0.85);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.settings_title,),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Section 1 — Accessibility
                SectionTitle(
                  title: AppLocalizations.of(context)!.accessibility_section,
                ),
                SettingsCard(
                  children: [
                    // Language selection
                    ListTile(
                      leading: Icon(Icons.translate, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.language,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          context.watch<LocaleProvider>().locale.languageCode == 'es'
                              ? 'assets/images/mexico.png'
                              : 'assets/images/usa.png',
                          width: 36,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onTap: () => LanguageDialog.show(context),
                    ),

                    // Theme mode selection (Light / Dark / System)
                    ListTile(
                      leading: Icon(
                        Icons.brightness_6_rounded,
                        color: iconColor,
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.color,
                        style: TextStyle(color: textColor,
                        fontWeight: FontWeight.w600,),
                      ),
                      subtitle: Text(
                        themeProvider.themeModeOption == ThemeModeOption.dark
                            ? AppLocalizations.of(context)!.dark_mode
                            : themeProvider.themeModeOption ==
                                ThemeModeOption.light
                            ? AppLocalizations.of(context)!.sure_mode
                            : AppLocalizations.of(context)!.sistem_mode,
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                      onTap: () => Modal.show(context),
                    ),

                    // Accessibility settings (placeholder for future options)
                    ListTile(
                      leading: Icon(Icons.accessibility, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.accessibility,
                        style: TextStyle(color: textColor,
                        fontWeight: FontWeight.w600,),
                      ),
                      /* onTap: () => */
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Section 2 — Help and Information
                SectionTitle(
                  title: AppLocalizations.of(context)!.help_information_section,
                ),
                SettingsCard(
                  children: [
                    // Privacy Policy
                    ListTile(
                      leading: Icon(Icons.security, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.privacy_policy,
                        style: TextStyle(color: textColor,
                        fontWeight: FontWeight.w600,),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrivacyPolicyScreen(),
                            ),
                          ),
                    ),

                    // Terms and Conditions
                    ListTile(
                      leading: Icon(Icons.library_books, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.terms_and_conditions,
                        style: TextStyle(color: textColor,
                        fontWeight: FontWeight.w600,),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TermsAndConditionsScreen(),
                            ),
                          ),
                    ),

                    // Help Section
                    ListTile(
                      leading: Icon(Icons.help, color: iconColor),
                      title: Text(
                        AppLocalizations.of(context)!.help_information_section,
                        style: TextStyle(color: textColor,
                        fontWeight: FontWeight.w600,),
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

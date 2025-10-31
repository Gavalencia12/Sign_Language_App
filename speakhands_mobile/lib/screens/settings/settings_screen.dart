import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_database/firebase_database.dart';
import 'package:speakhands_mobile/models/user_model.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/widgets/bottom_nav_bar.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';
import 'TermsAndConditionsScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'HelpScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /* final AuthService _authService = AuthService(); */
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Usuario? usuario;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _dbRef.child("usuarios").child(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          usuario = Usuario.fromMap(snapshot.value as Map<dynamic, dynamic>);
        });
      }
    }
  }

  /*   void _signOut(BuildContext context) async {
    await _authService.signOut();
    // Clear all previous screens and navigate to Home
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (Route<dynamic> route) => false,
    );
  } */

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final localeProvider = Provider.of<LocaleProvider>(
          context,
          listen: false,
        );
        final currentCode = localeProvider.locale.languageCode;

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final theme = Theme.of(context);
final backgroundColor = theme.colorScheme.background;
final textColor = theme.colorScheme.onBackground;
final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: backgroundColor, // 👈 ahora el fondo se define
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SETTINGS",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Speak",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Hands",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Scroll principal
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70),

                // 🔹 Sección 1 — Cuenta
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.account_section,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.security, color: textColor),
                    title: Text(
                      AppLocalizations.of(context)!.privacy_policy,
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ),

                // 🔹 Sección 2 — Accesibilidad
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.accessibility_section,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.g_translate, color: textColor),
                        title: Text(
                          AppLocalizations.of(context)!.language,
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () => _showLanguageDialog(context),

                        trailing: Consumer<LocaleProvider>(
                          builder: (context, localeProvider, _) {
                            return Image.asset(
                              localeProvider.locale.languageCode == 'es'
                                  ? 'assets/images/mexico.png'
                                  : 'assets/images/usa.png',
                              height: 24,
                              width: 36,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Divider(color: textColor.withOpacity(0.3)),
                      ListTile(
                        leading: Icon(Icons.color_lens, color: textColor),
                        title: Text(
                          AppLocalizations.of(context)!.color,
                          style: TextStyle(color: textColor),
                        ),
                        onTap:
                            () => themeProvider.toggleTheme(
                              !themeProvider.isDarkMode,
                            ),
                      ),
                      Divider(color: textColor.withOpacity(0.3)),
                      ListTile(
                        leading: Icon(
                          Icons.accessibility_new,
                          color: textColor,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.accessibility,
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {},
                      ),
                      Divider(color: textColor.withOpacity(0.3)),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          String subtitleText;
                          switch (themeProvider.themeMode) {
                            case ThemeMode.light:
                              subtitleText = 'Tema actual: Claro';
                              break;
                            case ThemeMode.dark:
                              subtitleText = 'Tema actual: Oscuro';
                              break;
                            default:
                              subtitleText = 'Tema actual: Sistema';
                          }

                          return ListTile(
                            leading: const Icon(Icons.brightness_6_rounded),
                            title: const Text('Apariencia'),
                            subtitle: Text(subtitleText),
                            onTap: () => ThemeSelectorModal.show(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 🔹 Sección 3 — Ayuda e Información
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    AppLocalizations.of(context)!.help_information_section,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.library_books, color: textColor),
                        title: Text(
                          AppLocalizations.of(context)!.terms_and_conditions,
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(color: textColor.withOpacity(0.3)),
                      ListTile(
                        leading: Icon(Icons.help, color: textColor),
                        title: Text(
                          AppLocalizations.of(context)!.help,
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(color: textColor.withOpacity(0.3)),
                      ListTile(
                        leading: Icon(Icons.assignment, color: textColor),
                        title: Text(
                          AppLocalizations.of(context)!.qualife,
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 🔹 Cabecera fija mejorada
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color:
                    themeProvider.isDarkMode
                        ? Colors.black.withOpacity(0.6)
                        : Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                AppLocalizations.of(context)!.hello,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeSelectorModal {
  static void show(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        final themeMode = themeProvider.themeMode;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Seleccionar tema',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              RadioListTile<ThemeMode>(
                title: const Text('Claro'),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (mode) {
                  themeProvider.setThemeMode(mode!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Oscuro'),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (mode) {
                  themeProvider.setThemeMode(mode!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Predeterminado del sistema'),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (mode) {
                  themeProvider.setThemeMode(mode!);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

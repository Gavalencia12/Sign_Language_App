import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_database/firebase_database.dart';
import  'package:speakhands_mobile/models/user_model.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/widgets/bottom_nav_bar.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {

  SettingsScreen({super.key});
  
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
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
  void _signOut(BuildContext context) async {
    await _authService.signOut();
    // Clear all previous screens and navigate to Home
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false); 
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A); 

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text("SETTINGS", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min, // The space between the two SpeakHands texts
              children: [
                Text("Speak", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Text("Hands", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false, // Disables the automatic behavior of the back button
      ),
      body: Stack(
        children: [
          // The body with scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60), // Space so that the content is not covered by the box
                // First Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                  child: Row(
                    children:[
                      Text(
                        AppLocalizations.of(context)!.account_section,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                    ListTile(
                        leading: Icon(Icons.security, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.privacy_policy, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "Privacy Policy"
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                  child: Row(
                    children:[
                      Text(
                        AppLocalizations.of(context)!.accessibility_section,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Second Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.g_translate, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.language, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () => LanguageSwitcher.showLanguageDialog(context),
                        trailing: Builder(
                          builder: (context) {
                            final localeProvider = Provider.of<LocaleProvider>(context);
                            return Image.asset(
                              localeProvider.locale.languageCode == 'es' ? 'assets/images/mexico.png' : 'assets/images/usa.png',
                              height: 24,
                              width: 36,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),

                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.color_lens, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.color, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          themeProvider.toggleTheme(!themeProvider.isDarkMode);
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.accessibility_new, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.accessibility, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "accessibility"
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                  child: Row(
                    children:[
                      Text(
                        AppLocalizations.of(context)!.help_information_section,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.library_books, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.terms_and_conditions, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "terms and conditions"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.help, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.help, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "help"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.assignment, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(AppLocalizations.of(context)!.qualife, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "qualife"
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // The painting that stays fixed
          Positioned(
            top: 0, // Adjust the position so that it is below the AppBar
            left: 0,
            right: 0,
            child: Material(
              color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.hello, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),),
                      
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

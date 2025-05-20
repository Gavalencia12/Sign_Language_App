import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore

class SettingsScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  SettingsScreen({super.key});

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    // Clear all previous screens and navigate to Home
    Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false); 
  }

  Future<String> _getUserName() async {
    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the user's name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      return userDoc['nombre'] ?? 'Usuario'; // Returns the user name or 'User' if it does not exist
    }
    return 'Usuario'; // If the user is not authenticated, 'User' is returned
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final appBarColor = themeProvider.isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary;
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
                        "Account",
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
                        leading: Icon(Icons.account_circle, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Personal Data", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "Personal Data"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Línea divisoria
                      ListTile(
                        leading: Icon(Icons.mail, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Account", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "Account"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Línea divisoria
                      ListTile(
                        leading: Icon(Icons.security, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Privacy Policy", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
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
                        "Accessibility",
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
                        title: Text("Language", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "language"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.color_lens, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Color", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          themeProvider.toggleTheme(!themeProvider.isDarkMode);
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.accessibility_new, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Accessibility", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
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
                        "Help && Information",
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
                        title: Text("Terms and Conditions", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "terms and conditions"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.help, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Help", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "help"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.assignment, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Qualife", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "qualife"
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
                        "The Login",
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
                        leading: Icon(Icons.switch_account, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text(" Change Account", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          // Action to "change account"
                        },
                      ),
                      Divider(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ListTile(
                        leading: Icon(Icons.logout, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A)),
                        title: Text("Log Out", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A))),
                        onTap: () {
                          _signOut(context); // Log out action   
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
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error loading name');
                        } else if (snapshot.hasData) {
                          return Text(
                            "Hello, ${snapshot.data}!", // Muestra el nombre del usuario
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text(
                            "Hello, Usuario!",
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
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

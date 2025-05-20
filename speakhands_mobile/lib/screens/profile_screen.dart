import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/settings_screen.dart';
import 'package:speakhands_mobile/screens/editprofile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ProfileScreen({super.key});

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.popAndPushNamed(context, '/home'); // Closes the current screen and redirects to Home
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
            Text("PROFILE", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min, // The space between the two SpeakHands texts
              children: [
                Text("Speak", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Text("Hands", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),

        backgroundColor: backgroundColor, // We use the AppTheme color according to the theme
      ),
      body: Stack(
        children: [
          // The body with scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 45),
                  color: themeProvider.isDarkMode
                      ? AppTheme.darkBackground
                      : AppTheme.lightBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 120,
                                  height: 138,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.blueGrey[300],
                                  ),
                                  child: const Icon(Icons.person, size: 60),
                                ),
                                Positioned(
                                  bottom: -10,
                                  right: -10,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan[200],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),

                                    child: GestureDetector(
                                        onTap: () {
                                          // Navegar a la pantalla de configuración (settings_screen.dart)
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                                          );
                                        },
                                        child: const Icon(Icons.edit, size: 32, color: Colors.black),
                                      ),

                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Juan Miguel Perez Zepeda",
                                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 50),
                                      Row(
                                        children: [
                                          Text("Nivel 12", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 10),
                                          Text("LSM", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 5),
                                          Image.asset(
                                            'assets/images/mexico.png',
                                            height: 16,
                                            width: 24,
                                            fit: BoxFit.cover,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                        ListTile(
                          title: Text("Email", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("jperez34@ucol.com.mx", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text("Phone", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("3141641172", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text("Birth date", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("22/Dec/2024", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          trailing: Icon(Icons.calendar_today, color: textColor),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("MY STATISTICS:",
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.red[900]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text("Challenge of the Day",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const Spacer(),
                              Text("26 🔥", style: TextStyle(color: Colors.red[700])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.blueGrey
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text("Your Progress:",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const Spacer(),
                              Text("Nivel 12", style: TextStyle(color: textColor)),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text("Disability:", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("SordoMudo", style: TextStyle(color: textColor, fontSize: 15)),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text("About You:", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("My Name is jorge Gael Valencia Colima", style: TextStyle(color: textColor, fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // El cuadro que se queda fijo
          Positioned(
            top: 0, // Ajusta la posición para que esté debajo del AppBar
            left: 15,
            right: 15, // Añadí este `right` para que también ocupe el espacio disponible en el extremo derecho
            child: Material(
              color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea el contenido a los extremos
                  children: [
                    Text(
                      "Edit your profile",
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Alineamos "Settings" y el ícono a la derecha
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navegar a la pantalla de configuración (settings_screen.dart)
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SettingsScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.settings,
                                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

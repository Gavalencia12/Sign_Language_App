import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/settings/settings_screen.dart';
import 'package:speakhands_mobile/screens/editprofile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import  'package:speakhands_mobile/models/user_model.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/data/speech_texts.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/widgets/bottom_nav_bar.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {

  ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextToSpeechService ttsService = TextToSpeechService();

  Usuario? usuario;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakText());
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

  Future<void> _speakText() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    if (speakOn) {
      await ttsService.stop();
      await ttsService.speak(ProfileSpeechTexts.intro);
    }
  }
  
  @override
  void dispose() {
    ttsService.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A); 

    return Scaffold(
      appBar: const CustomAppBar(title: "PROFILE"),
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
                                  child: usuario?.foto != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          usuario!.foto,
                                          width: 120,
                                          height: 138,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 60),
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
                                          // Navigate to the settings screen (settings_screen.dart)
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                                          );
                                        },
                                        child: const Icon(Icons.edit, size: 32, color: Colors.black),
                                      ),

                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -195,
                                  child: Container(
                                  
                                    child: GestureDetector(
                                        onTap: () {
                                          // Navigate to the settings screen (settings_screen.dart)
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                                          );
                                        },
                                        child: Icon(Icons.notifications, color: Colors.orange[400], size: 28),
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
                                        usuario?.nombre ?? 'User',
                                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(AppLocalizations.of(context)!.age,style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),),
                                          Text(
                                            usuario?.edad ?? 'Age',
                                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Nivel 12", 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),   
                                          LanguageSwitcher(),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                          ],
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.email, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            usuario?.email ?? 'Email',
                            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.phone, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            usuario?.telefono ?? AppLocalizations.of(context)!.without_phone,
                            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.birth_date, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            usuario?.fechaNacimiento ?? AppLocalizations.of(context)!.without_birth_date,
                            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.calendar_today, color: textColor),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(AppLocalizations.of(context)!.my_statistics,
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
                              Text(AppLocalizations.of(context)!.challenge_of_the_day,
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
                              Text(AppLocalizations.of(context)!.your_progress,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const Spacer(),
                              Text("${AppLocalizations.of(context)!.level} 12", style: TextStyle(color: textColor)),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.disability, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(usuario?.discapacidad ?? AppLocalizations.of(context)!.without_disability, style: TextStyle(color: textColor, fontSize: 15)),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.about_you, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(usuario?.about ?? AppLocalizations.of(context)!.without_information, style: TextStyle(color: textColor, fontSize: 15)),                        
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // The painting that stays fixed
          Positioned(
            top: 0, // Adjust the position so that it is below the AppBar
            left: 15,
            right: 15, 
            child: Material(
              color: themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns content to the edges
                  children: [
                    Text(
                      AppLocalizations.of(context)!.edit_your_profile,
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end, 
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to the settings screen (settings_screen.dart)
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SettingsScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.settings,
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

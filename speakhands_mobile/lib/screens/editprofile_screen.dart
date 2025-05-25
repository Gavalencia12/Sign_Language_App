import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Get the color for the AppBar and the body background based on the mode
    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A); 

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text("Edit Profile", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
        automaticallyImplyLeading: false, // Disables the automatic behavior of the back button
      ),
      body: Center(child: Text('Edit Profile Screen')),
    );
  }
}

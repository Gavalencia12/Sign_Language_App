import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Obtener el color para el AppBar y el fondo del body según el modo
    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final appBarColor = themeProvider.isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A); // Color dinámico del texto

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ajustar el texto a los extremos
          children: [
            Text("LEARNING", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min, // El espacio entre los dos textos de SpeakHands
              children: [
                Text("Speak", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Text("Hands", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        backgroundColor: backgroundColor, // Usamos el color de AppTheme según el tema
      ),
      body: Center(child: Text('Learn Screen')),
    );
  }
}

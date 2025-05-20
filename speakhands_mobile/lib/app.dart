import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/splash_screen.dart';
import 'package:speakhands_mobile/screens/login_screen.dart';
import 'package:speakhands_mobile/screens/main_nav.dart';

class SpeakHandsApp extends StatelessWidget {
  const SpeakHandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeakHands',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const MainNavigation(),
        '/login': (_) => const LoginScreen(), // Pantalla de inicio de sesión
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/splash_screen.dart';
import 'package:speakhands_mobile/screens/login_screen.dart';
import 'package:speakhands_mobile/screens/main_nav.dart';
import 'package:speakhands_mobile/screens/register/register_screen.dart';
import 'package:speakhands_mobile/screens/register/register_email_screen.dart';
import 'package:speakhands_mobile/screens/register/verify_email_screen.dart';
import 'package:speakhands_mobile/screens/register/create_password_screen.dart';
import 'package:speakhands_mobile/screens/register/complete_profile_screen.dart';

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
        '/register': (context) => RegisterScreen(), // Ruta a la pantalla de registro
        '/register_email': (context) => const RegisterEmailScreen(), // Ruta a la pantalla de registro por email
        '/verify_email': (context) => const VerifyEmailScreen(), // esta la haremos en el siguiente paso
        '/create_password': (context) => const CreatePasswordScreen(), // Ruta a la pantalla de creación de contraseña
        '/complete_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return CompleteProfileScreen(
            email: args['email'],
            createdAt: args['createdAt'],
          );
        },
        '/login': (_) => const LoginScreen(), // Login screen
      },
    );
  }
}

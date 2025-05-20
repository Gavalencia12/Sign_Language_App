import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signInGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final userCredential = await _authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (userCredential != null) {
      // Redirect to the main screen after a successful login
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _signInFacebook() async {
    // Implement Facebook login here
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final appBarColor = themeProvider.isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A); // Color dinámico del texto

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Return to the home screen
          },
        ),
        backgroundColor: backgroundColor, // We use the AppTheme color according to the theme
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()  // Display the loading indicator
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text('Iniciar sesión con Google'),
                      onPressed: _signInGoogle,
                    ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()  // Display the loading indicator
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.facebook),
                      label: const Text('Iniciar sesión con Facebook'),
                      onPressed: _signInFacebook,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

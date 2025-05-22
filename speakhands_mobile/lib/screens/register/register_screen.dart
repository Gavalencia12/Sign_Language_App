import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _goToEmailRegister() {
    Navigator.pushNamed(context, '/register_email');
  }

  void _signInGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      final bool isNew = result['isNew'];
      final UserCredential userCredential = result['userCredential'];
      final DateTime createdAt = result['createdAt'];

      if (isNew) {
        Navigator.pushReplacementNamed(
          context,
          '/complete_profile',
          arguments: {
            'email': userCredential.user?.email,
            'createdAt': createdAt.toIso8601String(), // Ensures it is String
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Create new account",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Begin with creating new free account. This helps you keep your learning way easier.",
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToEmailRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26C6DA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Continue with email", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("or", style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            _socialButton(
              icon: Icons.facebook,
              label: "Continue with Facebook",
              onTap: () {
                // future integration (Mariana)
              },
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _socialButton(
                    icon: Icons.g_mobiledata,
                    label: "Continue with Google",
                    onTap: _signInGoogle,
                  ),
            const Spacer(),
            Center(
              child: Text(
                "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: const TextStyle(color: Colors.black)),
        ),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
      ),
    );
  }
}

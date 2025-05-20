import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _goToEmailRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register_email'); // ruta que crearemos en el siguiente paso
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
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7),fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToEmailRegister(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26C6DA), // Turquesa
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Continue with email", style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("or", style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            _socialButton(
              context,
              icon: Icons.facebook,
              label: "Continue with Facebook",
              onTap: () {
                // integración futura
              },
            ),
            const SizedBox(height: 10),
            _socialButton(
              context,
              icon: Icons.g_mobiledata,
              label: "Continue with Google",
              onTap: () {
                // integración futura
              },
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

  Widget _socialButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: const TextStyle(color: Colors.black)),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

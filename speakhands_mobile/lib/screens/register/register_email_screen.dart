import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/register/verify_email_screen.dart';
import 'package:speakhands_mobile/service/auth_service.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService(); // instancia del servicio

  void _continueToVerification() async {
    final email = _emailController.text.trim();
    print("Verificando el correo: $email");

    if (email.isEmpty || !email.contains('@')) {
      print("Email no válido");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    }

    try {
      print("Buscando métodos de inicio de sesión para el correo $email");
      final methods = await _authService.fetchSignInMethods(email);
      print("Métodos para $email: $methods"); // Verifica si el método se obtiene correctamente

      if (methods.isNotEmpty) {
        print("El email ya está registrado");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This email is already registered")),
        );
        return;
      }

      print("Enviando código de verificación a $email");
      // Si el correo NO está registrado, continúa con el código de verificación
      await _authService.sendVerificationCode(email);
      print("Código enviado a $email");

      // Redirige a la pantalla de verificación
      Navigator.pushNamed(context, '/verify_email', arguments: email);
    } catch (e) {
      print("Error al continuar con la verificación: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isCurrent = index == currentStep - 3;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 20,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFFA0E7E5) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2F3A4A);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add your email 1 / 3", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              _buildStepIndicator(3),
              const SizedBox(height: 30),
              const Text("Enter your email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueToVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26C6DA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Create an account", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

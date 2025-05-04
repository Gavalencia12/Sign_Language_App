import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/auth_service.dart';

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
      // Redirigir a la pantalla principal después de un inicio de sesión exitoso
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _signInFacebook() async {
    // Implementa el inicio de sesión con Facebook aquí
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Iniciar sesión"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Botón de regreso
          },
        ),
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
                  ? const CircularProgressIndicator()  // Muestra el indicador de carga
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
                  ? const CircularProgressIndicator()  // Muestra el indicador de carga
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

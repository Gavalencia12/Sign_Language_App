import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakhands_mobile/widgets/text_field.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

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
            'createdAt': createdAt.toIso8601String(), // Explicitly convert to String         
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _signInFacebook() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithFacebook();

    setState(() => _isLoading = false);

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
            'createdAt': createdAt.toIso8601String(),
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar sesión con Facebook')),
      );
    }
  }

  void _signInWithEmailAndPassword() async {
    FocusScope.of(context).unfocus(); // Oculta teclado

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor ingresa email y contraseña')),
    );
    return;
  }

    setState(() {
      _isLoading = true;
    });

  try {
    final userCredential = await _authService.logIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (userCredential != null) {
      final bool isNew = userCredential.additionalUserInfo?.isNewUser ?? false;
      final DateTime? createdAt = userCredential.user?.metadata.creationTime;

      if (isNew) {
        Navigator.pushReplacementNamed(
          context,
          '/complete_profile',
          arguments: {
            'email': userCredential.user?.email,
            'createdAt': createdAt?.toIso8601String(),
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  } on FirebaseAuthException catch (e) {
    // Manejo del error específico cuando el usuario no existe
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no registrado. Por favor regístrate.')),
      );

      // Esperamos un poco para que el usuario vea el mensaje y luego navegamos
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacementNamed(context, '/register');
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña incorrecta')),
      );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.message}')),
      );
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _goToRegisterScreen() {
    // Redirect to the registration screen
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final backgroundColor = themeProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;

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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, left: 32, right: 32),
            child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Speak",
                      style: TextStyle(
                        fontSize: 30,
                        color: AppTheme.lightPrimary
                      ),),
                      Text("Hands",
                      style: TextStyle(
                        fontSize: 30,
                      ),),
                    ],
                  ),
        
                  Image.asset('assets/images/logo.png', height: 180),
                  const SizedBox(height: 20),
              
                  TextFields(
                    label: 'Email',
                    icon: Icons.email,
                    controller: _emailController),
              
                  const SizedBox(height: 40),
              
                  TextFields(
                    label: 'Password',
                    icon: Icons.lock,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    showVisibilityToggle: true,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
        
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: _goToRegisterScreen,
                        child: Text( 
                          "Forgot password?",
                          style: TextStyle(fontSize: 14,),
                        )
                      ),
                  ),
        
                  const SizedBox(height: 20),
        
                  _isLoading
                    ? const CircularProgressIndicator()
                    :ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      label: const Text('Log In'),
                      onPressed: _signInWithEmailAndPassword,
                    ),
        
                  const SizedBox(height: 20),
              
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
                          label: const Text('Sign in with Google'),
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
                          label: const Text('Log in with Facebook'),
                          onPressed: _signInFacebook,
                        ),
                  const SizedBox(height: 20),
                  // Here we add the text that redirects to the registry
                  TextButton(
                    onPressed: _goToRegisterScreen, // Redirige a la pantalla de registro
                    child: Text(
                      "¿No tienes una cuenta? Regístrate",
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF2F3A4A),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}
//etger
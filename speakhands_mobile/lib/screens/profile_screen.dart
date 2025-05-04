import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ProfileScreen({super.key});

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/home'); // Redirige al Home después de cerrar sesión
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Perfil del usuario'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
      
    );
  }
}

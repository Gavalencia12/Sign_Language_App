import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/theme.dart'; 

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      backgroundColor: AppTheme.lightAccent,
      body: Center(
        child: Image.asset('assets/images/logo.png', height: 150),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// Importa tus pantallas
import 'package:speakhands_mobile/screens/splash/splash_screen.dart';
import 'package:speakhands_mobile/screens/main_nav/main_nav.dart';
import 'package:speakhands_mobile/screens/settings/settings_screen.dart';
import 'package:speakhands_mobile/screens/translator/translator_screen.dart';
import 'package:speakhands_mobile/screens/interpreter/interpreter_screen.dart';

class AppRouter {
  // Nombres de rutas como constantes
  static const String splash = '/splash';
  static const String main = '/main';
  static const String settings = '/settings';
  static const String translator = '/translator';
  static const String interpreter = '/interpreter';

  // Ruta inicial de la aplicación
  static const String initialRoute = '/splash';

  static final Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashScreen(),
    '/main': (context) => MainNavigation(key: MainNavigation.globalKey),
    '/settings': (context) => const SettingsScreen(),
    '/translator': (context) => const TranslatorScreen(),
    '/interpreter': (context) => const InterpreterScreen(),
  };

  // Método auxiliar (por si quieres navegar desde context fácilmente)
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  // Método auxiliar para reemplazar toda la ruta (por ejemplo, tras iniciar sesión)
  static void replaceWith(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // Método que maneja rutas desconocidas (por si el nombre de la ruta no existe)
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const SplashScreen());
  }
}

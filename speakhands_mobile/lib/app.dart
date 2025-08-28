import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/splash_screen.dart';
import 'package:speakhands_mobile/screens/main_nav.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:speakhands_mobile/providers/locale_provider.dart'; 
import 'package:speakhands_mobile/l10n/app_localizations.dart'; 


class SpeakHandsApp extends StatelessWidget {
  const SpeakHandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()), // <- voice provider
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const _AppContent(),
    );
  }
}
class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context); // <--- AÑADE ESTO

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeakHands',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale, // <--- IDIOMA ACTUAL
      supportedLocales: L10n.all,    // <--- LISTA DE LOCALES
      localizationsDelegates: const [ // <--- DELEGADOS DE FLUTTER
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (context) => MainNavigation(key: MainNavigation.globalKey),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/learn_screen.dart';
import 'package:speakhands_mobile/screens/settings/settings_screen.dart';
import 'package:speakhands_mobile/screens/translator_screen.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class MainNavigation extends StatefulWidget {
  // Definimos una key estática para controlar el estado desde fuera
  static final GlobalKey<_MainNavigationState> globalKey = GlobalKey<_MainNavigationState>();

  MainNavigation({Key? key}) : super(key: globalKey);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1;
  final AuthService _authService = AuthService();

  final List<Widget> screens = [
    const LearnScreen(),
    const TranslatorScreen(),
    SettingsScreen(),
  ];

  // Método para cambiar la pestaña activamente
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.darkAccent : AppTheme.lightPrimary;
    final iconColor = isDarkMode ? AppTheme.lightBackground : AppTheme.lightBackground;

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(50)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(screens.length, (index) {
            bool isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 150 : 56, // Más ancho para la pestaña seleccionada
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForIndex(index),
                        size: 30,
                        color: isSelected ? backgroundColor : iconColor,
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            _getTextForIndex(index),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: backgroundColor, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.waving_hand;
      case 1:
        return Icons.connect_without_contact;
      case 2:
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Interprete';
      case 1:
        return 'Translate';
      case 2:
        return 'Settings';
      default:
        return '';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/translator_screen.dart';
import 'package:speakhands_mobile/screens/home_screen.dart';
import 'package:speakhands_mobile/screens/learn_screen.dart';
import 'package:speakhands_mobile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1;

  final AuthService _authService = AuthService();

  final screens = [
    const HomeScreen(),
    const TranslatorScreen(),
    const LearnScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 1) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      if (_authService.currentUser != null) {
        setState(() => _currentIndex = index);
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
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
          children: List.generate(4, (index) {
            bool isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 150 : 56, // Make the selected button wider
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30), // Round the button's corners
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
        return Icons.house;
      case 1:
        return Icons.connect_without_contact;
      case 2:
        return Icons.waving_hand;
      case 3:
        return Icons.account_circle;
      default:
        return Icons.circle;
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Translate';
      case 2:
        return 'Learning';
      case 3:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }
}

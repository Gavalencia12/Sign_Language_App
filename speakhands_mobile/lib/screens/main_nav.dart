import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/translator_screen.dart';
import 'package:speakhands_mobile/screens/learn_screen.dart';
import 'package:speakhands_mobile/screens/settings_screen.dart';
import 'package:speakhands_mobile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _controller;
  late Animation<double> _animation;

  final screens = [
    const TranslatorScreen(),
    const LearnScreen(),
    const TranslatorScreen(),
    const SettingsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: -10).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.forward(from: 0); // cada vez que seleccionas, hace el saltito
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? AppTheme.darkAccent : AppTheme.lightAccent;
    final floatingColor = isDarkMode ? AppTheme.darkSecondary : AppTheme.lightSecondary;
    final iconColor = isDarkMode ? AppTheme.lightText : AppTheme.lightText;

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                if (_currentIndex == index) {
                  return const SizedBox(width: 64);
                }

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForIndex(index),
                        size: 24,
                        color: iconColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Botón flotante animado
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: 40 + _animation.value,
                left: MediaQuery.of(context).size.width / 5 * _currentIndex +
                    (MediaQuery.of(context).size.width / 5 - 64) / 2,
                child: child!,
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: floatingColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getIconForIndex(_currentIndex),
                  size: 30,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.menu_book;
      case 2:
        return Icons.gesture;
      case 3:
        return Icons.settings;
      case 4:
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}

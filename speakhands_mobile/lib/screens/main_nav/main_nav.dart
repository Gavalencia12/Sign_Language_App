import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/interpreter/interpreter_screen.dart';
import 'package:speakhands_mobile/screens/settings/settings_screen.dart';
import 'package:speakhands_mobile/screens/translator/translator_screen.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// The main navigation widget that manages the bottom navigation bar
// and switches between the core app screens: **Interpreter**, **Translator**, and **Settings**.

// This widget uses a custom, animated bottom navigation bar
// to enhance the visual experience and provide smooth transitions
// between screens.
class MainNavigation extends StatefulWidget {
  /// A global key used to access the navigation state from anywhere in the app.
  static final GlobalKey<_MainNavigationState> globalKey =
      GlobalKey<_MainNavigationState>();

  // Creates a new instance of [MainNavigation].
  // The [key] is set to the static [globalKey] for global access.
  MainNavigation({Key? key}) : super(key: globalKey);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Holds the index of the currently selected tab.
  int _currentIndex = 1;

  // List of screens corresponding to each tab in the bottom navigation bar.
  final List<Widget> screens = const [
    InterpreterScreen(),
    TranslatorScreen(),
    SettingsScreen(),
  ];

  // Changes the active tab programmatically using the provided [index].
  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  // Handles user taps on navigation items.
  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic global colors based on current theme mode
    final Color backgroundColor = AppColors.primary(context);
    final Color surfaceColor = AppColors.surface(context);
    final Color iconColor = AppColors.text(context).withOpacity(0.8);

    return Scaffold(
      // Displays the screen corresponding to the selected tab
      body: screens[_currentIndex],

      // Custom bottom navigation bar with smooth animations and rounded design
      bottomNavigationBar: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.text(context).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(screens.length, (index) {
            bool isSelected = _currentIndex == index;

            final Color itemBackground =
                isSelected ? backgroundColor : Colors.transparent;
            final Color itemIconColor =
                isSelected ? AppColors.onPrimary(context) : iconColor;

            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 130 : 56,
                height: 48,
                decoration: BoxDecoration(
                  color: itemBackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForIndex(index),
                        size: 26,
                        color: itemIconColor,
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            _getTextForIndex(index),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
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

  // Returns the corresponding icon for each tab index.
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.waving_hand_rounded;
      case 1:
        return Icons.connect_without_contact;
      case 2:
        return Icons.settings_rounded;
      default:
        return Icons.circle;
    }
  }

  // Returns the label text for each tab index.
  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Interprete';
      case 1:
        return 'Traductor';
      case 2:
        return 'Ajustes';
      default:
        return '';
    }
  }
}

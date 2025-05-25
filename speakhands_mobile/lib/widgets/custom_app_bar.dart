import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.isDarkMode
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    final textColor = themeProvider.isDarkMode
        ? Colors.white
        : const Color(0xFF2F3A4A);

    return AppBar(
      backgroundColor: backgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text("Speak", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              Text("Hands", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

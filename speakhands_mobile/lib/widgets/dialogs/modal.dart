import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class Modal {
  static void show(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final Color backgroundColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color primaryColor = AppColors.primary(context);
    final Color handleColor = AppColors.text(context).withOpacity(0.3);

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        final themeMode = themeProvider.themeModeOption;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              
              Text(
                'Seleccionar tema',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),

              
              RadioListTile<ThemeModeOption>(
                activeColor: primaryColor,
                title: Text(
                  'Claro',
                  style: TextStyle(color: textColor),
                ),
                value: ThemeModeOption.light,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                    Navigator.pop(context);
                  }
                },
              ),

              
              RadioListTile<ThemeModeOption>(
                activeColor: primaryColor,
                title: Text(
                  'Oscuro',
                  style: TextStyle(color: textColor),
                ),
                value: ThemeModeOption.dark,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                    Navigator.pop(context);
                  }
                },
              ),

              
              RadioListTile<ThemeModeOption>(
                activeColor: primaryColor,
                title: Text(
                  'Predeterminado del sistema',
                  style: TextStyle(color: textColor),
                ),
                value: ThemeModeOption.system,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                    Navigator.pop(context);
                  }
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

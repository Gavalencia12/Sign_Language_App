import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

// Displays a bottom sheet allowing the user to choose between
// Light, Dark, or System default theme modes.
// It interacts with [ThemeProvider] to persist the selected mode
// across app sessions using `SharedPreferences`.

// Features:
// - Smooth, native-style bottom sheet with rounded corners.
// - Adaptive color palette using [AppColors].
// - Persists the user's theme preference locally.
// - Accessible and easy to use on both light and dark themes.
class Modal {
  // Displays the theme selection bottom sheet.
  static void show(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // === Retrieve adaptive colors based on the current theme ===
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
              // === Handle bar (for dragging the modal) ===
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // === Title ===
              Text(
                'Seleccionar tema',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // === Light mode option ===
              RadioListTile<ThemeModeOption>(
                activeColor: primaryColor,
                title: Text(AppLocalizations.of(context)!.light, style: TextStyle(color: textColor)),
                value: ThemeModeOption.light,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                    Navigator.pop(context);
                  }
                },
              ),

              // === Dark mode option ===
              RadioListTile<ThemeModeOption>(
                activeColor: primaryColor,
                title: Text( AppLocalizations.of(context)!.dark, style: TextStyle(color: textColor)),
                value: ThemeModeOption.dark,
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                    Navigator.pop(context);
                  }
                },
              ),

              // === System default option ===
              RadioListTile<ThemeModeOption>(
                activeColor: primaryColor,
                title: Text(
                  AppLocalizations.of(context)!.system,
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

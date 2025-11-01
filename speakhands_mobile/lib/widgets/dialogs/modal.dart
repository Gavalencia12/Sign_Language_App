import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';

class Modal {
  static void show(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        final themeMode = themeProvider.themeMode;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Seleccionar tema',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              RadioListTile<ThemeMode>(
                title: const Text('Claro'),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (mode) {
                  themeProvider.setThemeMode(mode!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Oscuro'),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (mode) {
                  themeProvider.setThemeMode(mode!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Predeterminado del sistema'),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (mode) {
                  themeProvider.setThemeMode(mode!);
                  Navigator.pop(context);
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

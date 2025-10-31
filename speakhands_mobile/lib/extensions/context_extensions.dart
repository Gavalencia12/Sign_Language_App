// Extensiones útiles para Theme, MediaQuery, etc.

import 'package:flutter/material.dart';

extension ContextTheme on BuildContext {
  // Colores
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get background => Theme.of(this).colorScheme.surface;
  Color get textColor => Theme.of(this).colorScheme.onSurface;

  // Tipografías
  TextStyle get title => Theme.of(this).textTheme.titleLarge!;
  TextStyle get body => Theme.of(this).textTheme.bodyMedium!;
}

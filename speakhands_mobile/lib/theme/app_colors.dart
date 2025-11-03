import 'package:flutter/material.dart';

/// Paleta de colores global que se adapta automáticamente
/// según el tema (claro u oscuro).
class AppColors {
  // ===== 🎨 PALETA BASE =====
  // Aquí defines los colores principales de tu marca.
  // (Puedes ajustar estos valores con tu propia paleta)
  static const Color primaryLight = Color(0xFF44CBCC);
  static const Color primaryDark = Color(0xFF5C8DAD);

  static const Color secondaryLight = Color(0xFFAEC6CF);
  static const Color secondaryDark = Color(0xFF6D9DC5);

  static const Color successLight = Color(0xFF28A745);
  static const Color successDark = Color(0xFF66BB6A);

  static const Color warningLight = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFB300);

  static const Color errorLight = Color(0xFFDC3545);
  static const Color errorDark = Color(0xFFEF5350);

  /* static const Color backgroundLight = Color(0xFFE3E7FF); */

  /* static const Color backgroundLight = Color.fromARGB(255, 233, 236, 247); */
  static const Color backgroundLight = Color.fromARGB(255, 233, 235, 240);
  static const Color backgroundDark = Color(0xFF00010D);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color.fromARGB(255, 22, 22, 28);
  /* static const Color surfaceDark = Color(0xFF121212); */

  static const Color textLight = Color(0xFF2F3A4A);
  static const Color textDark = Color(0xFFBDBDBD);

//
  static const Color sectiontextLight = Color(0xFF2F3A4A);
  static const Color sectiontextDark = Color(0xFFBDBDBD);

  // ===== 🌞 MÉTODOS DINÁMICOS =====
  static Color primary(BuildContext context) =>
      _isDark(context) ? primaryDark : primaryLight;

  static Color secondary(BuildContext context) =>
      _isDark(context) ? secondaryDark : secondaryLight;

  static Color success(BuildContext context) =>
      _isDark(context) ? successDark : successLight;

  static Color warning(BuildContext context) =>
      _isDark(context) ? warningDark : warningLight;

  static Color error(BuildContext context) =>
      _isDark(context) ? errorDark : errorLight;

  static Color background(BuildContext context) =>
      _isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;

  static Color text(BuildContext context) =>
      _isDark(context) ? textDark : textLight;

    // 🔹 NUEVO: Color para contenido sobre el color primario
  static Color onPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.white;

  // 🔹 NUEVO (opcional): Color para contenido sobre el fondo
  static Color onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

    // ===== NUEVOS MÉTODOS DE TEXTO =====

  /// Color base para el texto principal (párrafos, labels)
  static Color textNormal(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.9)
          : Colors.black87;

  /// Color más fuerte para títulos o encabezados
  static Color textStrong(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  /// Color atenuado (por ejemplo, texto secundario o hint)
  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.black54;
        
  // ===== 🧠 HELPER =====
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}




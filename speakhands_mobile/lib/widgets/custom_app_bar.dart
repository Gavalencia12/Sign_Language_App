import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// 🔹 Permite personalizar el color de fondo y el texto si se desea.
  final Color? backgroundColor;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Colores dinámicos según el tema activo
    final Color bgColor = backgroundColor ?? AppColors.background(context);
    final Color textColor = titleColor ?? AppColors.primary(context);
    final Color accentColor = AppColors.text(context);

    return AppBar(
      elevation: 0,
      backgroundColor: bgColor,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Título principal de la pantalla
          Text(
            title.toUpperCase(),
            style: AppTextStyles.textTitle.copyWith(
              color: accentColor,
              letterSpacing: 0.8,
            ),
          ),

          // 🔹 Branding “SpeakHands”
          Row(
            children: [
              Text(
                "Speak",
                style: AppTextStyles.textTitle.copyWith(
                  color: textColor,
                ),
              ),
              Text(
                "Hands",
                style: AppTextStyles.textTitle.copyWith(
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

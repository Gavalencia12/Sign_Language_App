import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  /// 🔹 Permite opcionalmente pasar un color personalizado
  final Color? color;

  const SettingsCard({
    required this.children,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final Color backgroundColor = color ?? AppColors.surface(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.text(context).withOpacity(0.1), // 🔹 Borde sutil adaptable
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      ),
    );
  }
}

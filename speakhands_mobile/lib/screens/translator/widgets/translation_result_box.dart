import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class TranslationResultBox extends StatelessWidget {
  final String text;

  const TranslationResultBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Colores dinámicos según tema
    final Color backgroundColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color borderColor = AppColors.primary(context).withOpacity(0.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

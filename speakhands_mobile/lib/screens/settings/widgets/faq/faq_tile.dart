import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class FaqTile extends StatelessWidget {
  final FaqItem item;
  const FaqTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color iconColor = AppColors.primary(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.text(
            context,
          ).withOpacity(0.1), // borde sutil adaptable
          width: 0.8,
        ),
      ),
      child: Theme(
        // 🔹 Ajustamos el color del ícono de expansión según el tema
        data: Theme.of(context).copyWith(
          dividerColor:
              Colors.transparent, // elimina la línea interna por defecto
          iconTheme: IconThemeData(color: iconColor),
        ),
        child: ExpansionTile(
          leading: Icon(Icons.help_outline, color: iconColor),
          title: Text(
            item.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          children:
              item.answers
                  .map(
                    (a) => ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        a,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

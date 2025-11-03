import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';
import 'faq_tile.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class FaqModal extends StatelessWidget {
  final List<FaqItem> items;
  const FaqModal({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color iconColor = AppColors.text(context).withOpacity(0.8);
    final Color handleColor = AppColors.text(context).withOpacity(0.3);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // 🔹 Pequeño "handle" superior para arrastrar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 8),

              // 🔹 Título y botón de cierre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Preguntas frecuentes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: iconColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // 🔹 Contenido de preguntas frecuentes
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => FaqTile(item: items[i]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

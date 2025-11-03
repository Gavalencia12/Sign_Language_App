import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';
import 'faq_tile.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A modal bottom sheet that displays a scrollable list of all
// Frequently Asked Questions (FAQs).
// This modal is typically triggered from the “Help” screen’s
// “See more” button, allowing users to browse the full list of
// questions and answers in an interactive, scrollable interface.
// The modal uses a [DraggableScrollableSheet] so the user can
// expand or collapse it dynamically.
class FaqModal extends StatelessWidget {
  // The list of FAQ items to display inside the modal.
  final List<FaqItem> items;
  const FaqModal({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Retrieve theme-based colors for consistent design
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

              // Small top handle to indicate the modal can be dragged
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 8),

              // Header section with title and close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Preguntas frecuentes',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
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

              // Scrollable FAQ content list
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

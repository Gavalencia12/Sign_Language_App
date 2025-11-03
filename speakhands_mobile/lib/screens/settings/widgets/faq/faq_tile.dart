import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A widget that represents a single Frequently Asked Question (FAQ) entry.
// Each [FaqTile] displays:
// - A **question** as the main title.
// - One or more **answers** that can be expanded or collapsed using
//   Flutter’s built-in [ExpansionTile].
// The design adapts automatically to the current app theme (light/dark)
// using dynamic colors from [AppColors].
class FaqTile extends StatelessWidget {
  /// The FAQ data model containing the question and its list of answers.
  final FaqItem item;
  const FaqTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on the current theme
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
          ).withOpacity(0.1), // subtle adaptive border
          width: 0.8,
        ),
      ),
      child: Theme(
        // Override internal ExpansionTile styles
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // removes default divider line
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

          // Displays each answer as a separate ListTile when expanded
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

import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class FaqTile extends StatelessWidget {
  final FaqItem item;
  const FaqTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: AppColors.lightForebackground,
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline),
        title: Text(
          item.question,
          style: theme.textTheme.titleMedium,
        ),
        children: item.answers
            .map((a) => ListTile(
                  title: Text(a, style: theme.textTheme.bodyMedium),
                  
                ))
            .toList(),
      ),
    );
  }
}

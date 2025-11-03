import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A simple widget used to display a placeholder message
// when a list or data view has no results.
// Commonly used to indicate that no items match the current
// search or that no data is available.
class EmptyState extends StatelessWidget {
  /// The message to display in the empty state.
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.text(context).withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

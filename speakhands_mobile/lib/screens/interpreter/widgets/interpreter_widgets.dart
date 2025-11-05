import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final Function(String) onChanged;

  CustomTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        minLines: 3,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(fontSize: 18, color: AppColors.text(context)),
        onChanged: onChanged,
      ),
    );
  }
}

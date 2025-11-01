import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: AppColors.lightForebackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(children: children),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle lightTextStyle = TextStyle(color: AppColors.textLight, fontSize: 16);
  static TextStyle darkTextStyle = TextStyle(color: AppColors.textDark, fontSize: 16);

  static TextStyle titleLargeLight = TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold);
  static TextStyle titleLargeDark = TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold);

  static const TextStyle heading6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const textTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}

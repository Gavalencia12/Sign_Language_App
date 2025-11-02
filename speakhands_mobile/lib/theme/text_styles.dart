import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle lightTextStyle = TextStyle(color: AppColors.lightText, fontSize: 16);
  static TextStyle darkTextStyle = TextStyle(color: AppColors.darkText, fontSize: 16);

  static TextStyle titleLargeLight = TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold);
  static TextStyle titleLargeDark = TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold);

  static const TextStyle heading6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
}

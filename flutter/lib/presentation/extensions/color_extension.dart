import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';

extension ColorX on Color {
  /// Returns a [MaterialColor] from a [Color] object
  MaterialColor getMaterialColorFromColor() {
    final colorShades = <int, Color>{
      50: AppColors.getShade(this, value: 0.5),
      100: AppColors.getShade(this, value: 0.4),
      200: AppColors.getShade(this, value: 0.3),
      300: AppColors.getShade(this, value: 0.2),
      400: AppColors.getShade(this, value: 0.1),
      500: this, //Primary value
      600: AppColors.getShade(this, value: 0.1, darker: true),
      700: AppColors.getShade(this, value: 0.15, darker: true),
      800: AppColors.getShade(this, value: 0.2, darker: true),
      900: AppColors.getShade(this, value: 0.25, darker: true),
    };
    return MaterialColor(value, colorShades);
  }

  Color get contrastColor {
    // computeLuminance() -> value is from 0 (black) to 1 (white)
    return computeLuminance() > 0.5 ? AppColors.black : AppColors.white;
  }
}
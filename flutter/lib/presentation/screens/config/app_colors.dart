import 'dart:collection';

import 'package:flutter/material.dart';

class AppColors {
  static const lightGray2 = Color(0xFF898A8D);
  static const gray = Color(0xFFCCCED3);
  static const primary = Color(0xFFE82622);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const shark = Color(0xFF212529);
  static const outerSpace = Color(0xFF343A40);
  static const paleSky = Color(0xFF6C757D);
  static const green = Color(0xFF21BF73);
  static const greenDark = Color(0xFF008000);
  static const greenSec = Color(0xFFDCF9EB);
  static const yellow = Colors.yellow;
  static const red = Color(0xFFD90429);
  static const redSec = Color(0xFFFFEBEE);
  static const blueSec = Color(0xFFECF4FF);
  static const orange = Color(0xFFFFB800);
  static const orangeDim = Color(0xFFcc5500);
  static const orangeDeep = Color(0xffff0000);
  static const whiteBeige = Color.fromRGBO(255, 209, 128, 0.09);

  static const goldenYellow = Color(0xffd4b106);
  static const lightLemon = Color(0xfffffbe6);
  static const pumpkin = Color(0xffd46b08);
  static const peach = Color(0xfffff2e8);
  // static const mediumGray = Color(0xff8c8c8c);
  // static const lightGray = Color(0xfff5f5f5);
  static const emeraldGreen = Color(0xff389e0d);
  static const mintGreen = Color(0xfff6ffed);

  static const transparent = Colors.transparent;

  /// Outlines a text using shadows.
  static List<Shadow> outlinedText({double strokeWidth = 1, Color strokeColor = Colors.black, int precision = 3}) {
    Set<Shadow> result = HashSet();
    for (int x = 1; x < strokeWidth + precision; x++) {
      for(int y = 1; y < strokeWidth + precision; y++) {
        double offsetX = x.toDouble();
        double offsetY = y.toDouble();
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      }
    }
    return result.toList();
  }

  static Color getShade(Color color, {bool darker = false, double value = .1}) {
    assert(value >= 0 && value <= 1, 'shade values must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
      (darker ? (hsl.lightness - value) : (hsl.lightness + value))
          .clamp(0.0, 1.0),
    );

    return hslDark.toColor();
  }

}

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
  'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

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

  static const textFieldBorder = Color(0xFF6C757D);
  static const loginButtonBg = Color(0xFF0a12bf);
  static const appBarBackgroundColor = Color(0xFF070042);

  static const blue = Color(0xFF0063F5);
  static const cyan = Color(0xFF00BCD4);
  static const cyanLight = Color(0xFFE0F7FA);
  static const textColor = Color(0xFF343A40);
  static const textColorLight = Color(0xFFFFFFFF);

  static const textMediumGreyColor = Color(0x7f7f7f00);
  static const lightGrey = Color(0xFFf2f2f2);
  static const textLightGrey = Color.fromRGBO(135, 135, 135, 0.7);

  static const overlapBackground = Color(0x80343A40);

  static const activeTabColor = Color.fromRGBO(10, 18, 191, 1); // Color(0x0A12BF00);
  static const tabColor = Color.fromRGBO(10, 18, 191, 0.39);
  static const borderColor = Color(0xFF797979);

  static const pink = Colors.purple;
  static const purple = Color.fromARGB(255, 112, 66, 212);
  static const lightPurple = Color(0xffdfd0ff);
  static const lightBlue = Color(0xFFe3eaff);

  static const bgSnackBarGreen = Color.fromRGBO(218, 240, 200, 1);
  static const borderSnackBarGreen = Color(0xff2ec555);
  static const bgSnackBarRed = Color(0xFFFFEBEE);
  static const borderSnackBarRed = Color(0xFFD90429);
  static const snackBarTextColor = Color(0xff333333);


  static const light = Color(0xffccccd3);
  static const lightMedium = Color(0xFF9999a7);
  static const darkMedium = Color(0xff66667c);
  static const dark = Color(0xFF333350);

  static const lightGreyBorder = Color(0xffecebeb);
  static const greyBorder = Color(0xFF797979);
  static const bgGrey = Color.fromRGBO(148, 148, 148, 0.23);
  static const bgGreyShadow = Color.fromRGBO(0, 0, 0, 0.24);

  static const weightChartEmptyColor = Color(0xFFf0f0f0);
  static const weightChartColor1 = Color(0xffA2A7F4);
  static const weightChartColor2 = Color(0xff7042D4);
  static const weightChartColor3 = Color(0xff130076);

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

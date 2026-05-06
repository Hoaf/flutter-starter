import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_font_sizes.dart';

class AppSnackBars {
  static void show(BuildContext context, String message,
      {Color color = const Color(0xFF333333),
      Color textColor = AppColors.white}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
        content: Text(message,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 14,
              color: textColor,
            )),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 20),
      ));
    });
  }

  static void showSafeSnackBar(BuildContext context, String message) {
    show(context, message, color: AppColors.green);
  }

  static void showDangerSnackBar(BuildContext context, String message) {
    show(context, message, color: AppColors.red);
  }

  static void showAttentionSnackBar(BuildContext context, String message) {
    show(context, message,
        color: AppColors.orange, textColor: AppColors.black);
  }

  static void showAbpSnackBarWithIcon(BuildContext context, String message,
      {String title = "Success", String iconName = "ic_tick.svg",
        Color color = AppColors.bgSnackBarGreen,
        Color borderColor = AppColors.borderSnackBarGreen}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.fixed,
      // margin: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
      content: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
            color: color
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/$iconName", width: 20, height: 20),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                        color: AppColors.snackBarTextColor,
                        fontSize: AppFontSizes.fs_15,
                        fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4,),
                    Text(message,
                        style: const TextStyle(
                          fontSize: AppFontSizes.fs_15,
                          color: AppColors.snackBarTextColor,
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      // padding: const EdgeInsets.symmetric(
      //     vertical: 16, horizontal: 20),
    ));
  }

  static void showAbpSnackBarInSuccess(BuildContext context, String message) {
    showAbpSnackBarWithIcon(context, message);
  }

  static void showAbpSnackBarInFailure(BuildContext context, String message) {
    showAbpSnackBarWithIcon(
        context, message, title: "Error", iconName: "ic_close.svg",
        borderColor: AppColors.borderSnackBarRed, color: AppColors.bgSnackBarRed
    );
  }

  static void dismissSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

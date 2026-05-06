import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_font_sizes.dart';
import 'buttons/flat_button.dart';

class DialogUtils {
  static Future<void>showAlertDialog(BuildContext context, String? title, Widget content, {String actionText = "OK", VoidCallback? onActionPressed,
    bool barrierDismissible = true, double titleSize = 18, bool preventBackButton = false}) async {
    return await showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async {
          if(!preventBackButton) {
            Navigator.of(dialogContext).pop();
          }
          return false;
        },
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          backgroundColor: AppColors.white,
          title: title == null ? null : Text(title, style: TextStyle(fontSize: titleSize),),
          content: content,
          actions: <Widget>[
            FlatButton(actionText, backgroundColor: AppColors.loginButtonBg, isWrapWidth: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onActionPressed?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  static bool _isDialogShowing = false;
  static void showTwoActionsDialog(
      BuildContext context,
      String title,
      Widget content,
      {
        double titleSize = AppFontSizes.fs_20,
        String actionText1 = "OK",
        VoidCallback? onActionPressed1,
        String actionText2 = "CANCEL",
        VoidCallback? onActionPressed2,
        bool barrierDismissible = true
      }) {
    _isDialogShowing = true;
    showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        backgroundColor: AppColors.white,
        title: Text(title, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w500),),
        content: content,
        actions: <Widget>[
          FlatButton(actionText1, backgroundColor: AppColors.gray, foregroundColor: AppColors.black, isWrapWidth: true,
            onPressed: () {
              _isDialogShowing = false;
              Navigator.of(dialogContext).pop();
              onActionPressed1?.call();
            },
          ),
          FlatButton(actionText2, backgroundColor: AppColors.loginButtonBg, isWrapWidth: true,
            onPressed: () {
              _isDialogShowing = false;
              Navigator.of(dialogContext).pop();
              onActionPressed2?.call();
            },
          ),
        ],
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }
  static bool get isDialogShowing => DialogUtils._isDialogShowing;
  static void dismiss(BuildContext dialogContext) => Navigator.of(dialogContext).pop();

}
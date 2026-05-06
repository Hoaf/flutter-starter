import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingHelper {
  static Widget Function(BuildContext, Widget?) initLoading({
    TransitionBuilder? builder,
  }) {
    return EasyLoading.init(builder: builder);
  }

  static void configLoading() {
    EasyLoading.instance
      ..maskType = EasyLoadingMaskType.none
      ..indicatorSize = 40.0
      ..radius = 10.0
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  static void show() {
    EasyLoading.show();
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }

  static bool get isShow => EasyLoading.isShow;
}

import 'package:flutter_demo/presentation/screens/widgets/dialog_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class PermissionUtils {
  static Future<void> checkStorage(BuildContext context, {VoidCallback? onGranted}) async {
    // TODO check if is IOS
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PermissionStatus result;
    if(Platform.isAndroid && (await DeviceInfoPlugin().androidInfo).version.sdkInt > 32) {
      // result = await Permission.photos.request();
      onGranted?.call();
      return;
    } else {
      result = await Permission.storage.request();
    }
    switch (result) {
      case PermissionStatus.granted:
        onGranted?.call();
        return;
      case PermissionStatus.limited:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        return;
      case PermissionStatus.permanentlyDenied:
        DialogUtils.showTwoActionsDialog(context, "Permission Required",
            Text(
                "To download this file, please allow ABP LiveStock access to your device's files. Tap Settings > App Info (ABP Livestock) > Permissions, and turn \"Files and media\" or \"Storage\" on."),
            actionText1: "Not now",
            actionText2: "Settings",
            onActionPressed2: () {
              openAppSettings();
            });
        return;
      case PermissionStatus.provisional:
        return;
    }
  }
}
import 'dart:async';

import 'package:flutter_demo/globals.dart' as globals;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CalculatorUtils {
  static expireTimeStampFromLifeTokenTime(int lifeTokenTime) {
    return DateTime.now().millisecondsSinceEpoch + lifeTokenTime * 1000;
  }

  static checkTokenExpired(int tokenExpiredTime) {
    //300000 milliseconds is a buffer to avoid boundary testing
    //300000 mils = 5 minutes
    // print("====> ${DateTime.now().millisecondsSinceEpoch >= tokenExpiredTime - convertMinuteToMils(29)}");
    return DateTime.now().millisecondsSinceEpoch >= tokenExpiredTime - convertMinuteToMils(5);
  }

  static convertMinuteToMils(int minutes) {
    return minutes * 60000;
  }

  static bool isSessionTimeout() {
    int now = DateTime.now().millisecondsSinceEpoch;
    int deltaTime = now - globals.lastInteractiveTime;
    return deltaTime > CalculatorUtils.convertMinuteToMils(30);
  }

  static Timer? _timer;
  // static const int _durationInMin = 1;

  static void startAnyway(VoidCallback? onInactivateCallback) {
    var hasShownPopup = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1), (Timer timer) {
        if (kDebugMode) {
          print(globals.lastInteractiveTime);
        }
        if (isSessionTimeout() && !hasShownPopup) {
          onInactivateCallback?.call();
          hasShownPopup = true;
        }
      },
    );
  }

  static void destroyTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
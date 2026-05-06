import 'package:flutter_demo/presentation/helper/loading_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart';

import 'data/services/config/environments_config.dart';
import 'di/injector.dart';
import 'presentation/myapp.dart';
import 'presentation/utilities/logger.dart';

void main() async {
  // await loadInitInstanceApp();

  runApp(const MyApp());
  LoadingHelper.configLoading();
}

Future<void> loadInitInstanceApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  ByteData tzf = await rootBundle.load('assets/timezone/latest_all.tzf');
  initializeDatabase(tzf.buffer.asUint8List());

  await F.loadEnv();
  // await AppDependency.inject();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await configureLogger();
}

Future<void> configureLogger() async {
  if (kDebugMode) {
    // Add standard log output only on debug builds
    AppLogger.addLogger(DebugLogger());
    FlutterError.onError = (FlutterErrorDetails details) async {
      AppLogger.e(details, details.exception, details.stack);
    };
  } else {
    // Pass all uncaught errors from the framework to Crashlytics.
    // FlutterError.onError
    AppLogger.addLogger(ProductionLogger());
  }
}

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/data/services/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environments { dev, staging, prod }

extension EnviromentsExt on Environments {
  String get fileName {
    switch (this) {
      case Environments.dev:
        return 'lib/configs/env/dev.env';
      case Environments.staging:
        return 'lib/configs/env/stag.env';
      case Environments.prod:
        return 'lib/configs/env/prod.env';
    }
  }
}

class F {
  static Environments env = Environments.dev;

  static Future<void> checkEnvironment() async {
    /// Check package name to know dev or prod.
    // final packageInfo = await PackageInfo.fromPlatform();
    // final packageName = packageInfo.packageName;

    String flavor = await const MethodChannel('flavor')
        .invokeMethod<String>('getFlavor') ?? "prod"; // prod as default
    env = detectEnv(flavor);
  }

  static Future<String> applicationVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<void> loadEnv() async {
    await checkEnvironment();
    final _ = await dotenv.load(fileName: env.fileName);
    APIConfig.baseApiUrl = dotenv.env['BASE_API_URL'] ?? '';
    APIConfig.baseGraphQLApiUrl = dotenv.env['BASE_GRAPHQL_API_URL'] ?? '';
    APIConfig.baseUrlBrowser = dotenv.env['BASE_URL_BROWSER'] ?? '';
  }

  static Environments detectEnv(String packageName) {
    if (packageName.endsWith('dev')) {
      return Environments.dev;
    } else if (packageName.endsWith('staging')) {
      return Environments.staging;
    }
    return Environments.prod;
  }
}

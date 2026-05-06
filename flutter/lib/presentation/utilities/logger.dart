import 'package:logger/logger.dart';

class AppLogger {
  static late NTLogger _ntLogger;

  static addLogger(NTLogger logger) {
    _ntLogger = logger;
  }

  static bool get _isDisableLog {
    //use for disable log view in some use case
    return false;
  }

  static v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDisableLog) return;
    _ntLogger.onLog(Level.verbose, message, error, stackTrace);
  }

  static d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDisableLog) return;
    _ntLogger.onLog(Level.debug, message, error, stackTrace);
  }

  static i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDisableLog) return;
    _ntLogger.onLog(Level.info, message, error, stackTrace);
  }

  static w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDisableLog) return;
    _ntLogger.onLog(Level.warning, message, error, stackTrace);
  }

  static e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDisableLog) return;
    _ntLogger.onLog(Level.error, message, error, stackTrace);
  }

  static wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDisableLog) return;
    _ntLogger.onLog(Level.wtf, message, error, stackTrace);
  }
}

abstract class NTLogger {
  void onLog(Level level, dynamic message,
      [dynamic error, StackTrace? stackTrace]);
}

class DebugLogger implements NTLogger {
  static final _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
        printTime: false,
      ));
  @override
  void onLog(Level level, message, [dynamic error, StackTrace? stackTrace]) {
    _logger.log(level, message, error:  error, stackTrace: stackTrace);
  }
}

class ProductionLogger implements NTLogger {
  @override
  void onLog(Level level, message, [dynamic error, StackTrace? stackTrace]) {
    switch (level) {
      case Level.error:
      // send report to report to Crashlytics/ sentry
      default:
    }
  }
}
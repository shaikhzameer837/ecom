import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Central logging. Debug builds log to console; release builds forward
/// errors to Crashlytics.
class AppLogger {
  AppLogger._();

  static void d(String message, {String tag = 'App'}) {
    if (kDebugMode) developer.log(message, name: tag);
  }

  static void e(String message, {Object? error, StackTrace? stackTrace, String tag = 'App'}) {
    if (kDebugMode) {
      developer.log(message, name: tag, error: error, stackTrace: stackTrace, level: 1000);
    } else {
      FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace, reason: message);
    }
  }
}

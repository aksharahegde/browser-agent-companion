import 'dart:developer' as developer;

void logInfo(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(message, name: 'cua_companion', error: error, stackTrace: stackTrace);
}

void logError(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'cua_companion',
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );
}

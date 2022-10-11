import 'dart:ui';

import 'package:flutter/src/foundation/assertions.dart';
import 'package:movie_gallery/http/model/ErrorReportPostRequest.dart';
import 'package:movie_gallery/inject/injection.dart';

import 'http/MyClient.dart';

class AppErrorHandler {
  MyClient myClient = getIt<MyClient>();

  void registerErrorHandler() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      this._onErrorDetail(details);
    };
    PlatformDispatcher.instance.onError = (exception, stackTrace) {
      this._onError(exception, stackTrace);
      return false;
    };
  }

  void _onErrorDetail(FlutterErrorDetails details) {
    String message = details.exceptionAsString();
    String stackString = details.stack.toString();
    _report(message, stackString);
  }

  void _onError(Object exception, StackTrace stackTrace) {
    String message = exception.toString();
    String stackString = stackTrace.toString();

    _report(message, stackString);
  }

  void _report(String message, String stackString) {
    ErrorReportPostRequest request =
        ErrorReportPostRequest(message: message, stacktrace: stackString);
    myClient.errorReportPost(request);
  }
}

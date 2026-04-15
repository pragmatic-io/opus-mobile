import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('[API REQUEST] ${options.method} ${options.uri}');
      print('[API REQUEST] Headers: ${_sanitizeHeaders(options.headers)}');
      if (options.data != null) {
        print('[API REQUEST] Body: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('[API REQUEST] Query: ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('[API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
      print('[API RESPONSE] Body: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('[API ERROR] ${err.type} ${err.requestOptions.uri}');
      print('[API ERROR] Message: ${err.message}');
      if (err.response != null) {
        print('[API ERROR] Status: ${err.response?.statusCode}');
        print('[API ERROR] Body: ${err.response?.data}');
      }
    }
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = 'Bearer [REDACTED]';
    }
    return sanitized;
  }
}

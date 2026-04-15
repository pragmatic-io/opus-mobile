import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;
  final Dio _dio;

  AuthInterceptor({
    FlutterSecureStorage? storage,
    required Dio dio,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await _retryRequest(err.requestOptions);
        if (retryResponse != null) {
          handler.resolve(retryResponse);
          return;
        }
      }
      await _clearTokens();
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ),
      );

      final data = response.data;
      if (data == null) return false;

      final newToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newToken == null) return false;

      await _storage.write(key: _tokenKey, value: newToken);
      if (newRefreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response<dynamic>?> _retryRequest(RequestOptions requestOptions) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final options = Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
      );

      return await _dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

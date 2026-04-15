import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opus_mobile/core/api/api_client.dart';
import 'package:opus_mobile/features/auth/models/auth_model.dart';

const String _authTokenKey = 'auth_token';
const String _refreshTokenKey = 'refresh_token';

class AuthService {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthService({
    ApiClient? api,
    FlutterSecureStorage? storage,
  })  : _api = api ?? ApiClient.instance,
        _storage = storage ?? const FlutterSecureStorage();

  /// Sends an OTP to the given phone number (e.g. "+225XXXXXXXXXX").
  Future<void> sendOtp(String phone) async {
    await _api.post<dynamic>(
      '/auth/send-otp',
      data: {'phone': phone},
    );
  }

  /// Verifies the OTP code and returns an [OtpResponse] containing tokens.
  Future<OtpResponse> verifyOtp(String phone, String code) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {
        'phone': phone,
        'code': code,
      },
    );
    return OtpResponse.fromJson(data);
  }

  /// Persists [token] and [refreshToken] in secure storage.
  Future<void> saveTokens(String token, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _authTokenKey, value: token),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Removes all stored tokens, effectively logging the user out.
  Future<void> logout() async {
    await Future.wait([
      _storage.delete(key: _authTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  /// Returns `true` if a non-empty auth token is present in secure storage.
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

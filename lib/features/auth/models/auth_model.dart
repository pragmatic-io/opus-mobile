class OtpResponse {
  final String token;
  final String refreshToken;
  final bool isNewUser;

  const OtpResponse({
    required this.token,
    required this.refreshToken,
    required this.isNewUser,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      isNewUser: json['is_new_user'] as bool,
    );
  }

  @override
  String toString() =>
      'OtpResponse(token: [redacted], refreshToken: [redacted], isNewUser: $isNewUser)';
}

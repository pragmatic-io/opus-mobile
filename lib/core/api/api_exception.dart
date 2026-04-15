import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  const ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          statusCode: null,
          message: 'La connexion a expiré. Veuillez réessayer.',
          data: null,
        );
      case DioExceptionType.badResponse:
        final response = e.response;
        final statusCode = response?.statusCode;
        final responseData = response?.data;
        String message = 'Une erreur est survenue.';
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String? ??
              responseData['error'] as String? ??
              message;
        }
        return ApiException(
          statusCode: statusCode,
          message: message,
          data: responseData,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          statusCode: null,
          message: 'La requête a été annulée.',
          data: null,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          statusCode: null,
          message: 'Impossible de se connecter au serveur. Vérifiez votre connexion.',
          data: null,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          statusCode: null,
          message: 'Certificat SSL invalide.',
          data: null,
        );
      case DioExceptionType.unknown:
        return ApiException(
          statusCode: null,
          message: e.message ?? 'Une erreur inconnue est survenue.',
          data: null,
        );
    }
  }

  factory ApiException.networkError() {
    return const ApiException(
      statusCode: null,
      message: 'Erreur réseau. Vérifiez votre connexion internet.',
      data: null,
    );
  }

  factory ApiException.timeoutError() {
    return const ApiException(
      statusCode: null,
      message: 'La requête a expiré. Veuillez réessayer.',
      data: null,
    );
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

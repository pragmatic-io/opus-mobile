import 'dart:io';
import 'package:dio/dio.dart';
import 'package:opus_mobile/core/api/api_client.dart';
import 'package:opus_mobile/features/profile/models/profile_model.dart';

class ProfileService {
  final ApiClient _client;

  ProfileService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Creates a new profile. Sends as multipart/form-data when a local photo
  /// file path is provided, otherwise sends JSON.
  Future<void> createProfile(ProfileModel profile, {String? localPhotoPath}) async {
    if (localPhotoPath != null) {
      final formData = FormData.fromMap({
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'bio': profile.bio,
        'skills': profile.skills,
        if (profile.latitude != null) 'latitude': profile.latitude,
        if (profile.longitude != null) 'longitude': profile.longitude,
        if (profile.city != null) 'city': profile.city,
        'photo': await MultipartFile.fromFile(
          localPhotoPath,
          filename: File(localPhotoPath).uri.pathSegments.last,
        ),
      });

      await _client.post<dynamic>(
        '/profiles',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } else {
      await _client.post<dynamic>(
        '/profiles',
        data: profile.toJson(),
      );
    }
  }

  /// Fetches the current authenticated user's profile.
  Future<ProfileModel?> getMyProfile() async {
    try {
      final data = await _client.get<Map<String, dynamic>>('/profiles/me');
      return ProfileModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}

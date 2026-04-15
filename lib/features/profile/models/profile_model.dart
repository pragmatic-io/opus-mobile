class ProfileModel {
  final String? photoUrl;
  final String firstName;
  final String lastName;
  final String bio;
  final List<String> skills;
  final double? latitude;
  final double? longitude;
  final String? city;

  const ProfileModel({
    this.photoUrl,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.skills,
    this.latitude,
    this.longitude,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      if (photoUrl != null) 'photo_url': photoUrl,
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'skills': skills,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      photoUrl: json['photo_url'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      bio: json['bio'] as String,
      skills: List<String>.from(json['skills'] as List),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
    );
  }

  ProfileModel copyWith({
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? bio,
    List<String>? skills,
    double? latitude,
    double? longitude,
    String? city,
  }) {
    return ProfileModel(
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
    );
  }
}

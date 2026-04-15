class GomboModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double budget;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String location;
  final List<String> skills;
  final String employerName;
  final String? employerPhotoUrl;
  final bool isNew;
  final int applicationsCount;
  final double? distanceKm;

  const GomboModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.skills,
    required this.employerName,
    this.employerPhotoUrl,
    required this.isNew,
    required this.applicationsCount,
    this.distanceKm,
  });

  factory GomboModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
        : DateTime.now();

    final date = json['date'] != null
        ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
        : DateTime.now();

    final bool isNew =
        DateTime.now().difference(createdAt).inHours < 24;

    final rawSkills = json['skills'];
    final List<String> skills = rawSkills is List
        ? rawSkills.map((e) => e.toString()).toList()
        : <String>[];

    return GomboModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      date: date,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      location: (json['location'] ?? '') as String,
      skills: skills,
      employerName: (json['employer_name'] ?? '') as String,
      employerPhotoUrl: json['employer_photo_url'] as String?,
      isNew: isNew,
      applicationsCount: (json['applications_count'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'skills': skills,
      'employer_name': employerName,
      'employer_photo_url': employerPhotoUrl,
      'applications_count': applicationsCount,
      'distance_km': distanceKm,
    };
  }

  GomboModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? budget,
    DateTime? date,
    double? latitude,
    double? longitude,
    String? location,
    List<String>? skills,
    String? employerName,
    String? employerPhotoUrl,
    bool? isNew,
    int? applicationsCount,
    double? distanceKm,
  }) {
    return GomboModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      budget: budget ?? this.budget,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      employerName: employerName ?? this.employerName,
      employerPhotoUrl: employerPhotoUrl ?? this.employerPhotoUrl,
      isNew: isNew ?? this.isNew,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

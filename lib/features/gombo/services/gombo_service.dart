import 'dart:convert';
import 'package:opus_mobile/core/api/api_client.dart';
import 'package:opus_mobile/core/cache/cache_service.dart';
import 'package:opus_mobile/features/gombo/models/gombo_model.dart';

class GomboService {
  final ApiClient _api;
  final CacheService _cache;

  GomboService({
    ApiClient? api,
    CacheService? cache,
  })  : _api = api ?? ApiClient.instance,
        _cache = cache ?? CacheService();

  static const Duration _listTtl = Duration(minutes: 5);

  String _listCacheKey({
    int page = 1,
    int limit = 20,
    String? category,
    double? maxRadiusKm,
    double? minBudget,
    double? maxBudget,
    DateTime? fromDate,
    String sort = 'distance',
    double? userLat,
    double? userLng,
  }) {
    return 'gombos_list_${page}_${limit}_${category ?? ''}'
        '_${maxRadiusKm ?? ''}_${minBudget ?? ''}_${maxBudget ?? ''}'
        '_${fromDate?.toIso8601String() ?? ''}_${sort}_${userLat ?? ''}_${userLng ?? ''}';
  }

  /// GET /gombos with query params. Cache-first with 5-minute TTL.
  Future<List<GomboModel>> getGombos({
    int page = 1,
    int limit = 20,
    String? category,
    double? maxRadiusKm,
    double? minBudget,
    double? maxBudget,
    DateTime? fromDate,
    String sort = 'distance',
    double? userLat,
    double? userLng,
  }) async {
    final cacheKey = _listCacheKey(
      page: page,
      limit: limit,
      category: category,
      maxRadiusKm: maxRadiusKm,
      minBudget: minBudget,
      maxBudget: maxBudget,
      fromDate: fromDate,
      sort: sort,
      userLat: userLat,
      userLng: userLng,
    );

    // Cache-first strategy
    final cached = await _cache.get<String>(cacheKey);
    if (cached != null) {
      final List<dynamic> decoded = jsonDecode(cached) as List<dynamic>;
      return decoded
          .map((e) => GomboModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
    };
    if (category != null) queryParams['category'] = category;
    if (maxRadiusKm != null) queryParams['max_radius_km'] = maxRadiusKm;
    if (minBudget != null) queryParams['min_budget'] = minBudget;
    if (maxBudget != null) queryParams['max_budget'] = maxBudget;
    if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
    if (userLat != null) queryParams['lat'] = userLat;
    if (userLng != null) queryParams['lng'] = userLng;

    final responseData = await _api.get<dynamic>(
      '/gombos',
      queryParameters: queryParams,
    );

    List<dynamic> rawList;
    if (responseData is List) {
      rawList = responseData;
    } else if (responseData is Map<String, dynamic>) {
      rawList = (responseData['data'] ?? responseData['gombos'] ?? []) as List<dynamic>;
    } else {
      rawList = [];
    }

    final gombos = rawList
        .map((e) => GomboModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Store serialized list in cache
    await _cache.put<String>(
      cacheKey,
      jsonEncode(gombos.map((g) => g.toJson()).toList()),
      ttl: _listTtl,
    );

    return gombos;
  }

  /// GET /gombos/:id — network-first (no cache read).
  Future<GomboModel> getGomboById(String id) async {
    final responseData = await _api.get<dynamic>('/gombos/$id');

    Map<String, dynamic> raw;
    if (responseData is Map<String, dynamic>) {
      raw = responseData['data'] is Map<String, dynamic>
          ? responseData['data'] as Map<String, dynamic>
          : responseData;
    } else {
      throw Exception('Unexpected response format for gombo $id');
    }

    return GomboModel.fromJson(raw);
  }

  /// POST /gombos/:id/applications
  Future<void> applyToGombo(String gomboId) async {
    await _api.post<dynamic>('/gombos/$gomboId/applications');
  }
}

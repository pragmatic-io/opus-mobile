import 'package:opus_mobile/core/api/api_client.dart';
import 'package:opus_mobile/features/chat/models/message_model.dart';

class ChatService {
  final ApiClient _api;

  ChatService({ApiClient? api}) : _api = api ?? ApiClient.instance;

  /// GET /conversations/:id/messages?page=1&limit=30
  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
    String currentUserId = '',
  }) async {
    final data = await _api.get<dynamic>(
      '/conversations/$conversationId/messages',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      rawList = data['messages'] as List<dynamic>? ??
          data['data'] as List<dynamic>? ??
          [];
    } else {
      rawList = [];
    }

    return rawList
        .map((item) => MessageModel.fromJson(
              item as Map<String, dynamic>,
              currentUserId: currentUserId,
            ))
        .toList();
  }

  /// POST /conversations/:id/messages with {"content": "..."}
  Future<MessageModel> sendMessage(
    String conversationId,
    String content, {
    String currentUserId = '',
  }) async {
    final data = await _api.post<dynamic>(
      '/conversations/$conversationId/messages',
      data: {'content': content},
    );

    final Map<String, dynamic> json;
    if (data is Map<String, dynamic>) {
      json = data['message'] as Map<String, dynamic>? ??
          data['data'] as Map<String, dynamic>? ??
          data;
    } else {
      throw Exception('Unexpected response format from sendMessage');
    }

    return MessageModel.fromJson(json, currentUserId: currentUserId);
  }
}

enum MessageStatus { sending, sent, delivered, read }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final MessageStatus status;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.status,
    required this.isMe,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = json['senderId'] as String? ??
        json['sender_id'] as String? ??
        '';
    return MessageModel(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ??
          json['conversation_id'] as String? ??
          '',
      senderId: senderId,
      content: json['content'] as String? ?? '',
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : json['sent_at'] != null
              ? DateTime.parse(json['sent_at'] as String)
              : DateTime.now(),
      status: _statusFromString(json['status'] as String?),
      isMe: senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'status': status.name,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    DateTime? sentAt,
    MessageStatus? status,
    bool? isMe,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      isMe: isMe ?? this.isMe,
    );
  }

  static MessageStatus _statusFromString(String? value) {
    switch (value) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }
}

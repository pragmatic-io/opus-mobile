import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/features/chat/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: message.isMe ? OpusSpacing.xl : OpusSpacing.sm,
          right: message.isMe ? OpusSpacing.sm : OpusSpacing.xl,
          top: OpusSpacing.xs,
          bottom: OpusSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: OpusSpacing.md,
                vertical: OpusSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? OpusColors.rougeEnseigne
                    : OpusColors.blancChaux,
                borderRadius: _buildBorderRadius(),
                border: message.isMe
                    ? null
                    : Border.all(
                        color: OpusColors.grisPoussiere.withValues(alpha: 0.4),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: message.isMe
                      ? Colors.white
                      : OpusColors.noirGoudron,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.sentAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: OpusColors.grisPoussiere,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _buildBorderRadius() {
    const double large = 16;
    const double small = 4;

    if (message.isMe) {
      // Sent: sharp top-right corner (toward same-sender side)
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(small),
        bottomLeft: Radius.circular(large),
        bottomRight: Radius.circular(large),
      );
    } else {
      // Received: sharp top-left corner (toward same-sender side)
      return const BorderRadius.only(
        topLeft: Radius.circular(small),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(large),
        bottomRight: Radius.circular(large),
      );
    }
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: OpusColors.grisPoussiere,
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check_rounded,
          size: 13,
          color: OpusColors.grisPoussiere,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all_rounded,
          size: 13,
          color: OpusColors.grisPoussiere,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all_rounded,
          size: 13,
          color: Colors.blue,
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

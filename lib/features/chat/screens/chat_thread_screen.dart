import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opus_mobile/core/theme/opus_colors.dart';
import 'package:opus_mobile/core/theme/opus_spacing.dart';
import 'package:opus_mobile/features/chat/models/message_model.dart';
import 'package:opus_mobile/features/chat/services/chat_service.dart';
import 'package:opus_mobile/features/chat/widgets/message_bubble.dart';

// Hardcoded until real auth is wired in.
const String _kCurrentUserId = 'me';

class ChatThreadScreen extends StatefulWidget {
  final String id;
  final String? recipientName;

  const ChatThreadScreen({
    super.key,
    required this.id,
    this.recipientName,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  List<MessageModel> _messages = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  int _currentPage = 1;

  bool _showTypingIndicator = false;
  Timer? _typingTimer;

  String _inputText = '';
  bool _isSending = false;

  static const int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onInputChanged);
    _scrollController.addListener(_onScroll);
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _textController.text;
    if (text != _inputText) {
      setState(() => _inputText = text);
    }
  }

  void _onScroll() {
    // ListView is reversed, so "top of screen" = end of scroll range
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadInitialMessages() async {
    setState(() {
      _isLoadingInitial = true;
      _currentPage = 1;
      _hasMorePages = true;
    });

    try {
      final messages = await _chatService.getMessages(
        widget.id,
        page: 1,
        limit: _pageSize,
        currentUserId: _kCurrentUserId,
      );

      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoadingInitial = false;
        _hasMorePages = messages.length >= _pageSize;
        _currentPage = 1;
      });

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingInitial = false);
      _showError('Impossible de charger les messages.');
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMorePages || _isLoadingInitial) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    try {
      final more = await _chatService.getMessages(
        widget.id,
        page: nextPage,
        limit: _pageSize,
        currentUserId: _kCurrentUserId,
      );

      if (!mounted) return;
      setState(() {
        // Messages are displayed in reverse, so older ones go at the end
        _messages = [..._messages, ...more];
        _currentPage = nextPage;
        _hasMorePages = more.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _isSending) return;

    // Optimistic message
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      conversationId: widget.id,
      senderId: _kCurrentUserId,
      content: content,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
      isMe: true,
    );

    setState(() {
      _messages = [optimistic, ..._messages];
      _isSending = true;
    });

    _textController.clear();
    _scrollToBottom();
    _startTypingIndicator();

    try {
      final sent = await _chatService.sendMessage(
        widget.id,
        content,
        currentUserId: _kCurrentUserId,
      );

      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          _messages[idx] = sent.copyWith(status: MessageStatus.sent);
        }
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          // Keep message visible but mark as failed via sending status
          _messages[idx] = optimistic.copyWith(status: MessageStatus.sending);
        }
        _isSending = false;
      });
      _showError('Impossible d\'envoyer le message. Réessayez.');
    }
  }

  void _startTypingIndicator() {
    _typingTimer?.cancel();
    setState(() => _showTypingIndicator = true);
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showTypingIndicator = false);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpusColors.rougeEnseigne,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(OpusSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpusSpacing.sm),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_showTypingIndicator) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: OpusColors.indigoBache,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white70, size: 22),
          ),
          const SizedBox(width: OpusSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.recipientName ?? 'Conversation',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'En ligne',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () {},
          tooltip: 'Options',
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(color: OpusColors.rougeEnseigne),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: OpusColors.grisPoussiere.withValues(alpha: 0.6),
            ),
            const SizedBox(height: OpusSpacing.md),
            const Text(
              'Aucun message pour l\'instant.\nDites bonjour !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: OpusColors.grisPoussiere,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Build a list of items: messages interspersed with date separators.
    final items = _buildListItems();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        vertical: OpusSpacing.sm,
        horizontal: OpusSpacing.xs,
      ),
      itemCount: items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the "top" (end of reversed list)
        if (_isLoadingMore && index == items.length) {
          return const Padding(
            padding: EdgeInsets.all(OpusSpacing.md),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: OpusColors.rougeEnseigne,
                ),
              ),
            ),
          );
        }

        return items[index];
      },
    );
  }

  /// Groups messages by date and inserts date separator widgets.
  /// The list is reversed (newest first for reverse ListView),
  /// so separators appear after the group they label.
  List<Widget> _buildListItems() {
    final items = <Widget>[];
    String? lastDateLabel;

    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      final dateLabel = _dateLabel(message.sentAt);

      items.add(MessageBubble(message: message));

      // Insert separator after the last message of each date group
      // (since list is reversed, the "last" message is the oldest in the group)
      final isLastInGroup = i == _messages.length - 1 ||
          _dateLabel(_messages[i + 1].sentAt) != dateLabel;

      if (isLastInGroup && dateLabel != lastDateLabel) {
        items.add(_DateSeparator(label: dateLabel));
        lastDateLabel = dateLabel;
      }
    }

    return items;
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: OpusSpacing.md,
          bottom: OpusSpacing.xs,
          top: OpusSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: OpusSpacing.md,
          vertical: OpusSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: OpusColors.blancChaux,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: OpusColors.grisPoussiere.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const _TypingDots(),
      ),
    );
  }

  Widget _buildInputArea() {
    final canSend = _inputText.trim().isNotEmpty && !_isSending;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OpusSpacing.sm,
          vertical: OpusSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _inputFocusNode,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    fontSize: 15,
                    color: OpusColors.noirGoudron,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(
                      color: OpusColors.grisPoussiere,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: OpusSpacing.md,
                      vertical: OpusSpacing.sm + 2,
                    ),
                  ),
                  onSubmitted: canSend ? (_) => _sendMessage() : null,
                ),
              ),
            ),
            const SizedBox(width: OpusSpacing.xs),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: canSend
                    ? OpusColors.rougeEnseigne
                    : OpusColors.grisPoussiere.withValues(alpha: 0.4),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: canSend ? _sendMessage : null,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(OpusSpacing.sm + 2),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) return 'Aujourd\'hui';
    if (messageDay == yesterday) return 'Hier';

    // "14 janv.", "3 mars", etc.
    return DateFormat('d MMM', 'fr_FR').format(date);
  }
}

// ─── Date Separator ──────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String label;

  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OpusSpacing.sm),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: OpusColors.grisPoussiere,
              thickness: 0.5,
              endIndent: OpusSpacing.sm,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OpusSpacing.sm,
              vertical: OpusSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: OpusColors.grisPoussiere.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(OpusSpacing.md),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: OpusColors.grisPoussiere,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: OpusColors.grisPoussiere,
              thickness: 0.5,
              indent: OpusSpacing.sm,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing Dots Animation ────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context2, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot peaks at a different phase
            final phase = (i / 3);
            final progress = (_controller.value + phase) % 1.0;
            final bounceVal = _bounce(progress);
            final scale = 0.6 + 0.4 * bounceVal;
            final opacity = 0.5 + 0.5 * bounceVal;
            final translateY = -4.0 * bounceVal;
            return Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: OpusColors.grisPoussiere
                        .withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _bounce(double t) {
    // Sine wave mapped to [0..1]: 0 at rest, 1 at peak
    return (math.sin(t * 2 * math.pi) + 1) / 2;
  }
}

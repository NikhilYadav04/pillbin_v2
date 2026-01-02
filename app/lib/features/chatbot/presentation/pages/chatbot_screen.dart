import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/chatbot/data/model/chatBotModel.dart';
import 'package:pillbin/features/chatbot/data/repository/chatbot_provider.dart';
import 'package:pillbin/network/utils/http_client.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _typingAnimation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? name = "X";

  @override
  void initState() {
    super.initState();
    // Animation setup
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _typingController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _typingController, curve: Curves.easeInOut));

    _animationController.forward();
    _getName();

    // Scroll listener for pagination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatbotProvider>();
      if (provider.messages.isEmpty) provider.fetchMessages(refresh: true);
      _scrollController.addListener(_onScroll);
    });
  }

  void _getName() async {
    final HttpClient _httpClient = HttpClient();
    Map<String, String> map = await _httpClient.getUserData();
    setState(() => name = map["name"]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if (!_scrollController.hasClients) return;

    final provider = context.read<ChatbotProvider>();
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    //* Check if near top (maxScrollExtent in reverse list) to load older messages
    if (currentScroll >= (maxScroll - 100) &&
        !provider.isFetching &&
        provider.hasMore) {
      await provider.fetchMessages();
    }
  }

  void _sendMessage(ChatbotProvider provider) async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    //* Scroll to bottom (0.0) immediately
    _scrollToBottom();

    await provider.sendQuery(context: context, prompt: message);

    //* Ensure we stay at bottom after response
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<ChatbotProvider>(builder: (context, provider, _) {
            return Column(
              children: [
                _buildHeader(sw, sh, isTablet, provider),
                Expanded(child: _buildChatArea(sw, sh, isTablet, provider)),
                _buildMessageInput(sw, sh, isTablet, provider),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChatArea(
      double sw, double sh, bool isTablet, ChatbotProvider provider) {
    //* Initial loading state
    if (provider.isFetching && provider.messages.isEmpty) {
      return Center(
          child: CircularProgressIndicator(color: PillBinColors.primary));
    }

    //* Empty state
    if (provider.messages.isEmpty && !provider.isTyping) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.06),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_outlined, // Pill icon
                  size: isTablet ? sw * 0.12 : sw * 0.15,
                  color: PillBinColors.primary,
                ),
              ),
              SizedBox(height: sh * 0.03),
              Text(
                'PillBin Assistant',
                textAlign: TextAlign.center,
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.035 : sw * 0.055,
                  color: PillBinColors.textDark,
                ),
              ),
              SizedBox(height: sh * 0.015),
              Text(
                'Chat with PillBin Assistant to ask your\nhealth and general doubts.',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('ChatList'),
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.05 : sw * 0.04, vertical: sh * 0.02),
      itemCount: provider.messages.length +
          (provider.isTyping ? 1 : 0) +
          (provider.isFetching ? 1 : 0),
      itemBuilder: (context, index) {
        //* Typing Indicator (Visual Bottom / Index 0)
        if (provider.isTyping) {
          if (index == 0) return _buildTypingIndicator(sw, sh, isTablet);
          index--;
        }

        //* Loading Older Messages (Visual Top / Last Index)
        if (provider.isFetching && index == provider.messages.length) {
          return Padding(
            padding: EdgeInsets.only(bottom: sh * 0.02),
            child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: PillBinColors.primary))),
          );
        }

        //* Message Bubbles
        if (index >= provider.messages.length) return const SizedBox.shrink();

        final reversedIndex = provider.messages.length - 1 - index;
        return _buildMessageBubble(
            provider.messages[reversedIndex], sw, sh, isTablet);
      },
    );
  }

  Widget _buildHeader(
      double sw, double sh, bool isTablet, ChatbotProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PillBinColors.primary,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isTablet ? 32 : 24),
            bottomRight: Radius.circular(isTablet ? 32 : 24)),
      ),
      padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: PillBinColors.textWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Icon(Icons.arrow_back_ios,
                      color: PillBinColors.textWhite,
                      size: isTablet ? sw * 0.025 : sw * 0.05)),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PillBin Assistant',
                    style: PillBinBold.style(
                        fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                        color: PillBinColors.textWhite)),
                SizedBox(height: sh * 0.002),
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: PillBinColors.success,
                            borderRadius: BorderRadius.circular(4))),
                    SizedBox(width: sw * 0.02),
                    Text(provider.isTyping ? 'Typing...' : 'Online',
                        style: PillBinRegular.style(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                            color: PillBinColors.textWhite.withOpacity(0.9))),
                  ],
                ),
              ],
            ),
          ),
          if (provider.messages.length > 1)
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear Chat History',
                        style: PillBinBold.style(
                            fontSize: isTablet ? sw * 0.025 : sw * 0.06,
                            color: PillBinColors.primary)),
                    content: Text(
                        'Are you sure you want to clear all messages?',
                        style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.025 : sw * 0.035,
                            color: PillBinColors.textSecondary)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel',
                              style: PillBinMedium.style(
                                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                                  color: Colors.black))),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Clear',
                              style: PillBinMedium.style(
                                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                                  color: Colors.black))),
                    ],
                  ),
                );
                if (confirm == true) await provider.clearChatHistory();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: PillBinColors.textWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete_outline,
                    color: PillBinColors.textWhite,
                    size: isTablet ? sw * 0.025 : sw * 0.05),
              ),
            ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => provider.fetchMessages(refresh: true,forceRefresh: true),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: PillBinColors.textWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Icon(Icons.refresh,
                      color: PillBinColors.textWhite,
                      size: isTablet ? sw * 0.025 : sw * 0.05)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(double sw, double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? sw * 0.06 : sw * 0.08,
            height: isTablet ? sw * 0.06 : sw * 0.08,
            decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8)),
            child: Icon(Icons.smart_toy,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.04),
          ),
          SizedBox(width: sw * 0.02),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                vertical: isTablet ? sh * 0.015 : sh * 0.012),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTablet ? 16 : 12),
                  topRight: Radius.circular(isTablet ? 16 : 12),
                  bottomLeft: const Radius.circular(4),
                  bottomRight: Radius.circular(isTablet ? 16 : 12)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final value =
                      (_typingAnimation.value - (index * 0.3)).clamp(0.0, 1.0);
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Transform.translate(
                        offset: Offset(0, -4 * value),
                        child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: PillBinColors.primary,
                                borderRadius: BorderRadius.circular(3)))),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, double sw, double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: isTablet ? sw * 0.06 : sw * 0.08,
              height: isTablet ? sw * 0.06 : sw * 0.08,
              decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8)),
              child: Icon(Icons.smart_toy,
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.025 : sw * 0.04),
            ),
            SizedBox(width: sw * 0.02),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: sw * 0.75),
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                  vertical: isTablet ? sh * 0.015 : sh * 0.012),
              decoration: BoxDecoration(
                color: message.isUser
                    ? PillBinColors.primary
                    : PillBinColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTablet ? 16 : 12),
                  topRight: Radius.circular(isTablet ? 16 : 12),
                  bottomLeft: Radius.circular(
                      message.isUser ? (isTablet ? 16 : 12) : 4),
                  bottomRight: Radius.circular(
                      message.isUser ? 4 : (isTablet ? 16 : 12)),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.message,
                      style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: message.isUser
                              ? PillBinColors.textWhite
                              : PillBinColors.textDark)),
                  SizedBox(height: sh * 0.005),
                  Text(_formatTime(message.timestamp),
                      style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                          color: message.isUser
                              ? PillBinColors.textWhite.withOpacity(0.7)
                              : PillBinColors.textSecondary)),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: sw * 0.02),
            Container(
              width: isTablet ? sw * 0.06 : sw * 0.08,
              height: isTablet ? sw * 0.06 : sw * 0.08,
              decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8)),
              child: Center(
                  child: Text(name?.toUpperCase().split("")[0] ?? "U",
                      style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                          color: PillBinColors.primary))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(
      double sw, double sh, bool isTablet, ChatbotProvider provider) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(color: PillBinColors.surface, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2))
      ]),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: PillBinColors.background,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  border: Border.all(color: PillBinColors.greyLight)),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                enabled: !provider.isTyping,
                decoration: InputDecoration(
                  hintText: provider.isTyping
                      ? 'AI is typing...'
                      : 'Type your message...',
                  hintStyle: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                      color: PillBinColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                      vertical: isTablet ? sh * 0.015 : sh * 0.012),
                ),
                style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                    color: PillBinColors.textDark),
                onSubmitted: (_) => _sendMessage(provider),
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),
          GestureDetector(
            onTap: provider.isTyping ? null : () => _sendMessage(provider),
            child: Container(
              width: isTablet ? sw * 0.08 : sw * 0.12,
              height: isTablet ? sw * 0.08 : sw * 0.12,
              decoration: BoxDecoration(
                color: provider.isTyping
                    ? PillBinColors.primary.withOpacity(0.5)
                    : PillBinColors.primary,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                      color: PillBinColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Icon(Icons.send,
                  color: PillBinColors.textWhite,
                  size: isTablet ? sw * 0.035 : sw * 0.05),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

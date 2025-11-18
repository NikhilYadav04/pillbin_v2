import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _getName();
  }

  //* get name from local storage
  void _getName() async {
    final HttpClient _httpClient = HttpClient();

    Map<String, String> map = await _httpClient.getUserData();
    setState(() {
      name = map["name"];
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatbotProvider provider) async {
    if (_messageController.text.trim().isEmpty) return;

    provider.sendQueryToChatbot(
        context: context, prompt: _messageController.text.trim());

    _messageController.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                Expanded(
                  child: _buildChatArea(sw, sh, isTablet, provider),
                ),
                _buildMessageInput(sw, sh, isTablet, provider),
              ],
            );
          }),
        ),
      ),
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
          bottomRight: Radius.circular(isTablet ? 32 : 24),
        ),
      ),
      padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PillBinColors.textWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: PillBinColors.textWhite,
                  size: isTablet ? sw * 0.025 : sw * 0.05,
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PillBin Assistant',
                  style: PillBinBold.style(
                    fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                    color: PillBinColors.textWhite,
                  ),
                ),
                SizedBox(height: sh * 0.002),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: PillBinColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    Text(
                      provider.isTyping ? 'Typing...' : 'Online',
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                        color: PillBinColors.textWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(
      double sw, double sh, bool isTablet, ChatbotProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.02,
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.messages.length && provider.isTyping) {
            return _buildTypingIndicator(sw, sh, isTablet);
          }
          return _buildMessageBubble(
              provider.messages[index], sw, sh, isTablet);
        },
      ),
    );
  }

  Widget _buildTypingIndicator(double sw, double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? sw * 0.06 : sw * 0.08,
            height: isTablet ? sw * 0.06 : sw * 0.08,
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            ),
            child: Icon(
              Icons.smart_toy,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.025 : sw * 0.04,
            ),
          ),
          SizedBox(width: sw * 0.02),
          Container(
            constraints: BoxConstraints(maxWidth: sw * 0.75),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? sw * 0.025 : sw * 0.04,
              vertical: isTablet ? sh * 0.015 : sh * 0.012,
            ),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTablet ? 16 : 12),
                topRight: Radius.circular(isTablet ? 16 : 12),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(isTablet ? 16 : 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.only(right: 4),
                          child: Transform.translate(
                            offset: Offset(
                                0,
                                4 *
                                    (index == 0
                                        ? _typingAnimation.value
                                        : index == 1
                                            ? (_typingAnimation.value - 0.3)
                                                .clamp(0.0, 1.0)
                                            : (_typingAnimation.value - 0.6)
                                                .clamp(0.0, 1.0)) *
                                    (index % 2 == 0 ? -1 : 1)),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: PillBinColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
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
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Icon(
                Icons.smart_toy,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.04,
              ),
            ),
            SizedBox(width: sw * 0.02),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: sw * 0.75),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                vertical: isTablet ? sh * 0.015 : sh * 0.012,
              ),
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                      color: message.isUser
                          ? PillBinColors.textWhite
                          : PillBinColors.textDark,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    _formatTime(message.timestamp),
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                      color: message.isUser
                          ? PillBinColors.textWhite.withOpacity(0.7)
                          : PillBinColors.textSecondary,
                    ),
                  ),
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
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Center(
                child: Text(
                  name?.toUpperCase().split("")[0] ?? "U",
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                    color: PillBinColors.primary,
                  ),
                ),
              ),
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
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PillBinColors.background,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(color: PillBinColors.greyLight),
              ),
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
                    color: PillBinColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                    vertical: isTablet ? sh * 0.015 : sh * 0.012,
                  ),
                ),
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                  color: PillBinColors.textDark,
                ),
                onSubmitted: (_) => _sendMessage(provider),
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),
          GestureDetector(
            onTap: provider.isTyping
                ? null
                : () {
                    _sendMessage(provider);
                  },
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.send,
                color: PillBinColors.textWhite,
                size: isTablet ? sw * 0.035 : sw * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [
    ChatMessage(
      message: "Hello! I'm your PillBin assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    ChatMessage(
      message: "Hi! I have some questions about my expired medicines",
      isUser: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
    ),
    ChatMessage(
      message:
          "I'd be happy to help you with expired medicines! What would you like to know?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
    ),
    ChatMessage(
      message: "How should I dispose of expired Ibuprofen tablets?",
      isUser: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    ChatMessage(
      message:
          "Great question! For expired Ibuprofen tablets:\n\n• Remove them from original container\n• Mix with unappetizing substance (coffee grounds, cat litter)\n• Place in sealed bag\n• Throw in household trash\n\nAlternatively, you can take them to a pharmacy take-back program. Would you like me to help you find nearby disposal locations?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    ChatMessage(
      message: "Yes, please find locations near Mumbai",
      isUser: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 2)),
    ),
    ChatMessage(
      message:
          "I found several medicine disposal locations near Mumbai:\n\n🏥 Apollo Pharmacy - Bandra\n📍 2.3 km away\n\n🏥 MedPlus - Andheri\n📍 4.1 km away\n\n🏥 Fortis Hospital - Mulund\n📍 6.8 km away\n\nWould you like directions to any of these locations?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        message: _messageController.text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    String userMessage = _messageController.text.trim().toLowerCase();
    _messageController.clear();

    // Simulate bot response after a delay
    Future.delayed(Duration(seconds: 1), () {
      String botResponse = _getBotResponse(userMessage);
      setState(() {
        messages.add(ChatMessage(
          message: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  String _getBotResponse(String userMessage) {
    if (userMessage.contains('expire') || userMessage.contains('expiry')) {
      return "Based on your inventory, you have 2 expired medicines and 1 expiring soon. I recommend disposing of the expired ones safely. Would you like specific disposal instructions?";
    } else if (userMessage.contains('dispose') ||
        userMessage.contains('disposal')) {
      return "For safe medicine disposal:\n\n1. Never flush medicines down the toilet\n2. Use pharmacy take-back programs\n3. Mix with unappetizing substances before trash disposal\n4. Remove personal information from labels\n\nWould you like me to find disposal locations near you?";
    } else if (userMessage.contains('reminder') ||
        userMessage.contains('alert')) {
      return "I can help set up medicine expiry reminders! Currently, your Crocin expires in 38 days. Would you like me to set up alerts for:\n\n• 30 days before expiry\n• 7 days before expiry\n• On expiry date";
    } else if (userMessage.contains('inventory') ||
        userMessage.contains('medicines')) {
      return "Your current inventory shows:\n\n✅ 1 Active medicine\n⚠️ 1 Expiring soon (38 days)\n❌ 2 Expired medicines\n\nWould you like me to help you manage any specific category?";
    } else if (userMessage.contains('location') ||
        userMessage.contains('find') ||
        userMessage.contains('near')) {
      return "I can help you find medicine disposal locations, pharmacies, or hospitals near your location in Mumbai. What type of location are you looking for?";
    } else if (userMessage.contains('thanks') ||
        userMessage.contains('thank you')) {
      return "You're welcome! I'm here to help you manage your medicines safely. Is there anything else you'd like to know about medicine storage, disposal, or inventory management?";
    } else if (userMessage.contains('hello') || userMessage.contains('hi')) {
      return "Hello! I'm here to help you with all your medicine-related questions. You can ask me about:\n\n• Medicine disposal\n• Expiry alerts\n• Storage guidelines\n• Finding nearby pharmacies\n\nWhat would you like to know?";
    } else {
      return "I'm here to help with medicine-related questions! You can ask me about disposal methods, expiry reminders, storage tips, or finding nearby pharmacies. What would you like to know?";
    }
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
          child: Column(
            children: [
              _buildHeader(sw, sh, isTablet),
              Expanded(
                child: _buildChatArea(sw, sh, isTablet),
              ),
              _buildMessageInput(sw, sh, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double sw, double sh, bool isTablet) {
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
                      'Online',
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

  Widget _buildChatArea(double sw, double sh, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.02,
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(messages[index], sw, sh, isTablet);
        },
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
                  'RK',
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

  Widget _buildMessageInput(double sw, double sh, bool isTablet) {
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
                decoration: InputDecoration(
                  hintText: 'Type your message...',
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
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: isTablet ? sw * 0.08 : sw * 0.12,
              height: isTablet ? sw * 0.08 : sw * 0.12,
              decoration: BoxDecoration(
                color: PillBinColors.primary,
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

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/health_ai/presentation/widgets/health_ai_widgets.dart';

class HealthReportChatScreen extends StatefulWidget {
  const HealthReportChatScreen({Key? key}) : super(key: key);

  @override
  State<HealthReportChatScreen> createState() => _HealthReportChatScreenState();
}

class _HealthReportChatScreenState extends State<HealthReportChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _hasUploadedReport = false;
  String? _uploadedFileName;
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    // Welcome message
    _messages.add(ChatMessage(
      text:
          "Hi! I'm your health report assistant. Upload your medical reports and ask me any questions about them.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleUploadReport() {
    // Simulate file picker
    setState(() {
      _hasUploadedReport = true;
      _uploadedFileName = "blood_test_report.pdf";
      _messages.add(ChatMessage(
        text:
            "Report uploaded successfully! I've analyzed your blood test report. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _generateResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateResponse(String question) {
    // Simulate responses based on question
    if (question.toLowerCase().contains('cholesterol')) {
      return "Based on your report, your total cholesterol is 195 mg/dL, which is within the normal range (less than 200 mg/dL). Your HDL (good cholesterol) is 52 mg/dL and LDL is 120 mg/dL, both acceptable levels.";
    } else if (question.toLowerCase().contains('sugar') ||
        question.toLowerCase().contains('glucose')) {
      return "Your fasting blood sugar level is 92 mg/dL, which is normal (70-100 mg/dL). This indicates good glucose control.";
    }
    return "I can help you understand your report better. Try asking about specific values like cholesterol, blood sugar, hemoglobin, or any other parameters in your report.";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showUploadDialog(double sw, double sh, bool isTablet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: PillBinColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: isTablet ? sw * 0.08 : sw * 0.15,
                color: PillBinColors.primary,
              ),
              SizedBox(height: sh * 0.02),
              Text(
                'Upload Health Report',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.028 : sw * 0.045,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.01),
              Text(
                'Select a file format to upload',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
              SizedBox(height: sh * 0.03),
              _buildUploadOption(
                sw,
                sh,
                isTablet,
                Icons.picture_as_pdf,
                'PDF Document',
                'Upload PDF reports',
              ),
              SizedBox(height: sh * 0.015),
              _buildUploadOption(
                sw,
                sh,
                isTablet,
                Icons.image,
                'Image',
                'Upload JPG, PNG images',
              ),
              SizedBox(height: sh * 0.015),
              _buildUploadOption(
                sw,
                sh,
                isTablet,
                Icons.insert_drive_file,
                'Document',
                'Upload DOC, DOCX files',
              ),
              SizedBox(height: sh * 0.02),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption(
    double sw,
    double sh,
    bool isTablet,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _handleUploadReport();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(sw * 0.035),
        decoration: BoxDecoration(
          color: PillBinColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PillBinColors.greyLight.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.025),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.05,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                      color: PillBinColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? sw * 0.018 : sw * 0.03,
              color: PillBinColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              buildHealthAIHeader(context, sw, sh),
              // Upload section
              if (!_hasUploadedReport) _buildUploadSection(sw, sh, isTablet),

              // Uploaded file indicator
              if (_hasUploadedReport) _buildUploadedFileBar(sw, sh, isTablet),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                    vertical: sh * 0.02,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator(sw, sh, isTablet);
                    }
                    return _buildMessageBubble(
                      sw,
                      sh,
                      isTablet,
                      _messages[index],
                    );
                  },
                ),
              ),

              // Message input
              _buildMessageInput(sw, sh, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(double sw, double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PillBinColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file,
            size: isTablet ? sw * 0.08 : sw * 0.15,
            color: PillBinColors.primary.withOpacity(0.7),
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'Upload Your Health Report',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
              color: PillBinColors.textPrimary,
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            'Get instant AI-powered analysis and insights',
            textAlign: TextAlign.center,
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.02),
          ElevatedButton.icon(
            onPressed: () => _showUploadDialog(sw, sh, isTablet),
            icon: Icon(Icons.add, size: isTablet ? sw * 0.022 : sw * 0.04),
            label: Text(
              'Upload Report',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PillBinColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.06,
                vertical: sh * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFileBar(double sw, double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.025 : sw * 0.04,
        vertical: sh * 0.01,
      ),
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: PillBinColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PillBinColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.022 : sw * 0.04,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _uploadedFileName ?? 'Report uploaded',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                    color: PillBinColors.textPrimary,
                  ),
                ),
                Text(
                  'Analyzed successfully',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.016 : sw * 0.026,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: PillBinColors.textSecondary,
              size: isTablet ? sw * 0.02 : sw * 0.035,
            ),
            onPressed: () {
              setState(() {
                _hasUploadedReport = false;
                _uploadedFileName = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    double sw,
    double sh,
    bool isTablet,
    ChatMessage message,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.015),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.022 : sw * 0.04,
              ),
            ),
            SizedBox(width: sw * 0.02),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.015,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? PillBinColors.primary
                    : PillBinColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.034,
                      color: message.isUser
                          ? Colors.white
                          : PillBinColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    _formatTime(message.timestamp),
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.014 : sw * 0.024,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
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
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.022 : sw * 0.04,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.015),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.022 : sw * 0.04,
            ),
          ),
          SizedBox(width: sw * 0.02),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.015,
            ),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildDot(sw),
                SizedBox(width: sw * 0.01),
                _buildDot(sw),
                SizedBox(width: sw * 0.01),
                _buildDot(sw),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double sw) {
    return Container(
      width: sw * 0.015,
      height: sw * 0.015,
      decoration: BoxDecoration(
        color: PillBinColors.textSecondary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageInput(double sw, double sh, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: PillBinColors.background,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: PillBinColors.greyLight.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.034,
                    color: PillBinColors.textPrimary,
                  ),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Ask about your report...',
                    hintStyle: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.034,
                      color: PillBinColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                      vertical: sh * 0.015,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: sw * 0.02),
            GestureDetector(
              onTap: _handleSendMessage,
              child: Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                decoration: BoxDecoration(
                  color: PillBinColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: isTablet ? sw * 0.022 : sw * 0.045,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

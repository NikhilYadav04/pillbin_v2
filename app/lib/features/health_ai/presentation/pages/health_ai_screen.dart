import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/health_ai/data/repository/health_ai_provider.dart';
import 'package:pillbin/features/health_ai/presentation/widgets/health_ai_widgets.dart';
import 'package:pillbin/network/utils/http_client.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class HealthReportChatScreen extends StatefulWidget {
  const HealthReportChatScreen({Key? key}) : super(key: key);

  @override
  State<HealthReportChatScreen> createState() => _HealthReportChatScreenState();
}

class _HealthReportChatScreenState extends State<HealthReportChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? name = "X";
  String? user_id = "X";

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

    _getName();
  }

  //* get name from local storage
  void _getName() async {
    final HttpClient _httpClient = HttpClient();

    Map<String, String> map = await _httpClient.getUserData();
    setState(() {
      name = map["name"];
      user_id = "${map["name"]}_${map["phone"]?.substring(0, 4)}";
    });

    if (user_id == "X") {
      user_id = "XYZ";
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleUploadReport(HealthAiProvider provider) async {
    // var status = await Permission.storage.request();

    // if (status.isDenied) {
    //   CustomSnackBar.show(
    //     context: context,
    //     icon: Icons.warning,
    //     title: "Storage permission denied!",
    //   );
    //   return;
    // } else if (status.isPermanentlyDenied) {
    //   CustomSnackBar.show(
    //     context: context,
    //     icon: Icons.block,
    //     title: "Please enable storage permission in app settings.",
    //   );
    //   await openAppSettings();
    //   return;
    // }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      provider.addFile(file);

      bool response =
          await provider.uploadPDFToRAG(userId: user_id!, file: file);

      if (response) {
        // ✅ Upload successful
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          title: "PDF uploaded successfully!",
        );
      } else {
        // ❌ Upload failed
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Failed to upload PDF. Please try again!",
        );
      }

      return;
    }

    _scrollToBottom();
  }

  void _handleSendMessage(HealthAiProvider provider) {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    if (provider.file == null) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.upload_file,
        title: "Upload a PDF to ask any question !!",
      );
      return;
    }

    provider.askQueryRAG(
        userId: user_id!, query: _messageController.text.trim());

    _messageController.clear();

    _scrollToBottom();
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

  void _showUploadDialog(
      double sw, double sh, bool isTablet, HealthAiProvider provider) {
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
              SizedBox(height: sh * 0.03),
              _buildUploadOption(
                  sw,
                  sh,
                  isTablet,
                  Icons.picture_as_pdf,
                  'PDF Document',
                  'Upload your health report in PDF format',
                  provider),
              SizedBox(height: sh * 0.015),
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

  Widget _buildUploadOption(double sw, double sh, bool isTablet, IconData icon,
      String title, String subtitle, HealthAiProvider provider) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _handleUploadReport(provider);
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
          child: Consumer<HealthAiProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  buildHealthAIHeader(context, sw, sh, user_id!, provider),
                  //* Upload section
                  provider.file == null && !provider.isUploading
                      ? _buildUploadSection(sw, sh, isTablet, provider)
                      : SizedBox.shrink(),

                  //* Uploaded file indicator
                  provider.file != null && !provider.isUploading
                      ? buildUploadedFileBar(
                          sw, sh, isTablet, provider, context, user_id!)
                      : SizedBox.shrink(),

                  //* Uploading file indicator
                  provider.isUploading
                      ? _buildUploadingSection(
                          sw, sh, isTablet, path.basename(provider.file!.path))
                      : SizedBox.shrink(),

                  //* Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                        vertical: sh * 0.02,
                      ),
                      itemCount: provider.messages.length +
                          (provider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.messages.length &&
                            provider.isTyping) {
                          return _buildTypingIndicator(sw, sh, isTablet);
                        }
                        return _buildMessageBubble(
                          sw,
                          sh,
                          isTablet,
                          provider.messages[index],
                        );
                      },
                    ),
                  ),

                  // Message input
                  _buildMessageInput(sw, sh, isTablet, provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(
      double sw, double sh, bool isTablet, HealthAiProvider provider) {
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
            onPressed: () => _showUploadDialog(sw, sh, isTablet, provider),
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

  Widget _buildMessageBubble(
    double sw,
    double sh,
    bool isTablet,
    MessageAIModel message,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.015),
      child: Row(
        mainAxisAlignment: message.role == "user"
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!(message.role == "user")) ...[
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
                color: message.role == "user"
                    ? PillBinColors.primary
                    : PillBinColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.034,
                      color: message.role == "user"
                          ? Colors.white
                          : PillBinColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    _formatTime(message.sendTime),
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.014 : sw * 0.024,
                      color: message.role == "user"
                          ? Colors.white.withOpacity(0.7)
                          : PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.role == "user") ...[
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

  Widget _buildMessageInput(
      double sw, double sh, bool isTablet, HealthAiProvider provider) {
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
              onTap: () {
                _handleSendMessage(provider);
              },
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

  Widget _buildUploadingSection(
      double sw, double sh, bool isTablet, String fileName) {
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
          // Animated upload icon
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: 2),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, -10 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Icon(
                    Icons.cloud_upload,
                    size: isTablet ? sw * 0.08 : sw * 0.15,
                    color: PillBinColors.primary.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'Analyzing Report',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
              color: PillBinColors.textPrimary,
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            fileName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.02),
          // Animated dots - continuously repeating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 1500),
                builder: (context, double value, child) {
                  final delay = index * 0.2;
                  final animValue = (value - delay).clamp(0.0, 1.0);
                  final scale = 0.5 + (0.5 * sin(animValue * pi * 2));
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: isTablet ? sw * 0.012 : sw * 0.02,
                        height: isTablet ? sw * 0.012 : sw * 0.02,
                        decoration: BoxDecoration(
                          color: PillBinColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation continuously
                  if (mounted) setState(() {});
                },
              );
            }),
          ),
          SizedBox(height: sh * 0.015),
          // Progress bar - slower and repeating
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 8), // Slower progress
              builder: (context, double value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: PillBinColors.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PillBinColors.primary,
                  ),
                  minHeight: sh * 0.006,
                );
              },
              onEnd: () {
                // Restart progress bar continuously
                if (mounted) setState(() {});
              },
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Please wait while we analyze your report...',
            textAlign: TextAlign.center,
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.018 : sw * 0.028,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

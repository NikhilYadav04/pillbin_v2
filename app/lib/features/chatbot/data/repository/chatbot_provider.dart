import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/chatbot/data/model/chatBotModel.dart';
import 'package:pillbin/features/chatbot/data/services/chatbot_services.dart';
import 'package:pillbin/network/models/api_response.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatBotServices _chatBotServices = ChatBotServices();
  final Logger _logger = Logger();

  //* <------------ STATE --------------------- >
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  //* <--------- INIT ----------------->
  ChatbotProvider();

  //* < -------------- HELPERS ----------------->
  String cleanGeminiResponse(String input) {
    return input
        .replaceAll(RegExp(r'\*\*.*?\*\*'), '')
        .replaceAll(r'\n', ' ')
        .trim();
  }

  void _setTyping(bool value) {
    _isTyping = value;
    notifyListeners();
  }

  //* fetch
  Future<void> fetchMessages({bool refresh = false}) async {
    if (_isFetching || (!_hasMore && !refresh)) return;

    try {
      _isFetching = true;

      if (refresh) {
        _page = 1;
        _hasMore = true;
        _messages.clear();
        notifyListeners();
      }

      final ApiResponse<Map<String, dynamic>> response =
          await _chatBotServices.fetchChatMessages(
        page: _page,
        limit: _limit,
      );

      _logger.d("Fetch Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List list = response.data!['data'];

        final fetchedMessages =
            list.map((e) => ChatMessage.fromJson(e)).toList().reversed.toList();

        if (refresh || _page == 1) {
          //* First load: just add them
          _messages.addAll(fetchedMessages);
        } else {
          _messages.insertAll(0, fetchedMessages);
        }

        final pagination = response.data!['pagination'];
        _hasMore = pagination['hasMore'] ?? false;

        _page++;
      }
    } catch (e) {
      _logger.e(e);
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  //* send
  Future<void> sendQuery({
    required BuildContext context,
    required String prompt,
  }) async {
    if (prompt.trim().isEmpty) return;

    try {
      _setTyping(true);

      final userMessage = ChatMessage(
        id: "local-${DateTime.now().millisecondsSinceEpoch}",
        userId: "me",
        message: prompt.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      _messages.add(userMessage);
      notifyListeners();

      final response =
          await _chatBotServices.sendQuery(context: context, prompt: prompt);

      if (response.statusCode == 200) {
        final text = response.data!["reply"];

        final botMessage = ChatMessage(
          id: response.data!["_id"] ??
              "bot-${DateTime.now().millisecondsSinceEpoch}",
          userId: response.data!["userId"] ?? "bot",
          message: cleanGeminiResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        );

        _messages.add(botMessage);
      } else if (response.statusCode == 429) {
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.chat,
            title: "You’ve reached the maximum chat limit (100 messages).",
          );
        }
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.chat,
        title: "Something went wrong. Please try again.",
      );
    } finally {
      _setTyping(false);
    }
  }

  //* delete
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatBotServices.deleteChatMessage(messageId: messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      _logger.e(e);
    }
  }

  //* clear
  Future<void> clearChatHistory() async {
    try {
      await _chatBotServices.clearChatHistory();
      _messages.clear();
      _page = 1;
      _hasMore = true;
      notifyListeners();
    } catch (e) {
      _logger.e(e);
    }
  }

  //* reset (Local UI Reset)
  Future<void> reset() async {
    _messages.clear();
    _page = 1;
    _hasMore = true;
    _isTyping = false;
    notifyListeners();
  }
}

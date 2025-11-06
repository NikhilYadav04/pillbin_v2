import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/chatbot/data/services/chatbot_services.dart';
import 'package:pillbin/network/models/api_response.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatBotServices _chatBotServices = ChatBotServices();

  //* getter and setters
  List<ChatMessage> _messages = [
    ChatMessage(
      message: "Hello! I'm your PillBin assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  List<ChatMessage> get messages => _messages;

  void clearList() {
    _messages.clear();
    notifyListeners();
  }

  void addInList(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  //* Functions

  //* clean gemini response
  String cleanGeminiResponse(String input) {
    //* Remove markdown headings like **MEDIUM**, **HIGH**, etc.
    String cleaned = input.replaceAll(RegExp(r'\*\*.*?\*\*'), '');

    //* Replace escaped newlines (\n) with actual space or line breaks
    cleaned = cleaned.replaceAll(r'\n', ' ');

    //* Trim extra spaces
    cleaned = cleaned.trim();

    return cleaned;
  }

  //* Call chatbot to send query
  Future<String> sendQueryToChatbot(
      {required BuildContext context, required String prompt}) async {
    try {
      if (prompt.length == 0) {
        return 'Prompt cannot be empty. Please provide a valid question.';
      }

      _isTyping = true;

      addInList(ChatMessage(
          message: prompt.trim(), isUser: true, timestamp: DateTime.now()));
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _chatBotServices.sendQuery(context: context, prompt: prompt);

      if (response.statusCode == 200) {
        String responseText = response.data!["response"]["candidates"][0]
            ["content"]["parts"][0]["text"];
        Logger().d(responseText);

        String cleanResponse = cleanGeminiResponse(responseText);

        addInList(ChatMessage(
            message: cleanResponse, isUser: false, timestamp: DateTime.now()));
        notifyListeners();

        return cleanResponse;
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.chat,
            title: 'Cannot reach server, please try again');
        addInList(ChatMessage(
            message: 'Cannot reach server, please try again',
            isUser: false,
            timestamp: DateTime.now()));
        notifyListeners();
        return 'Cannot reach server, please try again';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.chat,
          title: 'Cannot reach server, please try again');
      print(e.toString());
      addInList(ChatMessage(
          message: 'Cannot reach server, please try again',
          isUser: false,
          timestamp: DateTime.now()));
      return 'Cannot reach server, please try again';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  //* <------------------------Reset-------------------->
  Future<void> reset() async {
    _messages.clear();

    // Re-add the default greeting message
    _messages.add(ChatMessage(
      message: "Hello! I'm your PillBin assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _isTyping = false;
    notifyListeners();
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

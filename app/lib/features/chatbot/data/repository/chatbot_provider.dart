import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/chatbot/data/services/chatbot_services.dart';
import 'package:pillbin/network/models/api_response.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatBotServices _chatBotServices = ChatBotServices();

  //* getter and setters
  List<String> _messages = [];
  List<String> get messages => _messages;

  void clearList() {
    _messages.clear();
    notifyListeners();
  }

  void addInList(String response) {
    _messages.add(response);
    notifyListeners();
  }

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

      ApiResponse<Map<String, dynamic>> response =
          await _chatBotServices.sendQuery(context: context, prompt: prompt);

      if (response.statusCode == 200) {
        String responseText = response.data!["response"]["candidates"][0]
            ["content"]["parts"][0]["text"];
        Logger().d(responseText);

        addInList(responseText);

        String cleanResponse = cleanGeminiResponse(responseText);

        return cleanResponse;
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.chat,
            title: 'Cannot reach server, please try again');
        return 'Cannot reach server, please try again';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.chat,
          title: 'Cannot reach server, please try again');
      print(e.toString());
      return 'Cannot reach server, please try again';
    }
  }
}

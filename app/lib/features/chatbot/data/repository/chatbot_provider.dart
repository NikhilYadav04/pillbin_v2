import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
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

        return 'success';
      } else {
        return 'Cannot reach server, please try again';
      }
    } catch (e) {
      print(e.toString());
      return 'Cannot reach server, please try again';
    }
  }
}

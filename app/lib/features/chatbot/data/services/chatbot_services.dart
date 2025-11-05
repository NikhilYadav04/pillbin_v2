
import 'package:flutter/material.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

String promptTemplate(String text) {
  return "You are an health assistant. Read the user’s question carefully and decide how much detail is required. Guidelines: - If the question is very simple (e.g., factual, yes/no, small definition), give a **SMALL** answer (1–2 sentences). - If the question needs some explanation but not deep detail, give a **MEDIUM** answer (one short paragraph). - If the question is broad or complex, give a **LARGE** answer (multiple paragraphs with details and examples). Now provide your response using the length you judge appropriate. Question: ${text} Answer:";
}

class ChatBotServices extends ApiService {
  //* send query to chatbot
  Future<ApiResponse<Map<String, dynamic>>> sendQuery(
      {required BuildContext context, required String prompt}) async {
    String promptFinal = promptTemplate(prompt);

    return post(ApiEndpoints.sendQueryToChatbot,
        data: {"prompt": promptFinal},
        fromJson: (data) => data as Map<String, dynamic>);
  }
  
}

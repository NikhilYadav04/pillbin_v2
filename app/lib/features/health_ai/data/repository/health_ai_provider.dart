import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pillbin/features/health_ai/data/service/health_ai_services.dart';
import 'package:pillbin/network/models/api_response.dart';

class HealthAiProvider extends ChangeNotifier {
  //* getters and setters

  File? _file;
  File? get file => _file;

  List<MessageAIModel> _messages = [
    MessageAIModel("agent",
        message:
            "Hi! I'm your health report assistant. Upload your medical reports and ask me any questions about them.",
        sendTime: DateTime.now())
  ];

  List<MessageAIModel> get messages => _messages;

  bool _isUploading = false;
  bool _isQuerying = false;

  bool _isTyping = false;

  bool get isUploading => _isUploading;
  bool get isQuerying => _isQuerying;
  bool get isTyping => _isTyping;

  final HealthAiServices _healthAiServices = HealthAiServices();

  //* utils
  void addMessage(MessageAIModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void deleteFile() {
    _file = null;
    _isUploading = false;
    _messages = [
      MessageAIModel("agent",
          message:
              "Hi! I'm your health report assistant. Upload your medical reports and ask me any questions about them.",
          sendTime: DateTime.now())
    ];
    notifyListeners();
  }

  void clear() {
    _file = null;
    _messages = [
      MessageAIModel("agent",
          message:
              "Hi! I'm your health report assistant. Upload your medical reports and ask me any questions about them.",
          sendTime: DateTime.now())
    ];
    _isQuerying = false;
    _isUploading = false;
    notifyListeners();
  }

  void addFile(File file) {
    _file = file;
    notifyListeners();
  }

  String cleanMessage(String message) {
    return message.replaceAll(RegExp(r'[*_/`#>-]'), '').trim();
  }

  //* functions

  //* upload user pdf to FAISS
  Future<bool> uploadPDFToRAG(
      {required String userId, required File file}) async {
    try {
      _isUploading = true;
      _file = file;
      notifyListeners();

      print(userId);

      ApiResponse<Map<String, dynamic>> response =
          await _healthAiServices.uploadPDF(userId: userId, file: file);

      if (response.statusCode == 200) {
        return true;
      } else {
        deleteFile();
        return false;
      }
    } catch (e) {
      deleteFile();
      print(e.toString());
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  //* ask query to RAG
  Future<String> askQueryRAG(
      {required String userId, required String query}) async {
    try {
      _isQuerying = true;
      _isTyping = true;

      _messages.add(
          MessageAIModel("user", message: query, sendTime: DateTime.now()));

      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _healthAiServices.askQuery(user_id: userId, query: query);

      String agent_message = cleanMessage(response.message);

      _messages.add(MessageAIModel("agent",
          message: agent_message, sendTime: DateTime.now()));
      notifyListeners();

      if (response.statusCode == 200) {
        return response.message;
      } else {
        return response.message;
      }
    } catch (e) {
      print(e);
      _messages.add(MessageAIModel("agent",
          message: 'The server is busy right now. Please try again in a moment',
          sendTime: DateTime.now()));
      return 'The server is busy right now. Please try again in a moment';
    } finally {
      _isQuerying = false;
      _isTyping = false;
      notifyListeners();
    }
  }

  //* delete FAISS Index
  Future<void> deleteFAISSIndex({required String userId}) async {
    try {
      await _healthAiServices.deleteIndex(user_id: userId);
    } catch (e) {
      print(e);
    }
  }

  //* <---------RESET---------------->
  Future<void> reset() async {
    _file = null;
    _isUploading = false;
    _isQuerying = false;
    _isTyping = false;

    // Reset messages to default greeting
    _messages = [
      MessageAIModel("agent",
          message:
              "Hi! I'm your health report assistant. Upload your medical reports and ask me any questions about them.",
          sendTime: DateTime.now())
    ];

    notifyListeners();
  }
}

class MessageAIModel {
  final String message;
  final String role;
  final DateTime sendTime;

  MessageAIModel(this.role, {required this.message, required this.sendTime});
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/features/pillbot/data/services/pillbot_service.dart';
import '../model/message_model.dart';

class PillBotProvider extends ChangeNotifier {
  final PillbotService _service = PillbotService();

  /// [userId] should be passed from the UI as context.read<UserProvider>().user?.id
  Future<String> _resolveToken(String? userId) async {
    String token = userId ?? '';
    if (token.isEmpty) {
      final cachedData = await CacheManager().getCachedUserProfile();
      if (cachedData != null) {
        token = cachedData['id'] ?? cachedData['_id'] ?? '';
      }
    }
    return token;
  }

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isQuerying = false;
  bool get isQuerying => _isQuerying;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  bool _isClearingHistory = false;
  bool get isClearingHistory => _isClearingHistory;

  bool _isTimedOut = false;
  bool get isTimedOut => _isTimedOut;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  int _pageLimit = 40;
  int get pageLimit => _pageLimit;
  set pageLimit(int value) {
    _pageLimit = value;
    notifyListeners();
  }

  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;
  set hasMorePages(bool value) {
    _hasMorePages = value;
    notifyListeners();
  }

  static const int _timeoutSeconds = 95;
  Timer? _requestTimer;

  void _startTimer(void Function() onTimeout) {
    _cancelTimer();
    _requestTimer = Timer(
      const Duration(seconds: _timeoutSeconds),
      onTimeout,
    );
  }

  void _cancelTimer() {
    _requestTimer?.cancel();
    _requestTimer = null;
  }

  Future<void> sendMessage(
      {required String userMessage,
      File? file,
      String latitude = "",
      String longitude = "",
      String? userId}) async {
    if (userMessage.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      message: userMessage.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    //* append token
    // final HttpClient _httpClient = HttpClient();
    // final jwt = await _httpClient.getAuthToken();

    //userMessage += "\n The JWT Token is ${jwt}";

    _isQuerying = true;
    _isTimedOut = false;
    _errorMessage = null;
    notifyListeners();

    _startTimer(() {
      _cancelTimer();
      _isQuerying = false;
      _isTimedOut = true;
      _errorMessage =
          'Request timed out after ${_timeoutSeconds}s. Please try again.';
      notifyListeners();
    });

    final token = await _resolveToken(userId);

    Logger().d("Lattitude is ${latitude}");
    Logger().d("Lattitude is ${longitude}");

    final result = await _service.queryAgent(
        token: token,
        userMessage: userMessage.trim(),
        file: file,
        latitude: latitude,
        longitude: longitude);

    _cancelTimer();

    if (_isTimedOut) return;

    if (result['success'] == true) {
      final rawData = result['data'];
      final Map<String, dynamic> data;
      if (rawData is String) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        data = rawData as Map<String, dynamic>;
      }

      final agentMsg = ChatMessage.fromJson(data);
      _messages.add(agentMsg);
      _isQuerying = false;
    } else {
      _errorMessage = result['error']?.toString() ?? 'Something went wrong.';
      _isQuerying = false;
    }
    notifyListeners();
  }

  Future<void> fetchHistory(
      {bool reset = false, String? userId}) async {
    if (_isLoadingMessages) return;
    if (!reset && !_hasMorePages) return;

    if (reset) {
      _currentPage = 1;
      _hasMorePages = true;
      _messages.clear();
    }

    _isLoadingMessages = true;
    _errorMessage = null;
    notifyListeners();

    bool historyTimedOut = false;
    _startTimer(() {
      _cancelTimer();
      historyTimedOut = true;
      _isLoadingMessages = false;
      _errorMessage =
          'Loading messages timed out after ${_timeoutSeconds}s. Please try again.';
      notifyListeners();
    });

    final token = await _resolveToken(userId);

    Logger().d("User token is ${token}");

    final result = await _service.getHistory(
      token: token,
      page: _currentPage,
      limit: _pageLimit,
    );

    _cancelTimer();

    if (historyTimedOut) return;

    if (result['success'] == true) {
      final Map<String, dynamic> data = result['data'] as Map<String, dynamic>;
      final List<dynamic> rawList = data['history'] as List<dynamic>;
      final List<ChatMessage> fetched = rawList
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      final pagination = data['pagination'] as Map<String, dynamic>?;
      _hasMorePages = pagination?['hasMore'] as bool? ?? fetched.length >= _pageLimit;

      if (reset) {
        _messages = fetched;
      } else {
        _messages.insertAll(0, fetched);
      }

      _currentPage++;
    } else {
      _errorMessage = result['error']?.toString() ?? 'Failed to load history.';
    }

    _isLoadingMessages = false;
    notifyListeners();
  }

  Future<bool> clearHistory({String? userId}) async {
    if (_isClearingHistory) return false;

    _isClearingHistory = true;
    _errorMessage = null;
    notifyListeners();

    bool clearTimedOut = false;
    _startTimer(() {
      _cancelTimer();
      clearTimedOut = true;
      _isClearingHistory = false;
      _errorMessage =
          'Clear history timed out after ${_timeoutSeconds}s. Please try again.';
      notifyListeners();
    });

    final token = await _resolveToken(userId);

    final result = await _service.clearHistory(token);

    _cancelTimer();

    if (clearTimedOut) return false;

    if (result['success'] == true) {
      _messages.clear();
      _currentPage = 1;
      _hasMorePages = true;
      _isClearingHistory = false;
      notifyListeners();
      return true;
    }

    _errorMessage = result['error']?.toString() ?? 'Failed to clear history.';
    _isClearingHistory = false;
    notifyListeners();
    return false;
  }

  Future<bool> clearKnowledge({String? userId}) async {
    final token = await _resolveToken(userId);

    final result = await _service.clearKnowledge(token);
    if (result['success'] != true) {
      _errorMessage =
          result['error']?.toString() ?? 'Failed to clear knowledge.';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> checkHealth() async {
    final result = await _service.checkHealth();
    return result['success'] == true;
  }

  void clearError() {
    _errorMessage = null;
    _isTimedOut = false;
    notifyListeners();
  }

  void resetState() {
    _isQuerying = false;
    _isTimedOut = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> reset() async {
    _cancelTimer();
    _messages = [];
    _isQuerying = false;
    _isLoadingMessages = false;
    _isClearingHistory = false;
    _isTimedOut = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}

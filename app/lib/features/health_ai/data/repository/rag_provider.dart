import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/config/notifications/notification_config.dart';
import 'package:pillbin/config/notifications/notification_model.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/health_ai/data/model/rag_model.dart';
import 'package:pillbin/features/health_ai/data/service/rag_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/utils/http_client.dart';

class RagProvider extends ChangeNotifier {
  final RagServices _ragServices = RagServices();
  final Logger _logger = Logger();

  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  //* <------------ STATE --------------------- >
  final List<HealthRagModel> _ragDocuments = [];
  List<HealthRagModel> get ragDocuments => List.unmodifiable(_ragDocuments);

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  int _page = 1;
  final int _limit = 15;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  //* <--------- INIT ----------------->
  RagProvider();

  //* < -------------- HELPERS ----------------->
  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  //* fetch History
  Future<void> fetchRagHistory(
      {bool refresh = false, bool forceRefresh = false}) async {
    if (_isFetching || (!_hasMore && !refresh)) return;

    try {
      _isFetching = true;

      if (refresh) {
        _page = 1;
        _hasMore = true;
        _ragDocuments.clear();
      }

      final isOnline = _httpClient.isOnline;

      if (_page == 1 &&
          !forceRefresh &&
          (!isOnline || await _cacheManager.hasValidRagHistoryCache())) {
        final cachedData = await _cacheManager.getCachedRagHistory();

        if (cachedData != null) {
          final List list = cachedData['data'] ?? [];
          final fetchedDocs =
              list.map((e) => HealthRagModel.fromJson(e)).toList();
          _ragDocuments.addAll(fetchedDocs);

          _isFetching = false;
          notifyListeners();
          return;
        }
      }

      if (isOnline || forceRefresh) {
        final ApiResponse<Map<String, dynamic>> response =
            await _ragServices.fetchRagHistory(
          page: _page,
          limit: _limit,
        );

        if (response.statusCode == 200) {
          final data = response.data!;

          if (_page == 1) {
            await _cacheManager.cacheRagHistory(data);
          }

          final List list = data['data'];
          final fetchedDocs =
              list.map((e) => HealthRagModel.fromJson(e)).toList();

          _ragDocuments.addAll(fetchedDocs);

          final pagination = data['pagination'];
          _hasMore = pagination['hasMore'] ?? false;
          _page++;
        }
      }
    } catch (e) {
      _logger.e(e);
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  //* Save New PDF Data (Upload)
  Future<void> savePDFData({
    required BuildContext context,
    required String pdfName,
    required String pdfDescription,
    required List<Map<String, dynamic>> queries,
  }) async {
    try {
      _setUploading(true);

      final response = await _ragServices.savePDFData(
        pdfName: pdfName,
        pdfDescription: pdfDescription,
        queries: queries,
      );

      if (response.statusCode == 201) {
        final newDoc = HealthRagModel.fromJson(response.data!);

        _ragDocuments.insert(0, newDoc);

        //* Show User Notification

        int randomId = Random().nextInt(100000);

        NotificationConfig().showInstantNotification(
          notify: PushNotificationModel(
            id: randomId.toString(),
            title: "✅ PDF Analysis Saved",
            body:
                "The analysis for '$pdfName' has been saved! 📂✨ Check the Saved Analysis screen. 👇",
          ),
        );

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.check_circle,
            title: "PDF Data Saved Successfully",
          );
        }
      } else {
        throw Exception("Failed to save PDF data");
      }
    } catch (e) {
      _logger.e(e);
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Failed to save PDF data.",
        );
      }
    } finally {
      _setUploading(false);
    }
  }

  //* Delete Single Document
  Future<void> deleteRagDocument(String ragId, BuildContext context) async {
    try {
      final index = _ragDocuments.indexWhere((doc) => doc.id == ragId);
      final backup = index != -1 ? _ragDocuments[index] : null;

      if (index != -1) {
        _ragDocuments.removeAt(index);
        notifyListeners();
      }

      final response = await _ragServices.deleteRagDocument(ragId: ragId);

      if (response.statusCode != 200) {
        if (backup != null) {
          _ragDocuments.insert(index, backup);
          notifyListeners();
        }
        throw Exception("Delete failed");
      }
    } catch (e) {
      _logger.e(e);
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Could not delete document.",
        );
      }
    }
  }

  //* Clear Entire History
  Future<void> clearRagHistory(BuildContext context) async {
    try {
      final response = await _ragServices.clearRAGHistory();

      Logger().d(response.statusCode);
      Logger().d(response.data);
      Logger().d(response.message);

      if (response.statusCode == 200) {
        Logger().d("checl");
        _ragDocuments.clear();
        _page = 1;
        _hasMore = true;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.delete_forever,
            title: "History Cleared",
          );
        }
      }
    } catch (e) {
      _logger.e(e);
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Failed to clear history.",
        );
      }
    }
  }

  //* Reset (Local UI Reset)
  Future<void> reset() async {
    _ragDocuments.clear();
    _page = 1;
    _hasMore = true;
    _isUploading = false;
    notifyListeners();
  }
}

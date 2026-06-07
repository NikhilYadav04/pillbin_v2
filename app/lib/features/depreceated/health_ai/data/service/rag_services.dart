import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class RagServices extends ApiService {
  //* Save new RAG PDF Data
  Future<ApiResponse<Map<String, dynamic>>> savePDFData({
    required String pdfName,
    required String pdfDescription,
    required List<Map<String, dynamic>> queries,
  }) async {
    return post(
      ApiEndpoints.savePDFData,
      data: {
        "pdfName": pdfName,
        "pdfDescription": pdfDescription,
        "queries": queries,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Fetch RAG history (pagination)
  Future<ApiResponse<Map<String, dynamic>>> fetchRagHistory({
    required int page,
    required int limit,
  }) async {
    return get(
      ApiEndpoints.fetchRagHistory(page: page, limit: limit),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Delete single RAG document
  Future<ApiResponse<Map<String, dynamic>>> deleteRagDocument({
    required String ragId,
  }) async {
    return delete(
      ApiEndpoints.deleteRagDocument(ragId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Clear entire RAG history
  Future<ApiResponse<Map<String, dynamic>>> clearRAGHistory() async {
    return delete(
      ApiEndpoints.clearRAGHistory,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}

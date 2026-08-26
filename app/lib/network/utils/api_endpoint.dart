import 'package:pillbin/network/config/api_config.dart';

class ApiEndpoints {
  //* Auth
  static String get signUp => '${ApiConfig.baseUrl}/api/auth/signup';
  static String get signin => '${ApiConfig.baseUrl}/api/auth/signin';
  static String get googleAuth =>
      '${ApiConfig.baseUrl}/api/auth/google';

  //* OTP
  static String get verifyOTPsignUp =>
      '${ApiConfig.baseUrl}/api/auth/verify-signup';
  static String get verifyOTPsignIn =>
      '${ApiConfig.baseUrl}/api/auth/verify-signin';

  //* Complete Profile
  static String get completeProfile =>
      '${ApiConfig.baseUrl}/api/user/complete-profile';
  static String get editProfile => '${ApiConfig.baseUrl}/api/user/edit-profile';
  static String get getProfile => '${ApiConfig.baseUrl}/api/user/profile';

  static String get saveMedicalCenter =>
      '${ApiConfig.baseUrl}/api/user/save-medical-center';
  static String get removeSavedMedicalCenter =>
      '${ApiConfig.baseUrl}/api/user/remove-saved-medical-center';
  static String getSavedMedicalCenters(int page, int limit) =>
      '${ApiConfig.baseUrl}/api/user/saved-medical-centers?page=${page}&limit=${limit}';

  //* Medicine
  static String get addMedicine => '${ApiConfig.baseUrl}/api/medicine/add';

  static String get familyMembers => '${ApiConfig.baseUrl}/api/family-members';
  static String deleteFamilyMember(String id) =>
      '${ApiConfig.baseUrl}/api/family-members/$id';
  static String get getInventory =>
      '${ApiConfig.baseUrl}/api/medicine/inventory';
  static String get getInventoryDeleted =>
      '${ApiConfig.baseUrl}/api/medicine/deleted-inventory';

  static String updateMedicine(String medicineId) =>
      '${ApiConfig.baseUrl}/api/medicine/update/${medicineId}';
  static String deleteMedicine(String medicineId) =>
      '${ApiConfig.baseUrl}/api/medicine/delete/${medicineId}';
  static String get deleteAllExpired =>
      '${ApiConfig.baseUrl}/api/medicine/delete-all-expired';

  static String deleteMedicineHard(String medicineId) =>
      '${ApiConfig.baseUrl}/api/medicine/delete/${medicineId}/hard';
  static String get deleteAllHard =>
      '${ApiConfig.baseUrl}/api/medicine/delete-all-hard';

  //* Medical Center (****)
  static String getAllMedicalCenters(int page, int limit) =>
      '${ApiConfig.baseUrl}/api/medical-center/all?page=${page}&limit=$limit';
  static String getNearbyMedicalCenters(
          double latitude, double longitude, int radius, int page, int limit) =>
      '${ApiConfig.baseUrl}/api/medical-center/nearby?latitude=${latitude}&longitude=${longitude}&radius=${radius}&page=${page}&limit=${limit}';
  static String getNearbyNeeds(double latitude, double longitude) =>
      '${ApiConfig.baseUrl}/api/medical-center/nearby-needs?latitude=${latitude}&longitude=${longitude}';
  static String searchMedicalCenters(
          String query, String facilityType, int page, int limit) =>
      '${ApiConfig.baseUrl}/api/medical-center/search?query=${query}&facilityType=${facilityType}&page=${page}&limit=${limit}';
  static String getMedicalCenterbyID(String medicalCenterId) =>
      '${ApiConfig.baseUrl}/api/medical-center/${medicalCenterId}';

  static String get addMedicalCenter =>
      '${ApiConfig.baseUrl}/api/medical-center/add';
  static String updateMedicalCenter(String medicalCenterId) =>
      '${ApiConfig.baseUrl}/api/medical-center/update/${medicalCenterId}';
  static String deleteMedicalCenter(String medicalCenterId) =>
      '${ApiConfig.baseUrl}/api/medical-center/delete/${medicalCenterId}';

  //* Chatbot
  static String get sendQueryToChatbot => '${ApiConfig.baseUrl}/api/chatbot/';

  static String deleteChatMessage(String messageId) =>
      '${ApiConfig.baseUrl}/api/chatbot$messageId';

  static String get clearChatHistory =>
      '${ApiConfig.baseUrl}/api/chatbot/clear';

  static String fetchChatMessages({int page = 1, int limit = 20}) =>
      '${ApiConfig.baseUrl}/api/chatbot?page=$page&limit=$limit';

  //* Notification
  static String get Notification => '${ApiConfig.baseUrl}/api/notifications';

  static String notificationsPaged({int page = 1, int limit = 20}) =>
      '${ApiConfig.baseUrl}/api/notifications?page=$page&limit=$limit';
  static String get markNotificationRead =>
      '${ApiConfig.baseUrl}/api/notifications/read';
  static String get notificationUnreadCount =>
      '${ApiConfig.baseUrl}/api/notifications/unread-count';
  static String get registerDeviceToken =>
      '${ApiConfig.baseUrl}/api/notifications/tokens/register';
  static String get deactivateDeviceToken =>
      '${ApiConfig.baseUrl}/api/notifications/tokens/deactivate';
  static String deleteNotification(String notificationId) =>
      '${ApiConfig.baseUrl}/api/notifications/${notificationId}';
  static String get deleteAllNotification =>
      '${ApiConfig.baseUrl}/api/notifications/';

  //* Health AI
  static String get uploadPDF => '${ApiConfig.agentURL}/api/upload';
  static String get askQuery => '${ApiConfig.agentURL}/api/query';
  static String get deleteIndex => '${ApiConfig.agentURL}/api/delete_index';

  //* Health AI data routes
  static String get savePDFData => '${ApiConfig.baseUrl}/api/rag';

  static String deleteRagDocument(String ragId) =>
      '${ApiConfig.baseUrl}/api/rag/$ragId';

  static String get clearRAGHistory => '${ApiConfig.baseUrl}/api/rag/clear';

  static String fetchRagHistory({int page = 1, int limit = 20}) =>
      '${ApiConfig.baseUrl}/api/rag?page=$page&limit=$limit';

  //* Blog Endpoints
  static String get createBlog => '${ApiConfig.baseUrl}/api/blog';

  static String getAllBlogs({int page = 1, int limit = 10}) =>
      '${ApiConfig.baseUrl}/api/blog?page=$page&limit=$limit';

  static String getUserBlogs({int page = 1, int limit = 10}) =>
      '${ApiConfig.baseUrl}/api/blog/user?page=$page&limit=$limit';

  static String getBlog(String blogId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId';

  static String updateBlog(String blogId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId';

  static String deleteBlog(String blogId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId';

  static String generateBlogImage({required String query}) =>
      '${ApiConfig.baseUrl}/api/blog/generate/image?query=${Uri.encodeComponent(query)}';

  //* Like Endpoints
  static String toggleLike(String blogId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/likes';

  static String getLikeStatus(String blogId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/likes/status';

  static String getBlogLikers(String blogId, {int page = 1, int limit = 20}) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/likes?page=$page&limit=$limit';

  //* Comment Endpoints
  static String addComment(String blogId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/comments';

  static String getBlogComments(String blogId,
          {int page = 1, int limit = 20}) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/comments?page=$page&limit=$limit';

  static String updateComment(String blogId, String commentId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/comments/$commentId';

  static String deleteComment(String blogId, String commentId) =>
      '${ApiConfig.baseUrl}/api/blog/$blogId/comments/$commentId';

  //* Vendor Endpoints
  static String get vendorRegisterCenter =>
      '${ApiConfig.baseUrl}/api/vendor/register-center';
  static String get vendorMyCenter =>
      '${ApiConfig.baseUrl}/api/vendor/my-center';
  static String get vendorInventory =>
      '${ApiConfig.baseUrl}/api/vendor/inventory';
  static String get vendorCenterImages =>
      '${ApiConfig.baseUrl}/api/vendor/my-center/images';
  static String vendorDonatedMedicines({int page = 1, int limit = 20}) =>
      '${ApiConfig.baseUrl}/api/vendor/analytics/medicines?page=$page&limit=$limit';

  static String vendorAnalytics({int months = 6}) =>
      '${ApiConfig.baseUrl}/api/vendor/analytics?months=$months';

  static String vendorRequests({String? status, int page = 1, int limit = 10}) {
    final q = status != null ? '&status=$status' : '';
    return '${ApiConfig.baseUrl}/api/vendor/requests?page=$page&limit=$limit$q';
  }

  static String vendorRequestUpdate(String requestId) =>
      '${ApiConfig.baseUrl}/api/vendor/requests/$requestId';
  static String vendorRequestComplete(String requestId) =>
      '${ApiConfig.baseUrl}/api/vendor/requests/$requestId/complete';
  static String searchCentersForClaim(String query) =>
      '${ApiConfig.baseUrl}/api/medical-center/search?query=${Uri.encodeComponent(query)}&facilityType=all&page=1&limit=20';

  //* Vendor Verification
  static String get vendorUploadVerificationDocs =>
      '${ApiConfig.baseUrl}/api/vendor/verify-documents';

  //* Admin Endpoints
  static String get adminPendingVerifications =>
      '${ApiConfig.baseUrl}/api/admin/verifications';
  static String adminApproveVerification(String centerId) =>
      '${ApiConfig.baseUrl}/api/admin/verifications/$centerId/approve';
  static String adminRejectVerification(String centerId) =>
      '${ApiConfig.baseUrl}/api/admin/verifications/$centerId/reject';

  //* Donation Endpoints
  static String get submitDonation => '${ApiConfig.baseUrl}/api/donations';
  static String myDonationRequests({String? status, int page = 1, int limit = 10}) {
    final q = status != null ? '&status=$status' : '';
    return '${ApiConfig.baseUrl}/api/donations/my-requests?page=$page&limit=$limit$q';
  }

  static String handoffToken(String id) =>
      '${ApiConfig.baseUrl}/api/donations/$id/handoff-token';

  static String get vendorScan => '${ApiConfig.baseUrl}/api/vendor/scan';

  static String donationById(String id) =>
      '${ApiConfig.baseUrl}/api/donations/$id';

  static String reviewDonation(String id) =>
      '${ApiConfig.baseUrl}/api/donations/$id/review';

  static String centerReviews(String centerId,
          {int page = 1, int limit = 10, int? rating}) =>
      '${ApiConfig.baseUrl}/api/donations/center/$centerId/reviews'
      '?page=$page&limit=$limit${rating != null ? '&rating=$rating' : ''}';

  static String deleteReview(String reviewId) =>
      '${ApiConfig.baseUrl}/api/donations/review/$reviewId';

  //* Medical center inventory (public)
  static String medicalCenterInventory(String centerId) =>
      '${ApiConfig.baseUrl}/api/medical-center/$centerId/inventory';

  //* Agent Endpoints
  static String get queryAgent => '${ApiConfig.agentBaseUrl}/query';

  static String getHistory(
          {int page = 1, int limit = 40, required String token}) =>
      '${ApiConfig.agentBaseUrl}/history?token=$token&page=$page&limit=$limit';

  static String clearHistory(String token) =>
      '${ApiConfig.agentBaseUrl}/history?token=$token';

  static String clearKnowledge(String token) =>
      '${ApiConfig.agentBaseUrl}/knowledge?token=$token';

  static String get health => '${ApiConfig.agentBaseUrl}/health';
}

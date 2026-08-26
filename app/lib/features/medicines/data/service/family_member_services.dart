import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class FamilyMemberServices extends ApiService {
  Future<ApiResponse<Map<String, dynamic>>> list() async {
    return get(ApiEndpoints.familyMembers,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> add({
    required String name,
    String? relation,
  }) async {
    return post(
      ApiEndpoints.familyMembers,
      data: {"name": name, if (relation != null) "relation": relation},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> remove(String memberId) async {
    return delete(ApiEndpoints.deleteFamilyMember(memberId),
        fromJson: (data) => data as Map<String, dynamic>);
  }
}

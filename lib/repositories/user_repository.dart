import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/order.dart';
import '../models/api/user_profile.dart';

/// Current-user endpoints (users.controller.ts → /me).
class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  Future<UserProfile> me() async {
    final res = await _api.get(ApiEndpoints.me);
    return UserProfile.fromJson(res as Map<String, dynamic>);
  }

  /// PATCH /me/onboarding — sets region/currency/board/grade + marks onboarded.
  /// Returns the refreshed [UserProfile] via a follow-up /me (the endpoint
  /// itself returns the raw StudentProfile).
  Future<void> onboard({
    required String region,
    required String currency,
    required String board,
    required String gradeId,
    String? name,
  }) async {
    await _api.patch(ApiEndpoints.onboarding, body: {
      'region': region,
      'currency': currency,
      'board': board,
      'gradeId': gradeId,
      if (name != null && name.isNotEmpty) 'name': name,
    });
  }

  /// PATCH /me/profile — updates any subset of profile/KYC fields; returns /me.
  Future<UserProfile> updateProfile(Map<String, dynamic> fields) async {
    final res = await _api.patch(ApiEndpoints.updateProfile, body: fields);
    return UserProfile.fromJson(res as Map<String, dynamic>);
  }

  Future<List<OrderModel>> orders() async {
    final res = await _api.get(ApiEndpoints.myOrders);
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }
}

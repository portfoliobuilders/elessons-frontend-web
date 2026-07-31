import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/session.dart';

/// All authentication endpoints (auth.controller.ts). Every call that logs a
/// user in resolves to an [AuthSession]. Throws [ApiException] on failure.
class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
    final res = await _api.post(ApiEndpoints.register, body: body, auth: false);
    return AuthSession.fromJson(res as Map<String, dynamic>);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(ApiEndpoints.login,
        body: {'email': email, 'password': password}, auth: false);
    return AuthSession.fromJson(res as Map<String, dynamic>);
  }

  Future<AuthActionResult> requestOtp(String phone) async {
    final res =
        await _api.post(ApiEndpoints.otpRequest, body: {'phone': phone}, auth: false);
    return AuthActionResult.fromJson(res as Map<String, dynamic>);
  }

  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final res = await _api.post(ApiEndpoints.otpVerify,
        body: {'phone': phone, 'code': code}, auth: false);
    return AuthSession.fromJson(res as Map<String, dynamic>);
  }

  Future<AuthActionResult> forgotPassword(String email) async {
    final res = await _api.post(ApiEndpoints.forgotPassword,
        body: {'email': email}, auth: false);
    return AuthActionResult.fromJson(res as Map<String, dynamic>);
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.post(ApiEndpoints.resetPassword,
        body: {'token': token, 'newPassword': newPassword}, auth: false);
  }

  Future<AuthSession> google(String idToken) async {
    final res = await _api.post(ApiEndpoints.google,
        body: {'idToken': idToken}, auth: false);
    return AuthSession.fromJson(res as Map<String, dynamic>);
  }

  Future<AuthSession> apple(String identityToken) async {
    final res = await _api.post(ApiEndpoints.apple,
        body: {'identityToken': identityToken}, auth: false);
    return AuthSession.fromJson(res as Map<String, dynamic>);
  }

  /// DEV convenience — mints a token for a test student (backend gates this
  /// behind ALLOW_DEV_LOGIN=true).
  Future<AuthSession> devLogin([String? email]) async {
    final res = await _api.post(ApiEndpoints.devLogin,
        body: {if (email != null) 'email': email}, auth: false);
    return AuthSession.fromJson(res as Map<String, dynamic>);
  }

  Future<void> logout(String refreshToken) async {
    await _api.post(ApiEndpoints.logout,
        body: {'refreshToken': refreshToken}, auth: false);
  }
}

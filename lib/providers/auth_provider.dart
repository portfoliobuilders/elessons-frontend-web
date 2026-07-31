import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/local_storage_service.dart';
import '../models/api/session.dart';
import '../models/api/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import 'view_status.dart';

/// High-level authentication state. On construction the app calls [bootstrap]
/// to attempt auto-login from the stored session. Owns login/register/OTP/
/// social/password flows and the forced-logout path (invoked by [ApiClient]
/// when a token refresh fails).
enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    LocalStorageService? storage,
    ApiClient? apiClient,
  })  : _auth = authRepository,
        _users = userRepository,
        _storage = storage ?? LocalStorageService.instance,
        _api = apiClient ?? ApiClient.instance {
    // When the client can't recover a session, drop straight to logged-out.
    _api.onUnauthorized = () => forceLogout();
  }

  final AuthRepository _auth;
  final UserRepository _users;
  final LocalStorageService _storage;
  final ApiClient _api;

  AuthState _state = AuthState.unknown;
  AuthState get state => _state;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  bool get isBusy => _status.isLoading;

  String? _error;
  String? get error => _error;

  UserProfile? _user;
  UserProfile? get user => _user;
  SessionUser? _sessionUser;

  bool get isAuthenticated => _state == AuthState.authenticated;
  String? get accessToken => _storage.accessToken;

  bool _onboarded = false;
  bool get isOnboarded => _user?.profile?.onboarded ?? _onboarded;

  /// Optional hook the UI layer sets to route to /welcome on a forced logout.
  VoidCallback? onForcedLogout;

  /// Attempt to restore a session at app start.
  Future<void> bootstrap() async {
    if (_storage.isLoggedIn && _storage.accessToken != null) {
      _onboarded = _storage.isOnboarded;
      final cached = _storage.user;
      if (cached != null) _sessionUser = SessionUser.fromJson(cached);
      _state = AuthState.authenticated; // optimistic; refresh below
      notifyListeners();
      // Validate + hydrate the full profile. Tolerate offline.
      try {
        _user = await _users.me();
        _onboarded = _user?.profile?.onboarded ?? _onboarded;
      } on ApiException catch (e) {
        if (e.isUnauthorized) {
          await forceLogout();
          return;
        }
        // Network/other error: keep the cached session so the app stays usable.
      }
      notifyListeners();
    } else {
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> _runSession(Future<AuthSession> Function() action) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final session = await action();
      await _persist(session);
      _status = ViewStatus.success;
      _state = AuthState.authenticated;
      notifyListeners();
      // Hydrate full profile in the background (non-fatal).
      _hydrateProfile();
      return true;
    } on ApiException catch (e) {
      _status = ViewStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = ViewStatus.error;
      _error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _persist(AuthSession session) async {
    await _storage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _storage.saveUser(session.user.toJson());
    _sessionUser = session.user;
    _onboarded = session.user.onboarded;
  }

  Future<void> _hydrateProfile() async {
    try {
      _user = await _users.me();
      _onboarded = _user?.profile?.onboarded ?? _onboarded;
      notifyListeners();
    } on ApiException catch (_) {
      // ignore — session user is enough to proceed
    }
  }

  // ── Public flows ────────────────────────────────────────────────────
  Future<bool> login(String email, String password) =>
      _runSession(() => _auth.login(email: email, password: password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _runSession(() =>
          _auth.register(name: name, email: email, password: password, phone: phone));

  Future<bool> verifyOtp({required String phone, required String code}) =>
      _runSession(() => _auth.verifyOtp(phone: phone, code: code));

  /// Requests an SMS OTP for [phone]. Returns the dev code when the backend is
  /// in ALLOW_DEV_LOGIN mode (so the OTP screen can auto-fill it), else null.
  Future<String?> requestOtp(String phone) async {
    try {
      final res = await _auth.requestOtp(phone);
      return res.devCode;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  /// The reset token echoed by the backend in dev mode (null in production,
  /// where it is delivered by email).
  String? lastResetToken;

  /// POST /auth/forgot-password. Returns true if the request was accepted.
  Future<bool> forgotPassword(String email) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final res = await _auth.forgotPassword(email);
      lastResetToken = res.devResetToken;
      _status = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// POST /auth/reset-password. Returns true on success.
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _auth.resetPassword(token: token, newPassword: newPassword);
      _status = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> google(String idToken) =>
      _runSession(() => _auth.google(idToken));

  Future<bool> apple(String identityToken) =>
      _runSession(() => _auth.apple(identityToken));

  Future<bool> devLogin([String? email]) =>
      _runSession(() => _auth.devLogin(email));

  /// Refreshes the cached full profile (after onboarding / profile edits).
  Future<void> refreshProfile() => _hydrateProfile();

  void markOnboarded() {
    _onboarded = true;
    _storage.setOnboarded(true);
    notifyListeners();
  }

  Future<void> logout() async {
    final rt = _storage.refreshToken;
    if (rt != null) {
      try {
        await _auth.logout(rt);
      } catch (_) {/* best effort */}
    }
    await _clearAndReset();
  }

  Future<void> forceLogout() async {
    await _clearAndReset();
    onForcedLogout?.call();
  }

  Future<void> _clearAndReset() async {
    await _storage.clearSession();
    _user = null;
    _sessionUser = null;
    _onboarded = false;
    _status = ViewStatus.idle;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // Convenience getters for the UI (session user is available immediately).
  String get displayName =>
      _user?.displayName ?? _sessionUser?.name ?? _sessionUser?.email ?? 'Student';
  String get displayEmail => _user?.email ?? _sessionUser?.email ?? '';
  String? get phone => _sessionUser?.phone;
  String get initials => _user?.initials ?? _initialsFrom(displayName);

  String _initialsFrom(String s) {
    final t = s.trim();
    if (t.isEmpty) return 'G';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

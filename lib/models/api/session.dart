import '../../core/utils/json.dart';

/// The `{ accessToken, refreshToken, user }` payload returned by every auth
/// endpoint (register/login/google/otp verify/dev-login).
/// See auth.service.ts → `session()`.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final SessionUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: Json.str(json['accessToken']),
      refreshToken: Json.str(json['refreshToken']),
      user: SessionUser.fromJson(Json.obj(json['user'])),
    );
  }
}

/// The lightweight user object embedded in an [AuthSession].
class SessionUser {
  const SessionUser({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.onboarded,
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final bool onboarded;

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: Json.str(json['id']),
      name: Json.strOrNull(json['name']),
      email: Json.strOrNull(json['email']),
      phone: Json.strOrNull(json['phone']),
      avatarUrl: Json.strOrNull(json['avatarUrl']),
      role: Json.str(json['role'], 'STUDENT'),
      onboarded: Json.boolVal(json['onboarded']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'role': role,
        'onboarded': onboarded,
      };
}

/// Response of dev/OTP/reset helpers that echo a dev code in development
/// (`{ sent: true, devCode?, devResetToken? }`).
class AuthActionResult {
  const AuthActionResult({this.sent = true, this.devCode, this.devResetToken});

  final bool sent;
  final String? devCode;
  final String? devResetToken;

  factory AuthActionResult.fromJson(Map<String, dynamic> json) {
    return AuthActionResult(
      sent: Json.boolVal(json['sent'], true),
      devCode: Json.strOrNull(json['devCode']),
      devResetToken: Json.strOrNull(json['devResetToken']),
    );
  }
}

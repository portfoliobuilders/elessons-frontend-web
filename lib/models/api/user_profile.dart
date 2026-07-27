import '../../core/utils/json.dart';

/// Response of `GET /me` (users.service.ts → `me()`):
/// `{ id, name, email, avatarUrl, role, profile }`.
class UserProfile {
  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    required this.role,
    this.profile,
  });

  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String role;
  final StudentProfile? profile;

  String get displayName => (name != null && name!.trim().isNotEmpty)
      ? name!
      : (email ?? 'Student');

  /// Monogram for the avatar tile (e.g. "MB").
  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return 'G';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    return UserProfile(
      id: Json.str(json['id']),
      name: Json.strOrNull(json['name']),
      email: Json.strOrNull(json['email']),
      avatarUrl: Json.strOrNull(json['avatarUrl']),
      role: Json.str(json['role'], 'STUDENT'),
      profile: profileJson is Map<String, dynamic>
          ? StudentProfile.fromJson(profileJson)
          : null,
    );
  }
}

/// The embedded StudentProfile (region, board, grade, KYC fields).
class StudentProfile {
  const StudentProfile({
    this.region = 'IN',
    this.currency = 'INR',
    this.board,
    this.gradeId,
    this.gradeName,
    this.onboarded = false,
    this.photoUrl,
    this.dob,
    this.gender,
    this.addressLine,
    this.city,
    this.state,
    this.pincode,
    this.parentName,
    this.parentPhone,
    this.kycComplete = false,
  });

  final String region;
  final String currency;
  final String? board;
  final String? gradeId;
  final String? gradeName;
  final bool onboarded;

  final String? photoUrl;
  final DateTime? dob;
  final String? gender;
  final String? addressLine;
  final String? city;
  final String? state;
  final String? pincode;
  final String? parentName;
  final String? parentPhone;
  final bool kycComplete;

  /// Rough completion %, used by the "Complete your profile" prompt.
  int get kycPercent {
    const fields = [];
    final values = <Object?>[
      dob,
      gender,
      addressLine,
      city,
      state,
      pincode,
      parentName,
      parentPhone,
    ];
    final filled = values.where((v) {
      if (v == null) return false;
      if (v is String) return v.trim().isNotEmpty;
      return true;
    }).length;
    final total = values.length + fields.length;
    return total == 0 ? 0 : ((filled / total) * 100).round();
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    // `grade` may be a nested object (users.service includes grade: true).
    final gradeJson = json['grade'];
    return StudentProfile(
      region: Json.str(json['region'], 'IN'),
      currency: Json.str(json['currency'], 'INR'),
      board: Json.strOrNull(json['board']),
      gradeId: Json.strOrNull(json['gradeId']),
      gradeName: gradeJson is Map<String, dynamic>
          ? Json.strOrNull(gradeJson['name'])
          : null,
      onboarded: Json.boolVal(json['onboarded']),
      photoUrl: Json.strOrNull(json['photoUrl']),
      dob: Json.dateOrNull(json['dob']),
      gender: Json.strOrNull(json['gender']),
      addressLine: Json.strOrNull(json['addressLine']),
      city: Json.strOrNull(json['city']),
      state: Json.strOrNull(json['state']),
      pincode: Json.strOrNull(json['pincode']),
      parentName: Json.strOrNull(json['parentName']),
      parentPhone: Json.strOrNull(json['parentPhone']),
      kycComplete: Json.boolVal(json['kycComplete']),
    );
  }
}

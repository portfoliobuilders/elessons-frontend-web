import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/learning.dart';
import '../models/api/user_profile.dart';
import '../repositories/progress_repository.dart';
import '../repositories/user_repository.dart';
import 'view_status.dart';

/// Profile screen state: stats for the header + profile/KYC/onboarding writes.
/// The canonical user object lives on AuthProvider; this handles the extras.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required UserRepository userRepository,
    required ProgressRepository progressRepository,
  })  : _users = userRepository,
        _progress = progressRepository;

  final UserRepository _users;
  final ProgressRepository _progress;

  final ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  ProgressStats _stats = ProgressStats.zero;
  ProgressStats get stats => _stats;

  bool _saving = false;
  bool get isSaving => _saving;

  Future<void> loadStats() async {
    try {
      _stats = await _progress.stats();
      notifyListeners();
    } on ApiException catch (_) {}
  }

  /// PATCH /me/onboarding. Returns null on success or an error message.
  Future<String?> onboard({
    required String region,
    required String currency,
    required String board,
    required String gradeId,
    String? name,
  }) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _users.onboard(
        region: region,
        currency: currency,
        board: board,
        gradeId: gradeId,
        name: name,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  /// PATCH /me/profile. Returns the updated profile or null (message in [error]).
  Future<UserProfile?> updateProfile(Map<String, dynamic> fields) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _users.updateProfile(fields);
      return updated;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

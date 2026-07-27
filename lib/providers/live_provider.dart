import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/live.dart';
import '../repositories/live_repository.dart';
import 'view_status.dart';

/// Live classes: schedule, reminders, join, in-room chat.
class LiveProvider extends ChangeNotifier {
  LiveProvider(this._repo);
  final LiveRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<LiveClass> _classes = const [];
  List<LiveClass> get classes => _classes;

  LiveRoom? _room;
  LiveRoom? get room => _room;

  List<LiveChatMessage> _messages = const [];
  List<LiveChatMessage> get messages => _messages;

  Future<void> loadUpcoming() async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _classes = await _repo.upcoming();
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> toggleReminder(String id, bool on) async {
    try {
      await _repo.setReminder(id, on);
      _classes = _classes
          .map((c) => c.id == id
              ? LiveClass(
                  id: c.id,
                  title: c.title,
                  subject: c.subject,
                  mentorName: c.mentorName,
                  startsAt: c.startsAt,
                  status: c.status,
                  watchingCount: c.watchingCount,
                  reminderSet: on,
                  hasLiveAccess: c.hasLiveAccess)
              : c)
          .toList();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<String?> join(String id) async {
    try {
      _room = await _repo.join(id);
      _messages = await _repo.chat(id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> refreshChat(String id) async {
    try {
      _messages = await _repo.chat(id);
      notifyListeners();
    } on ApiException catch (_) {}
  }

  Future<String?> sendMessage(String id, String text) async {
    try {
      final msg = await _repo.postChat(id, text);
      _messages = [msg, ..._messages];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}

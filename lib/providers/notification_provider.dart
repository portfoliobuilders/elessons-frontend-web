import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/notification.dart';
import '../repositories/notification_repository.dart';
import 'view_status.dart';

/// Notifications feed + unread badge count.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._repo);
  final NotificationRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<NotificationModel> _items = const [];
  List<NotificationModel> get items => _items;

  int _unread = 0;
  int get unread => _unread;

  Future<void> load() async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.list();
      _unread = _items.where((n) => !n.read).length;
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unread = await _repo.unreadCount();
      notifyListeners();
    } on ApiException catch (_) {}
  }

  Future<void> markRead(String id) async {
    // optimistic
    _items = _items
        .map((n) => n.id == id
            ? NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                read: true,
                createdAt: n.createdAt)
            : n)
        .toList();
    _unread = _items.where((n) => !n.read).length;
    notifyListeners();
    try {
      await _repo.markRead(id);
    } on ApiException catch (_) {}
  }

  Future<void> markAllRead() async {
    _items = _items
        .map((n) => NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            read: true,
            createdAt: n.createdAt))
        .toList();
    _unread = 0;
    notifyListeners();
    try {
      await _repo.markAllRead();
    } on ApiException catch (_) {}
  }
}

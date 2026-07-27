import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/api/notification.dart';

/// Notifications (notifications.controller.ts → /me/notifications).
class NotificationRepository {
  NotificationRepository(this._api);
  final ApiClient _api;

  Future<List<NotificationModel>> list({bool unreadOnly = false}) async {
    final res = await _api.get(ApiEndpoints.notifications,
        query: {if (unreadOnly) 'unread': 'true'});
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
  }

  Future<int> unreadCount() async {
    final res = await _api.get(ApiEndpoints.notificationsUnreadCount);
    return Json.intVal(Json.obj(res)['unread']);
  }

  Future<void> markRead(String id) async {
    await _api.patch(ApiEndpoints.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _api.patch(ApiEndpoints.notificationsReadAll);
  }
}

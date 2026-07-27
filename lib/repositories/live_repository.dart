import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/live.dart';

/// Live classes (live.controller.ts). Join/chat require the Live+Recorded plan.
class LiveRepository {
  LiveRepository(this._api);
  final ApiClient _api;

  Future<List<LiveClass>> upcoming() async {
    final res = await _api.get(ApiEndpoints.liveClasses);
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(LiveClass.fromJson)
        .toList();
  }

  Future<bool> setReminder(String id, bool on) async {
    await _api.post(on
        ? ApiEndpoints.liveReminderOn(id)
        : ApiEndpoints.liveReminderOff(id));
    return on;
  }

  Future<LiveRoom> join(String id) async {
    final res = await _api.get(ApiEndpoints.liveJoin(id));
    return LiveRoom.fromJson(res as Map<String, dynamic>);
  }

  Future<List<LiveChatMessage>> chat(String id) async {
    final res = await _api.get(ApiEndpoints.liveChat(id));
    return (res as List)
        .whereType<Map<String, dynamic>>()
        .map(LiveChatMessage.fromJson)
        .toList();
  }

  Future<LiveChatMessage> postChat(String id, String message) async {
    final res =
        await _api.post(ApiEndpoints.liveChat(id), body: {'message': message});
    return LiveChatMessage.fromJson(res as Map<String, dynamic>);
  }
}

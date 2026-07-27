import '../../core/utils/json.dart';

/// Upcoming live class row — GET /live-classes.
class LiveClass {
  const LiveClass({
    required this.id,
    required this.title,
    this.subject,
    required this.mentorName,
    this.startsAt,
    required this.status,
    this.watchingCount = 0,
    this.reminderSet = false,
    this.hasLiveAccess = false,
  });

  final String id;
  final String title;
  final String? subject;
  final String mentorName;
  final DateTime? startsAt;
  final String status; // SCHEDULED | LIVE | ENDED | CANCELLED
  final int watchingCount;
  final bool reminderSet;
  final bool hasLiveAccess;

  bool get isLive => status == 'LIVE';

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: Json.str(json['id']),
      title: Json.str(json['title']),
      subject: Json.strOrNull(json['subject']),
      mentorName: Json.str(json['mentorName']),
      startsAt: Json.dateOrNull(json['startsAt']),
      status: Json.str(json['status'], 'SCHEDULED'),
      watchingCount: Json.intVal(json['watchingCount']),
      reminderSet: Json.boolVal(json['reminderSet']),
      hasLiveAccess: Json.boolVal(json['hasLiveAccess']),
    );
  }
}

/// Live room join payload — GET /live-classes/:id/join.
class LiveRoom {
  const LiveRoom({
    required this.id,
    required this.title,
    required this.mentorName,
    this.youtubeId,
    this.embedUrl,
    this.watchingCount = 0,
  });

  final String id;
  final String title;
  final String mentorName;
  final String? youtubeId;
  final String? embedUrl;
  final int watchingCount;

  factory LiveRoom.fromJson(Map<String, dynamic> json) {
    return LiveRoom(
      id: Json.str(json['id']),
      title: Json.str(json['title']),
      mentorName: Json.str(json['mentorName']),
      youtubeId: Json.strOrNull(json['youtubeId']),
      embedUrl: Json.strOrNull(json['embedUrl']),
      watchingCount: Json.intVal(json['watchingCount']),
    );
  }
}

class LiveChatMessage {
  const LiveChatMessage({
    required this.id,
    required this.message,
    this.userName,
    this.createdAt,
  });

  final String id;
  final String message;
  final String? userName;
  final DateTime? createdAt;

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) {
    return LiveChatMessage(
      id: Json.str(json['id']),
      message: Json.str(json['message']),
      userName: Json.strOrNull(Json.obj(json['user'])['name']),
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }
}

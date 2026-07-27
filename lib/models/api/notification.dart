import '../../core/utils/json.dart';

/// A notification row — GET /me/notifications.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    this.createdAt,
  });

  final String id;
  final String type; // GENERAL | PAYMENT | DOUBT_ANSWERED | LIVE | OFFER …
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  /// Relative "time ago" label for the UI.
  String get timeLabel {
    final t = createdAt;
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: Json.str(json['id']),
      type: Json.str(json['type'], 'GENERAL'),
      title: Json.str(json['title']),
      body: Json.str(json['body']),
      read: Json.boolVal(json['read']),
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }
}

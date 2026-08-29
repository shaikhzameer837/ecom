import 'model_utils.dart';

enum NotificationType { offer, discount, order, cartReminder, general }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.general,
    this.targetId = '',
    this.read = false,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;

  /// Order id / product id / category id depending on [type].
  final String targetId;
  final bool read;
  final int createdAt;

  factory AppNotification.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return AppNotification(
      id: id,
      title: ModelUtils.asString(map['title']),
      body: ModelUtils.asString(map['body']),
      type: NotificationType.values
              .asNameMap()[ModelUtils.asString(map['type'])] ??
          NotificationType.general,
      targetId: ModelUtils.asString(map['targetId']),
      read: ModelUtils.asBool(map['read']),
      createdAt: ModelUtils.asInt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type.name,
        'targetId': targetId,
        'read': read,
        'createdAt': createdAt,
      };
}

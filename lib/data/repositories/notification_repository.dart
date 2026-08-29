import '../../core/constants/db_paths.dart';
import '../models/app_notification.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

class NotificationRepository extends BaseRepository {
  Stream<List<AppNotification>> watchNotifications(String uid) =>
      ref('${DbPaths.notifications}/$uid').onValue.map((event) {
        final map = ModelUtils.asMap(event.snapshot.value);
        final items = map.entries
            .map((e) => AppNotification.fromMap(e.key, e.value))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Future<void> add(String uid, AppNotification notification) => guard(
        () => ref('${DbPaths.notifications}/$uid')
            .push()
            .set(notification.toMap()),
        'addNotification',
      );

  Future<void> markRead(String uid, String notificationId) => guard(
        () => ref('${DbPaths.notifications}/$uid/$notificationId/read').set(true),
        'markRead',
      );

  Future<void> clearAll(String uid) => guard(
        () => ref('${DbPaths.notifications}/$uid').remove(),
        'clearAll',
      );
}

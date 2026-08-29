import '../../core/constants/db_paths.dart';
import '../models/app_user.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository {
  /// Creates the user profile on first login, otherwise returns the
  /// existing one.
  Future<AppUser> ensureProfile(String uid, String phone) => guard(() async {
        final snapshot = await ref('${DbPaths.users}/$uid').get();
        if (snapshot.exists) return AppUser.fromMap(uid, snapshot.value);
        final user = AppUser(
          uid: uid,
          phone: phone,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        await ref('${DbPaths.users}/$uid').set(user.toMap());
        return user;
      }, 'ensureProfile');

  /// Create-or-update used by the dev OTP bypass: writes the record on first
  /// login and refreshes phone + lastLoginAt on subsequent logins. Works
  /// without Firebase Auth (RTDB rules must permit the write).
  Future<AppUser> upsertUser(String uid, String phone) => guard(() async {
        final node = ref('${DbPaths.users}/$uid');
        final snapshot = await node.get();
        final now = DateTime.now().millisecondsSinceEpoch;
        if (snapshot.exists) {
          await node.update({'phone': phone, 'lastLoginAt': now});
          final refreshed = await node.get();
          return AppUser.fromMap(uid, refreshed.value);
        }
        final user = AppUser(uid: uid, phone: phone, createdAt: now);
        await node.set({...user.toMap(), 'lastLoginAt': now});
        return user;
      }, 'upsertUser');

  Future<AppUser?> fetchProfile(String uid) => guard(() async {
        final snapshot = await ref('${DbPaths.users}/$uid').get();
        if (!snapshot.exists) return null;
        return AppUser.fromMap(uid, snapshot.value);
      }, 'fetchProfile');

  Future<void> updateProfile(String uid, {String? name, String? email, String? photoUrl}) =>
      guard(() async {
        await ref('${DbPaths.users}/$uid').update({
          'name': ?name,
          'email': ?email,
          'photoUrl': ?photoUrl,
        });
      }, 'updateProfile');

  Future<void> saveFcmToken(String uid, String token) => guard(() async {
        await ref('${DbPaths.users}/$uid/fcmTokens/$token').set(true);
      }, 'saveFcmToken');

  Future<void> removeFcmToken(String uid, String token) => guard(() async {
        await ref('${DbPaths.users}/$uid/fcmTokens/$token').remove();
      }, 'removeFcmToken');
}

import '../../core/constants/db_paths.dart';
import '../models/coupon.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

class CouponRepository extends BaseRepository {
  Future<Coupon?> fetchCoupon(String code) => guard(() async {
        final normalized = code.trim().toUpperCase();
        if (normalized.isEmpty) return null;
        final snapshot = await ref('${DbPaths.coupons}/$normalized').get();
        if (!snapshot.exists) return null;
        return Coupon.fromMap(normalized, snapshot.value);
      }, 'fetchCoupon');

  // ---- Admin CRUD ----

  Future<List<Coupon>> fetchAll() => guard(() async {
        final snapshot = await ref(DbPaths.coupons).get();
        final map = ModelUtils.asMap(snapshot.value);
        return map.entries.map((e) => Coupon.fromMap(e.key, e.value)).toList()
          ..sort((a, b) => a.code.compareTo(b.code));
      }, 'fetchAllCoupons');

  /// The coupon code is the RTDB key, so this creates or overwrites by code.
  Future<void> upsertCoupon(Coupon coupon) => guard(
        () => ref('${DbPaths.coupons}/${coupon.code}').set(coupon.toMap()),
        'upsertCoupon',
      );

  Future<void> deleteCoupon(String code) => guard(
        () => ref('${DbPaths.coupons}/${code.toUpperCase()}').remove(),
        'deleteCoupon',
      );
}

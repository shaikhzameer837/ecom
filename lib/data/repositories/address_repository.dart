import '../../core/constants/db_paths.dart';
import '../models/address.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

class AddressRepository extends BaseRepository {
  Stream<List<Address>> watchAddresses(String uid) =>
      ref('${DbPaths.addresses}/$uid').onValue.map((event) {
        final map = ModelUtils.asMap(event.snapshot.value);
        final addresses =
            map.entries.map((e) => Address.fromMap(e.key, e.value)).toList()
              ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
        return addresses;
      });

  Future<String> addAddress(String uid, Address address) => guard(() async {
        final addressRef = ref('${DbPaths.addresses}/$uid').push();
        await addressRef.set(address.toMap());
        if (address.isDefault) await _clearOtherDefaults(uid, addressRef.key!);
        return addressRef.key!;
      }, 'addAddress');

  Future<void> updateAddress(String uid, Address address) => guard(() async {
        await ref('${DbPaths.addresses}/$uid/${address.id}').set(address.toMap());
        if (address.isDefault) await _clearOtherDefaults(uid, address.id);
      }, 'updateAddress');

  Future<void> deleteAddress(String uid, String addressId) => guard(
        () => ref('${DbPaths.addresses}/$uid/$addressId').remove(),
        'deleteAddress',
      );

  Future<void> _clearOtherDefaults(String uid, String keepId) async {
    final snapshot = await ref('${DbPaths.addresses}/$uid').get();
    final map = ModelUtils.asMap(snapshot.value);
    final updates = <String, dynamic>{};
    for (final entry in map.entries) {
      if (entry.key != keepId &&
          ModelUtils.asBool(ModelUtils.asMap(entry.value)['isDefault'])) {
        updates['${entry.key}/isDefault'] = false;
      }
    }
    if (updates.isNotEmpty) {
      await ref('${DbPaths.addresses}/$uid').update(updates);
    }
  }
}

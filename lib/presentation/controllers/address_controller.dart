import 'dart:async';

import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/address.dart';
import '../../data/repositories/address_repository.dart';
import 'auth_controller.dart';

class AddressController extends GetxController {
  AddressController({required this.addressRepository});

  final AddressRepository addressRepository;

  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  StreamSubscription<List<Address>>? _subscription;

  String? get _uid => Get.find<AuthController>().uid;

  Address? get defaultAddress =>
      addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.firstOrNull;

  @override
  void onInit() {
    super.onInit();
    final uid = _uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _subscription = addressRepository.watchAddresses(uid).listen(
      (value) {
        addresses.value = value;
        isLoading.value = false;
      },
      onError: (Object error) {
        AppLogger.e('Address stream error', error: error);
        isLoading.value = false;
      },
    );
  }

  Future<bool> save(Address address) async {
    final uid = _uid;
    if (uid == null) return false;
    isSaving.value = true;
    try {
      if (address.id.isEmpty) {
        await addressRepository.addAddress(uid, address);
      } else {
        await addressRepository.updateAddress(uid, address);
      }
      return true;
    } catch (error) {
      Get.snackbar('app_name'.tr, 'error_generic'.tr);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(String addressId) async {
    final uid = _uid;
    if (uid == null) return;
    await addressRepository.deleteAddress(uid, addressId);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

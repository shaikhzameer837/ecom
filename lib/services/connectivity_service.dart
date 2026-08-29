import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Reactive online/offline flag used by the global offline banner and by
/// controllers to short-circuit network calls with a friendly error.
///
/// Registered synchronously so [isOnline] is always available to the global
/// banner from the very first frame; the actual connectivity probe runs in
/// [onInit] and updates the flag once it resolves.
class ConnectivityService extends GetxService {
  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> _start() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _update(results);
      _subscription = Connectivity().onConnectivityChanged.listen(_update);
    } catch (_) {
      // Assume online if connectivity can't be determined.
      isOnline.value = true;
    }
  }

  void _update(List<ConnectivityResult> results) {
    isOnline.value =
        results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

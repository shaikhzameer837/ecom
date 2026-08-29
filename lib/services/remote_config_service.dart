import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/app_logger.dart';

/// Remote Config keeps tunable values (payment keys, feature flags,
/// thresholds) out of the binary.
class RemoteConfigService {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _config.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _config.setDefaults(const {
        AppConstants.razorpayKeyRemoteConfigKey: '',
        'free_shipping_threshold': AppConstants.freeShippingThreshold,
        'flash_sale_enabled': true,
      });
      await _config.fetchAndActivate();
    } catch (error, stackTrace) {
      // Non-fatal: defaults keep the app functional.
      AppLogger.e('RemoteConfig init failed', error: error, stackTrace: stackTrace);
    }
  }

  /// Razorpay publishable key id (not a secret; the key secret must only
  /// ever live on the server that verifies payments).
  String get razorpayKeyId =>
      _config.getString(AppConstants.razorpayKeyRemoteConfigKey);

  double get freeShippingThreshold {
    final value = _config.getDouble('free_shipping_threshold');
    return value > 0 ? value : AppConstants.freeShippingThreshold;
  }

  bool get flashSaleEnabled => _config.getBool('flash_sale_enabled');
}

import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../core/utils/app_exception.dart';
import '../core/utils/app_logger.dart';
import 'remote_config_service.dart';

class PaymentResult {
  const PaymentResult({required this.paymentId, this.orderId = '', this.signature = ''});

  final String paymentId;
  final String orderId;
  final String signature;
}

/// Razorpay checkout wrapper. UPI is offered through Razorpay's checkout
/// sheet (method preference "upi"), so both flows share one integration.
///
/// Note: amount verification/capture must be confirmed server-side (Cloud
/// Function) using the key secret before fulfilment — the client only
/// records the paymentId.
class PaymentService {
  PaymentService({required this.remoteConfig});

  final RemoteConfigService remoteConfig;

  Razorpay? _razorpay;
  Completer<PaymentResult>? _completer;

  /// Opens Razorpay checkout and resolves with the payment id, or throws
  /// [PaymentException] on failure/cancel.
  Future<PaymentResult> pay({
    required double amountInRupees,
    required String description,
    required String contactPhone,
    String? preferredMethod, // 'upi' to open UPI-first checkout
  }) {
    final keyId = remoteConfig.razorpayKeyId;
    if (keyId.isEmpty) {
      throw const PaymentException('error_payment');
    }

    _dispose();
    _razorpay = Razorpay();
    _completer = Completer<PaymentResult>();

    _razorpay!
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = <String, dynamic>{
      'key': keyId,
      'amount': (amountInRupees * 100).round(), // paise
      'currency': 'INR',
      'name': 'The Ramp',
      'description': description,
      'prefill': {'contact': contactPhone},
      'timeout': 300,
      if (preferredMethod == 'upi')
        'method': {
          'upi': true,
          'card': false,
          'netbanking': false,
          'wallet': false,
        },
    };

    try {
      _razorpay!.open(options);
    } catch (error, stackTrace) {
      AppLogger.e('Razorpay open failed', error: error, stackTrace: stackTrace);
      _completeError();
    }
    return _completer!.future.whenComplete(_dispose);
  }

  void _onSuccess(PaymentSuccessResponse response) {
    if (_completer?.isCompleted ?? true) return;
    _completer!.complete(PaymentResult(
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
    ));
  }

  void _onError(PaymentFailureResponse response) {
    AppLogger.d('Payment failed: ${response.code} ${response.message}',
        tag: 'Payment');
    final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    _completeError(cancelled ? 'payment_cancelled' : 'error_payment');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // External wallets complete outside the app; treat as pending failure
    // so the user can retry and the order stays unpaid.
    _completeError();
  }

  void _completeError([String message = 'error_payment']) {
    if (_completer?.isCompleted ?? true) return;
    _completer!.completeError(PaymentException(message));
  }

  void _dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}

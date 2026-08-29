import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/analytics_events.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/address.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/payment_service.dart';
import 'address_controller.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

/// Drives the checkout flow: address -> delivery -> payment -> order.
/// Payment failure/cancel keeps the cart intact so retry is trivial.
class CheckoutController extends GetxController {
  CheckoutController({
    required this.orderRepository,
    required this.paymentService,
    required this.analytics,
  });

  final OrderRepository orderRepository;
  final PaymentService paymentService;
  final AnalyticsService analytics;

  final Rxn<Address> selectedAddress = Rxn<Address>();
  final Rx<DeliveryOption> deliveryOption = DeliveryOption.standard.obs;
  final Rx<PaymentMethod> paymentMethod = PaymentMethod.razorpay.obs;
  final RxBool isPlacingOrder = false.obs;

  static const double expressCharge = 99.0;

  CartController get cart => Get.find<CartController>();

  double get deliveryExtra =>
      deliveryOption.value == DeliveryOption.express ? expressCharge : 0;

  double get payableTotal => cart.total + deliveryExtra;

  @override
  void onInit() {
    super.onInit();
    analytics.logCheckoutStarted(cart.total, cart.itemCount);
    // Preselect the default address once addresses arrive.
    final addressController = Get.find<AddressController>();
    selectedAddress.value = addressController.defaultAddress;
    ever(addressController.addresses, (_) {
      selectedAddress.value ??= addressController.defaultAddress;
      // If the selected address was deleted, fall back.
      if (selectedAddress.value != null &&
          !addressController.addresses
              .any((a) => a.id == selectedAddress.value!.id)) {
        selectedAddress.value = addressController.defaultAddress;
      }
    });
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
    analytics.logEvent(AnalyticsEvents.addressSelected);
  }

  void selectDelivery(DeliveryOption option) {
    deliveryOption.value = option;
    analytics.logEvent(
        AnalyticsEvents.deliverySelected, {'option': option.name});
  }

  void selectPayment(PaymentMethod method) {
    paymentMethod.value = method;
    analytics.logEvent(
        AnalyticsEvents.paymentMethodSelected, {'method': method.name});
  }

  Future<void> placeOrder() async {
    final uid = Get.find<AuthController>().uid;
    final address = selectedAddress.value;
    if (uid == null || cart.items.isEmpty) return;
    if (address == null) {
      Get.snackbar('app_name'.tr, 'no_addresses_desc'.tr);
      return;
    }

    isPlacingOrder.value = true;
    try {
      String paymentId = '';
      var status = OrderStatus.pending;

      if (paymentMethod.value != PaymentMethod.cod) {
        try {
          final result = await paymentService.pay(
            amountInRupees: payableTotal,
            description: 'order_review'.tr,
            contactPhone: address.phone,
            preferredMethod:
                paymentMethod.value == PaymentMethod.upi ? 'upi' : null,
          );
          paymentId = result.paymentId;
          status = OrderStatus.confirmed;
          analytics.logEvent(AnalyticsEvents.paymentSuccess,
              {AnalyticsEvents.pValue: payableTotal});
        } on PaymentException catch (error) {
          analytics.logEvent(AnalyticsEvents.paymentFailed,
              {AnalyticsEvents.pReason: error.message});
          if (error.message == 'payment_cancelled') {
            Get.snackbar('app_name'.tr, 'payment_cancelled'.tr);
          } else {
            _showPaymentFailedDialog();
          }
          return;
        }
      }

      final now = DateTime.now();
      final deliveryDays = deliveryOption.value == DeliveryOption.express
          ? 2
          : AppConstants.maxDeliveryDays;
      final order = OrderModel(
        id: '',
        items: cart.items.toList(),
        address: address,
        subtotal: cart.subtotal,
        discount: cart.productDiscount,
        couponCode: cart.appliedCoupon.value?.code ?? '',
        couponDiscount: cart.couponDiscount,
        deliveryCharge: cart.deliveryCharge + deliveryExtra,
        tax: cart.tax,
        total: payableTotal,
        paymentMethod: paymentMethod.value,
        paymentId: paymentId,
        status: status,
        deliveryOption: deliveryOption.value,
        createdAt: now.millisecondsSinceEpoch,
        statusTimeline: {status.name: now.millisecondsSinceEpoch},
        estimatedDeliveryAt:
            now.add(Duration(days: deliveryDays)).millisecondsSinceEpoch,
      );

      final orderId = await orderRepository.placeOrder(uid, order);
      await analytics.logPurchase(orderId, payableTotal);
      await cart.clearCart();
      Get.offAllNamed(AppRoutes.orderSuccess, arguments: orderId);
    } catch (error, stackTrace) {
      AppLogger.e('placeOrder failed', error: error, stackTrace: stackTrace);
      Get.snackbar('app_name'.tr, 'error_generic'.tr);
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void _showPaymentFailedDialog() {
    Get.defaultDialog(
      title: 'payment_failed_title'.tr,
      middleText: 'payment_failed_desc'.tr,
      textConfirm: 'retry_payment'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () {
        Get.back();
        placeOrder();
      },
    );
  }
}

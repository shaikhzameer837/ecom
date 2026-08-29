import 'package:get/get.dart';

/// Bottom navigation state for the main shell.
class NavController extends GetxController {
  final RxInt index = 0.obs;

  void changeTab(int newIndex) => index.value = newIndex;
}

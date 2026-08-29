import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/local_storage_service.dart';

class ThemeController extends GetxController {
  ThemeController({required this.storage});

  final LocalStorageService storage;

  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    mode.value = ThemeMode.values.asNameMap()[storage.themeMode ?? ''] ??
        ThemeMode.system;
  }

  Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    Get.changeThemeMode(newMode);
    await storage.setThemeMode(newMode.name);
  }
}

import 'dart:ui';

import 'package:get/get.dart';

import '../../core/localization/app_translations.dart';
import '../../services/local_storage_service.dart';

class LocaleController extends GetxController {
  LocaleController({required this.storage});

  final LocalStorageService storage;

  final RxString currentCode = 'en_US'.obs;

  Locale get initialLocale => _localeFromCode(
      storage.languageCode ?? AppTranslations.fallbackLocale.toString());

  @override
  void onInit() {
    super.onInit();
    currentCode.value = storage.languageCode ?? 'en_US';
  }

  Future<void> changeLanguage(String code) async {
    currentCode.value = code;
    await storage.setLanguageCode(code);
    Get.updateLocale(_localeFromCode(code));
  }

  Locale _localeFromCode(String code) {
    final parts = code.split('_');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}

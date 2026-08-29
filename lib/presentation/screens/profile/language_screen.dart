import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/app_translations.dart';
import '../../controllers/locale_controller.dart';

class LanguageScreen extends GetView<LocaleController> {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('select_language'.tr)),
      body: Obx(() => RadioGroup<String>(
            groupValue: controller.currentCode.value,
            onChanged: (code) {
              if (code != null) controller.changeLanguage(code);
            },
            child: ListView(
              children: [
                for (final entry in AppTranslations.languageNames.entries)
                  RadioListTile<String>(
                    value: entry.key,
                    title: Text(entry.value),
                  ),
              ],
            ),
          )),
    );
  }
}

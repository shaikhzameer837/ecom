import 'dart:ui';

import 'package:get/get.dart';

import 'langs/en_us.dart';
import 'langs/hi_in.dart';
import 'langs/mr_in.dart';

/// GetX translation bundle. Add a new language by adding a map in `langs/`
/// and registering it in [keys] and [supportedLocales].
class AppTranslations extends Translations {
  static const Locale fallbackLocale = Locale('en', 'US');

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
    Locale('mr', 'IN'),
  ];

  /// Display names shown in the language picker (kept in native script).
  static const Map<String, String> languageNames = {
    'en_US': 'English',
    'hi_IN': 'हिन्दी',
    'mr_IN': 'मराठी',
  };

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'hi_IN': hiIN,
        'mr_IN': mrIN,
      };
}

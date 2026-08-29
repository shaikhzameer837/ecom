import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'firebase_options.dart';
import 'presentation/controllers/locale_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/widgets/offline_banner.dart';
import 'services/analytics_service.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'services/remote_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Crashlytics catches all uncaught Flutter and platform errors.
    if (!kDebugMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (error, stackTrace) {
    // App still boots (e.g. before `flutterfire configure` is run).
    AppLogger.e('Firebase init failed', error: error, stackTrace: stackTrace);
  }

  InitialBinding().dependencies();
  unawaited(Get.find<RemoteConfigService>().init());
  unawaited(Get.find<NotificationService>().init());

  runApp(const StyleMartApp());
}

class StyleMartApp extends StatelessWidget {
  const StyleMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.mode.value,
      translations: AppTranslations(),
      locale: localeController.initialLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      navigatorObservers: [Get.find<AnalyticsService>().observer],
      scrollBehavior: const AppScrollBehavior(),
      defaultTransition: Transition.cupertino,
      // Global offline indicator over every screen.
      builder: (context, child) => OfflineBannerHost(child: child),
    );
  }
}

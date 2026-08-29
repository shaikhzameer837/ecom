import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_logo.dart';

/// Decides where the app starts: restores the Firebase session and routes
/// to main or login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Guests can browse, so we always land on the main shell. The session is
    // restored in the background (profile + FCM) when one already exists;
    // auth is only enforced later at the points that need it.
    await Future.wait([
      Get.find<AuthController>().restoreSession(),
      Future.delayed(const Duration(milliseconds: 900)),
    ]);
    Get.offAllNamed(AppRoutes.main);
  }

  /// Splash background brand color.
  static const Color backgroundColor = Color(0xFF7B8288);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 120),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

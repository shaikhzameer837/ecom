import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/primary_button.dart';

/// OTP entry with Android auto-fill (SMS Retriever) and resend countdown.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _auth = Get.find<AuthController>();
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'otp_title'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'otp_subtitle'.trParams({
                      'phone':
                          '${AppConstants.defaultCountryCode} ${_auth.phone}',
                    }),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  PinFieldAutoFill(
                    codeLength: AppConstants.otpLength,
                    autoFocus: true,
                    decoration: BoxLooseDecoration(
                      strokeColorBuilder:
                          FixedColorBuilder(theme.colorScheme.primary),
                      bgColorBuilder: FixedColorBuilder(
                          theme.colorScheme.surfaceContainerHighest),
                      radius: const Radius.circular(AppTheme.radiusS),
                    ),
                    currentCode: _code,
                    onCodeChanged: (code) {
                      _code = code ?? '';
                      if (_code.length == AppConstants.otpLength) {
                        _auth.verifyOtp(_code);
                      }
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  Obx(() => PrimaryButton(
                        label: 'verify'.tr,
                        isLoading: _auth.isVerifying.value,
                        onPressed: () => _auth.verifyOtp(_code),
                      )),
                  const SizedBox(height: AppTheme.spacingM),
                  Obx(() {
                    final seconds = _auth.resendSeconds.value;
                    return TextButton(
                      onPressed: seconds == 0 ? _auth.resendOtp : null,
                      child: Text(
                        seconds == 0
                            ? 'resend_otp'.tr
                            : 'resend_in'.trParams({'seconds': '$seconds'}),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

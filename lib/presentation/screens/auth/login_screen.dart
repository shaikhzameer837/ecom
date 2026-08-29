import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _auth.sendOtp(_phoneController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    _phoneController.text = "9876543210";
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // Guests can back out of the login prompt and keep browsing.
        leading: Get.key.currentState?.canPop() ?? false
            ? IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 88)),
                    const SizedBox(height: AppTheme.spacingL),
                    Text(
                      'login_title'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'login_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.phone,
                      decoration: InputDecoration(
                        labelText: 'phone_number'.tr,
                        counterText: '',
                        prefixIcon: const Icon(Icons.phone_android_rounded),
                        prefixText: '${AppConstants.defaultCountryCode} ',
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    Obx(() => PrimaryButton(
                          label: 'send_otp'.tr,
                          isLoading: _auth.isSendingOtp.value,
                          onPressed: _submit,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

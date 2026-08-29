import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = Get.find<AuthController>();
  late final _name =
      TextEditingController(text: _auth.user.value?.name ?? '');
  late final _email =
      TextEditingController(text: _auth.user.value?.email ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await _auth.updateProfile(
        name: _name.text.trim(),
        email: _email.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('edit_profile'.tr)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            TextFormField(
              controller: _name,
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'display_name'.tr,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'email'.tr,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              enabled: false,
              initialValue: _auth.user.value?.phone ?? '',
              decoration: InputDecoration(
                labelText: 'phone_number'.tr,
                prefixIcon: const Icon(Icons.phone_android_rounded),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            PrimaryButton(
              label: 'save'.tr,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

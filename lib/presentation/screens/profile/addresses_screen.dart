import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/address_controller.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';

class AddressesScreen extends GetView<AddressController> {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('saved_addresses'.tr)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addressForm),
        icon: const Icon(Icons.add_rounded),
        label: Text('add_address'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacingM),
                child: ShimmerBox(height: 100, radius: AppTheme.radiusM),
              ),
            ),
          );
        }
        if (controller.addresses.isEmpty) {
          return EmptyState(
            icon: Icons.location_off_outlined,
            title: 'no_addresses'.tr,
            subtitle: 'no_addresses_desc'.tr,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: controller.addresses.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return Card(
              child: ListTile(
                leading: Icon(switch (address.type.name) {
                  'work' => Icons.work_outline_rounded,
                  'other' => Icons.place_outlined,
                  _ => Icons.home_outlined,
                }),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(address.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: AppTheme.spacingS),
                      Chip(
                        label: Text('default_address'.tr,
                            style: const TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
                subtitle: Text('${address.formatted}\n${address.phone}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') {
                      Get.toNamed(AppRoutes.addressForm, arguments: address);
                    } else {
                      Get.defaultDialog(
                        title: 'delete'.tr,
                        middleText: 'delete_address_confirm'.tr,
                        textConfirm: 'yes'.tr,
                        textCancel: 'no'.tr,
                        onConfirm: () {
                          Get.back();
                          controller.delete(address.id);
                        },
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                    PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

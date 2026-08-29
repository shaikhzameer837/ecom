import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/connectivity_service.dart';

/// Wraps the whole app and slides a banner in whenever connectivity drops.
///
/// This sits in the root `GetMaterialApp.builder`, so it deliberately avoids
/// `Obx` (which is brittle at the root before the widget tree settles) and
/// instead subscribes to the connectivity flag with a GetX worker.
class OfflineBannerHost extends StatefulWidget {
  const OfflineBannerHost({super.key, this.child});

  final Widget? child;

  @override
  State<OfflineBannerHost> createState() => _OfflineBannerHostState();
}

class _OfflineBannerHostState extends State<OfflineBannerHost> {
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  late bool _online = _connectivity.isOnline.value;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever<bool>(_connectivity.isOnline, (online) {
      if (mounted && online != _online) setState(() => _online = online);
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child ?? const SizedBox.shrink()),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _online
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  height: 36,
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: Text(
                        'offline_banner'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

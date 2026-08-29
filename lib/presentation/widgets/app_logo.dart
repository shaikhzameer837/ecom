import 'package:flutter/material.dart';

/// The app logo, used on the splash, login, and profile avatar. Kept in one
/// place so swapping the asset updates every in-app usage.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.rounded = true,
    this.background,
  });

  static const String assetPath = 'assets/images/app_logo.png';

  final double size;
  final bool rounded;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? size * 0.22 : 0.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.checkroom_rounded,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

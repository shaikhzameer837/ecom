import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Standard image loader: memory+disk cache, shimmer-ish placeholder and a
/// graceful broken-image state.
class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Widget image = url.isEmpty
        ? _fallback(scheme)
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: width,
            height: height,
            placeholder: (_, _) =>
                Container(color: scheme.surfaceContainerHighest),
            errorWidget: (_, _, _) => _fallback(scheme),
          );
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _fallback(ColorScheme scheme) => Container(
        width: width,
        height: height,
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined,
            color: scheme.outline, size: 28),
      );
}

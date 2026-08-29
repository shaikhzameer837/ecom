import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// App-wide scroll behavior.
///
/// Deliberately omits the auto-added Material scrollbar. On desktop/web (and
/// whenever a mouse hovers over an emulator) Flutter wraps every scrollable in
/// a `Scrollbar` that hit-tests the underlying viewport; if a sliver's geometry
/// isn't ready that path throws `Null check operator used on a null value`
/// (RenderViewportBase.hitTestChildren). A mobile-first UI doesn't want those
/// scrollbars anyway, so removing them also removes that crash path entirely.
///
/// Mouse/trackpad drag-to-scroll is kept enabled so desktop/web still scroll.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

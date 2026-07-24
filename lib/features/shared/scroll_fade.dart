import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Wraps a scrollable and paints a soft gradient over its bottom edge whenever
/// content continues below the fold.
///
/// Why this exists: every screen here is a full-height scroll view whose last
/// card ends flush against the bottom navigation bar, with nothing to say the
/// content continues. On a tall-but-narrow phone the final card lands under the
/// fold — a Galaxy S24 Ultra is 384x832dp, a quarter less room than the Pixel
/// profile the screens were built against — and with the system font scale
/// raised only that card's heading stays visible. A user reported exactly that
/// as "the Saints of the Day section is cut off". The fade is the missing
/// affordance; it costs one widget and applies to every screen uniformly.
class ScrollFade extends StatefulWidget {
  const ScrollFade({super.key, required this.child, this.height = 36});

  /// The scrollable to wrap. Its own padding is left alone.
  final Widget child;

  /// Height of the gradient band.
  final double height;

  @override
  State<ScrollFade> createState() => _ScrollFadeState();
}

class _ScrollFadeState extends State<ScrollFade> {
  bool _hasMoreBelow = false;

  /// [ScrollMetricsNotification] is dispatched *during* layout, so the flag can
  /// only be applied once the frame settles — a bare setState here would throw
  /// "setState() called during build". The callback is registered from inside a
  /// frame that is already in flight, so it always runs at the end of it.
  bool _sync(ScrollMetrics metrics) {
    final hasMore = metrics.extentAfter > 1;
    if (hasMore != _hasMoreBelow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _hasMoreBelow != hasMore) {
          setState(() => _hasMoreBelow = hasMore);
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The scrollable must fill the slot it was given, not shrink-wrap, which
      // is what a loose-fit Stack would hand it.
      fit: StackFit.expand,
      children: [
        // ScrollMetricsNotification catches content that grows or shrinks
        // without the user scrolling (locale switch, a day with more saints,
        // a font-scale change); ScrollNotification catches the scrolling.
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) => _sync(n.metrics),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) => _sync(n.metrics),
            child: widget.child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _hasMoreBelow ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                height: widget.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // Transparent -> the app background, so the fade reads as
                    // the page dissolving rather than a drawn band.
                    colors: [Color(0x0016121C), AppColors.background],
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

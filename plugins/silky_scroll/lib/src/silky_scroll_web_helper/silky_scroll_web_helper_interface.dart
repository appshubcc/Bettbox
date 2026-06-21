/// CSS values for the `overscroll-behavior-x` property.
enum OverscrollBehaviorX {
  /// Browser default — allows back/forward swipe navigation.
  auto('auto'),

  /// Blocks browser back/forward swipe gestures entirely.
  none('none'),

  /// Prevents scroll chaining but keeps the glow/bounce effect.
  contain('contain');

  const OverscrollBehaviorX(this.cssValue);

  /// The raw CSS string written to `style.overscrollBehaviorX`.
  final String cssValue;
}

/// Interface for platform-specific overscroll behavior management.
///
/// On web, this manipulates the HTML body's `overscroll-behavior-x`.
/// On other platforms, the implementation is a no-op.
abstract interface class SilkyScrollWebManagerInterface {
  /// Whether the current platform is web.
  bool get isWebPlatform;

  /// Manually sets `overscroll-behavior-x` to [value].
  void setOverscrollBehaviorX(OverscrollBehaviorX value);
}

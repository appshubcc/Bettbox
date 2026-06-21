abstract mixin class WindowExtListener {
  void onTaskbarCreated() {}

  void onShouldTerminate() {}

  /// System is about to enter sleep/hibernate.
  void onPowerSuspend() {}

  /// System has resumed from sleep/hibernate.
  void onPowerResume() {}
}

import 'package:riverpod/riverpod.dart';

mixin NotifierValueMixin<T> on AnyNotifier<T, T> {
  set value(T value) {
    state = value;
  }
}

mixin AutoDisposeNotifierMixin<T> on AnyNotifier<T, T> {
  set value(T value) {
    state = value;
  }

  @override
  bool updateShouldNotify(previous, next) {
    final res = !identical(previous, next);
    if (res) {
      onUpdate(next);
    }
    return res;
  }

  void onUpdate(T value) {}
}

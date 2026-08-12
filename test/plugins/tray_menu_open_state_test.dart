import 'package:flutter_test/flutter_test.dart';
import 'package:tray_manager/src/tray_manager.dart';

void main() {
  test('keeps root menu open while a submenu closes', () {
    final state = TrayMenuOpenState();

    state.open();
    state.open();
    state.close();

    expect(state.isOpen, isTrue);
    expect(state.depth, 1);

    state.close();
    expect(state.isOpen, isFalse);
    expect(state.depth, 0);
  });

  test('does not underflow on an unmatched close event', () {
    final state = TrayMenuOpenState();

    state.close();

    expect(state.isOpen, isFalse);
    expect(state.depth, 0);
  });
}

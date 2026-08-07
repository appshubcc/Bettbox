import 'package:flutter_test/flutter_test.dart';
import 'package:tray_manager/tray_manager.dart';

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

  test('reuses open menu ids while keeping the latest callbacks', () {
    var clicked = '';
    final currentItem = MenuItem(
      key: 'proxy-a',
      label: 'old',
      onClick: (_) => clicked = 'old',
    );
    final nextItem = MenuItem(
      key: 'proxy-a',
      label: 'new',
      onClick: (_) => clicked = 'new',
    );

    final reused = reuseOpenMenuItemIds(
      Menu(items: [currentItem]),
      Menu(items: [nextItem]),
    );
    final nativeId = currentItem.id;
    Menu(items: [nextItem]).getMenuItemById(nativeId)?.onClick?.call(nextItem);

    expect(reused, isTrue);
    expect(nextItem.id, nativeId);
    expect(clicked, 'new');
  });

  test('rejects an incompatible open menu structure', () {
    final current = Menu(items: [MenuItem(label: 'item')]);
    final next = Menu(
      items: [
        MenuItem(label: 'item'),
        MenuItem.separator(),
      ],
    );

    expect(reuseOpenMenuItemIds(current, next), isFalse);
  });
}

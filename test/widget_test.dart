import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bett_box/application.dart';

void main() {
  test('Application entry can be constructed', () {
    expect(const Application(), isA<StatefulWidget>());
  });
}

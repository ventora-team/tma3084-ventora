// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tma3084_ventora/main.dart';

void main() {
  testWidgets('App shows the placeholder home', (tester) async {
    await tester.pumpWidget(const VentoraApp());
    expect(find.text('Mawar Cake House'), findsOneWidget);
  });
}
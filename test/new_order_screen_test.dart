import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawar_cake_house/features/orders/presentation/new_order_screen.dart';

Future<void> pumpOrder(WidgetTester t) async {
  t.view.physicalSize = const Size(800, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(const MaterialApp(home: NewOrderScreen()));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Confirm is disabled until the form is complete', (t) async {
    await pumpOrder(t);
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirm order'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('deposit and balance show 30% and 70% of the total', (t) async {
    await pumpOrder(t);
    await t.enterText(find.widgetWithText(TextField, 'Total (RM)'), '100');
    await t.pump();
    expect(find.text('RM 30.00'), findsOneWidget);
    expect(find.text('RM 70.00'), findsOneWidget);
  });

  testWidgets('choosing Other asks for a description', (t) async {
    await pumpOrder(t);
    expect(find.text('Describe the other allergy'), findsNothing);
    await t.tap(find.widgetWithText(FilterChip, 'Other'));
    await t.pump();
    expect(find.text('Describe the other allergy'), findsOneWidget);
  });

  testWidgets('None clears the other allergy choices', (t) async {
    await pumpOrder(t);
    await t.tap(find.widgetWithText(FilterChip, 'Nuts'));
    await t.pump();
    await t.tap(find.widgetWithText(FilterChip, 'None'));
    await t.pump();
    final nuts = t.widget<FilterChip>(find.widgetWithText(FilterChip, 'Nuts'));
    expect(nuts.selected, isFalse);
  });
}

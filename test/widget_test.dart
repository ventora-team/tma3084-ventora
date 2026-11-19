import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawar_cake_house/ai.dart';
import 'package:mawar_cake_house/complaints.dart';
import 'package:mawar_cake_house/pages.dart';

Widget app(DraftReply draft, ComplaintBox box) => MaterialApp(
  home: HomePage(draft: draft, complaints: box),
);

Future<String> fakeAi(String q) async => 'Yes, we have pandan cake today!';

// A tall test screen, so the whole Reply list is built (ListView builds lazily).
Future<void> start(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(800, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(w);
}

// Scrolls to a button first: the test screen is small and the list is long.
Future<void> tapText(WidgetTester t, String text) async {
  await t.ensureVisible(find.text(text).last);
  await t.pumpAndSettle();
  await t.tap(find.text(text).last);
}

Future<void> paste(WidgetTester t, String text) async {
  await t.enterText(find.byType(TextField).first, text);
  await t.pump();
}

void main() {
  test('complaint words are caught in English and Malay', () {
    expect(looksLikeComplaint('My cake was spoiled, I want a refund'), isTrue);
    expect(looksLikeComplaint('Kek saya rosak'), isTrue);
    expect(looksLikeComplaint('Do you have pandan cake on Saturday?'), isFalse);
    expect(looksLikeComplaint('Can I collect it later?'), isFalse);
  });

  test('daily limit has its own message', () {
    expect(const AiUnavailable('daily_limit').message, contains('100'));
    expect(const AiUnavailable('network').message, contains('template'));
  });

  testWidgets('question gets an AI draft that staff can edit', (t) async {
    String? copied;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await start(t, app(fakeAi, ComplaintBox()));
    await paste(t, 'Do you have pandan cake?');
    await t.tap(find.text('Draft reply'));
    await t.pumpAndSettle();
    expect(find.text('Yes, we have pandan cake today!'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'Yes, pandan is ready!');
    await tapText(t, 'Approve and copy');
    await t.pump();
    expect(copied, 'Yes, pandan is ready!');
    expect(find.text('Copied. Paste it to the customer.'), findsOneWidget);
  });

  testWidgets('AI down shows templates, tapping one fills the draft', (
    t,
  ) async {
    await start(
      t,
      app((_) async => throw const AiUnavailable('network'), ComplaintBox()),
    );
    await paste(t, 'Do you have pandan cake?');
    await t.tap(find.text('Draft reply'));
    await t.pumpAndSettle();
    expect(find.text('AI is unavailable. Use a template reply.'), findsOne);
    await tapText(t, templateReplies.first);
    await t.pump();
    expect(find.text('Approve and copy'), findsOneWidget);
  });

  testWidgets('complaint skips the AI and goes to the Complaints page', (
    t,
  ) async {
    var aiCalls = 0;
    final box = ComplaintBox();
    await start(
      t,
      app((q) {
        aiCalls++;
        return fakeAi(q);
      }, box),
    );
    await paste(t, 'The cake came late and I am disappointed');
    await t.tap(find.text('Draft reply'));
    await t.pumpAndSettle();
    expect(aiCalls, 0);
    expect(box.newCount, 1);

    await t.tap(find.text('Complaints').last);
    await t.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Flagged by app'), findsOneWidget);
    await t.tap(find.text('Mark handled'));
    await t.pump();
    expect(find.text('Handled'), findsOneWidget);
    expect(box.newCount, 0);
  });

  testWidgets('staff can flag by hand and release it back to reply', (t) async {
    var aiCalls = 0;
    final box = ComplaintBox();
    await start(
      t,
      app((q) {
        aiCalls++;
        return fakeAi(q);
      }, box),
    );
    await paste(t, 'Is the cake late today? I ordered for 5pm');
    await t.tap(find.text('Mark as complaint'));
    await t.pumpAndSettle();
    expect(box.items.single.byHand, isTrue);

    await t.tap(find.text('Complaints').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Release to reply flow'));
    await t.pumpAndSettle();
    expect(box.items, isEmpty);
    expect(find.text('Is the cake late today? I ordered for 5pm'), findsOne);

    // Released messages are not flagged again, even with "late" in them.
    await t.tap(find.text('Draft reply'));
    await t.pumpAndSettle();
    expect(aiCalls, 1);
  });

  testWidgets('login checks for empty fields and shows sign-in errors', (
    t,
  ) async {
    String? used;
    await t.pumpWidget(
      MaterialApp(
        home: LoginPage(
          signIn: (u, p) async {
            used = u;
            if (p != 'right') throw Exception('bad');
          },
        ),
      ),
    );
    await t.tap(find.text('Sign in'));
    await t.pump();
    expect(find.text('Enter your username and password.'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(0), 'siti');
    await t.enterText(find.byType(TextField).at(1), 'wrong');
    await t.tap(find.text('Sign in'));
    await t.pumpAndSettle();
    expect(used, 'siti');
    expect(find.text('Wrong username or password.'), findsOneWidget);
  });
}

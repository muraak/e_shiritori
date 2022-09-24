// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:e_shiritori/main.dart';
import 'dart:developer';

import 'package:e_shiritori/gameLogic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  test('test nameToId', (() {
    CoreLogic core = CoreLogic();
    core.newGame();
    assert(core.nameToId('てすと') == '001_てすと');
  }));

  test('test idToName', (() {
    CoreLogic core = CoreLogic();
    core.newGame();
    assert(core.idToName('001_てすと') == 'てすと');
  }));

  test('test isHiraganaOrKatakana', (() {
    assert(isHiraganaOrKatakana('てすと') == true);
    assert(isHiraganaOrKatakana('てーすと') == true);
    assert(isHiraganaOrKatakana('テスト') == true);
    assert(isHiraganaOrKatakana('テースト') == true);
    assert(isHiraganaOrKatakana('test') == false);
    assert(isHiraganaOrKatakana('てst') == false);
    assert(isHiraganaOrKatakana('tえst') == false);
    assert(isHiraganaOrKatakana('tesと') == false);
    assert(isHiraganaOrKatakana('テスト！') == false);
    assert(isHiraganaOrKatakana('テスト-') == false);
  }));
}

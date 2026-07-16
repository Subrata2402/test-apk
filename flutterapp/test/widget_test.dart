import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApkApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();
  });
}

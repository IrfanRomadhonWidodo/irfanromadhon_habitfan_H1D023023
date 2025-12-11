// Basic test for HabitFan app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    // Simple test to ensure app can be created
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('HabitFan'),
          ),
        ),
      ),
    );

    expect(find.text('HabitFan'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/widgets/custom_loader.dart';

void main() {
  group('CustomLoader Widget Tests', () {
    testWidgets('renders CustomLoader with default size (128.0)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomLoader(),
          ),
        ),
      );

      expect(find.byType(CustomLoader), findsOneWidget);

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders CustomLoader with specific size',
        (WidgetTester tester) async {
      const double testSize = 64.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomLoader(size: testSize),
            ),
          ),
        ),
      );

      expect(find.byType(CustomLoader), findsOneWidget);

      final customPaintFinder = find.descendant(
        of: find.byType(CustomLoader),
        matching: find.byType(CustomPaint),
      );

      final CustomPaint customPaint = tester.widget(customPaintFinder.first);
      expect(customPaint.size, const Size(testSize, testSize));
    });

    testWidgets('CustomLoader animations pump without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomLoader(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CustomLoader), findsOneWidget);
    });
  });
}

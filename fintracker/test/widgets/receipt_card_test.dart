import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/widgets/receipt_card.dart';
import 'package:fintracker/data/models/receipt_model.dart';

void main() {
  Widget createWidgetUnderTest(ReceiptModel receipt, VoidCallback onTap) {
    return MaterialApp(
      home: Scaffold(
        body: ReceiptCard(
          receipt: receipt,
          onTap: onTap,
        ),
      ),
    );
  }

  group('ReceiptCard Widget Tests', () {
    testWidgets('renders receipt details and correct category icon',
        (WidgetTester tester) async {
      final receipt = ReceiptModel(
        id: 1,
        storeName: 'Biedronka',
        categoryName: 'Artykuły spożywcze',
        totalAmount: 150.50,
        currencyCode: 'PLN',
        dateShopping: DateTime.now(),
        storeLogo: null,
      );

      await tester.pumpWidget(createWidgetUnderTest(receipt, () {}));

      expect(find.text('Biedronka'), findsOneWidget);
      expect(find.text('Artykuły spożywcze'), findsOneWidget);
      expect(find.textContaining('150.50'), findsOneWidget);
      expect(find.textContaining('PLN'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_basket), findsOneWidget);
    });

    testWidgets('shows default icon when category is unknown',
        (WidgetTester tester) async {
      final receipt = ReceiptModel(
        id: 2,
        storeName: 'Sklep z zabawkami',
        categoryName: 'Zabawki',
        totalAmount: 45.00,
        currencyCode: 'PLN',
        dateShopping: DateTime.now(),
        storeLogo: null,
      );

      await tester.pumpWidget(createWidgetUnderTest(receipt, () {}));

      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;
      final receipt = ReceiptModel(
        id: 3,
        storeName: 'Orlen',
        categoryName: 'Paliwo',
        totalAmount: 200.00,
        currencyCode: 'PLN',
        dateShopping: DateTime.now(),
        storeLogo: null,
      );

      await tester.pumpWidget(createWidgetUnderTest(receipt, () {
        wasTapped = true;
      }));

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(wasTapped, isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/widgets/budget_bar.dart';
import 'package:fintracker/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({required double spent, required double limit}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pl'),
      home: Scaffold(
        body: Center(
          child: BudgetBar(
            spent: spent,
            limit: limit,
            currencyCode: 'PLN',
          ),
        ),
      ),
    );
  }

  group('BudgetBar Widget Tests', () {
    testWidgets('renders properly and shows exact values',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(spent: 500, limit: 1000));
      await tester.pumpAndSettle();

      expect(find.byType(BudgetBar), findsOneWidget);

      expect(find.text('50%'), findsOneWidget);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, 0.5);
    });

    testWidgets('limits percentage value to maximum 1.0 (100%)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(spent: 1500, limit: 1000));
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, 1.0);
    });

    testWidgets(
        'renders properly with 0 limit (prevent division by zero issues)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(spent: 100, limit: 0));
      await tester.pumpAndSettle();

      expect(find.byType(BudgetBar), findsOneWidget);
    });
  });
}

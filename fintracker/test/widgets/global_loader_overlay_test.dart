import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fintracker/ui/widgets/global_loader_overlay.dart';
import 'package:fintracker/ui/view_models/loading_view_model.dart';
import 'package:fintracker/ui/widgets/custom_loader.dart';

void main() {
  Widget createWidgetUnderTest(LoadingViewModel viewModel) {
    return MaterialApp(
      home: ChangeNotifierProvider<LoadingViewModel>.value(
        value: viewModel,
        child: const Scaffold(
          body: GlobalLoaderOverlay(),
        ),
      ),
    );
  }

  group('GlobalLoaderOverlay Widget Tests', () {
    testWidgets(
        'is completely transparent and ignores pointer when not loading',
        (tester) async {
      final loadingViewModel = LoadingViewModel();

      await tester.pumpWidget(createWidgetUnderTest(loadingViewModel));

      final overlayFinder = find.byType(GlobalLoaderOverlay);

      final opacityFinder = find.descendant(
        of: overlayFinder,
        matching: find.byType(AnimatedOpacity),
      );
      final AnimatedOpacity animatedOpacity =
          tester.widget(opacityFinder.first);
      expect(animatedOpacity.opacity, 0.0);

      final ignorePointerFinder = find.descendant(
        of: overlayFinder,
        matching: find.byType(IgnorePointer),
      );
      final IgnorePointer ignorePointer =
          tester.widget(ignorePointerFinder.first);
      expect(ignorePointer.ignoring, true);
    });

    testWidgets('becomes visible and blocks touches when loading',
        (tester) async {
      final loadingViewModel = LoadingViewModel();

      await tester.pumpWidget(createWidgetUnderTest(loadingViewModel));

      loadingViewModel.show();

      await tester.pump(const Duration(milliseconds: 250));

      final overlayFinder = find.byType(GlobalLoaderOverlay);

      final opacityFinder = find.descendant(
        of: overlayFinder,
        matching: find.byType(AnimatedOpacity),
      );
      final AnimatedOpacity animatedOpacity =
          tester.widget(opacityFinder.first);
      expect(animatedOpacity.opacity, 1.0);

      final ignorePointerFinder = find.descendant(
        of: overlayFinder,
        matching: find.byType(IgnorePointer),
      );
      final IgnorePointer ignorePointer =
          tester.widget(ignorePointerFinder.first);
      expect(ignorePointer.ignoring, false);

      expect(
          find.descendant(
              of: overlayFinder, matching: find.byType(CustomLoader)),
          findsOneWidget);
    });
  });
}

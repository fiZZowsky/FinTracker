import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/view_models/loading_view_model.dart';

void main() {
  group('LoadingViewModel Tests', () {
    late LoadingViewModel viewModel;

    setUp(() {
      viewModel = LoadingViewModel();
    });

    test('initial state should be false', () {
      expect(viewModel.isLoading, isFalse);
    });

    test('show() should set isLoading to true', () {
      bool listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.show();

      expect(viewModel.isLoading, isTrue);
      expect(listenerCalled, isTrue);
    });

    test('hide() should set isLoading to false', () {
      viewModel.show();

      bool listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.hide();

      expect(viewModel.isLoading, isFalse);
      expect(listenerCalled, isTrue);
    });

    test('show() multiple times should notify only once', () {
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.show();
      viewModel.show();

      expect(notifyCount, 1);
    });
  });
}

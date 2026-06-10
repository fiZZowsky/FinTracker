import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/view_models/connectivity_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityViewModel Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'check') {
            return ['wifi'];
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('dev.fluttercommunity.plus/connectivity'),
              null);
    });

    test('initial state hasInternet is true', () {
      final viewModel = ConnectivityViewModel();
      expect(viewModel.hasInternet, isTrue);
    });

    test('checkConnection() does not throw errors', () async {
      final viewModel = ConnectivityViewModel();
      await expectLater(viewModel.checkConnection(), completes);
    });
  });
}

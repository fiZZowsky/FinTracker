import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/view_models/locale_view_model.dart';

void main() {
  group('LocaleViewModel Tests', () {
    late LocaleViewModel viewModel;

    setUp(() {
      viewModel = LocaleViewModel();
    });

    test('initial locale should be English (en)', () {
      expect(viewModel.locale, const Locale('en'));
    });

    test('setLocale() should change locale and notify listeners', () {
      bool listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.setLocale(const Locale('pl'));

      expect(viewModel.locale, const Locale('pl'));
      expect(listenerCalled, isTrue);
    });

    test('setLocale() with the same locale should not notify listeners', () {
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      viewModel.setLocale(const Locale('en'));

      expect(notifyCount, 0);
    });
  });
}

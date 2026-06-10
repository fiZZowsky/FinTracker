import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintracker/ui/view_models/theme_view_model.dart';

void main() {
  group('ThemeViewModel Tests', () {
    late ThemeViewModel viewModel;

    setUp(() {
      viewModel = ThemeViewModel();
    });

    test('initial themeMode should be ThemeMode.system', () {
      expect(viewModel.themeMode, ThemeMode.system);
    });

    test('toggleTheme(true) should change themeMode to dark', () {
      bool listenerCalled = false;
      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.toggleTheme(true);

      expect(viewModel.themeMode, ThemeMode.dark);
      expect(listenerCalled, isTrue);
    });

    test('toggleTheme(false) should change themeMode to light', () {
      viewModel.toggleTheme(false);

      expect(viewModel.themeMode, ThemeMode.light);
    });

    test('setThemeMode() should set exactly provided mode', () {
      viewModel.setThemeMode(ThemeMode.light);
      expect(viewModel.themeMode, ThemeMode.light);

      viewModel.setThemeMode(ThemeMode.system);
      expect(viewModel.themeMode, ThemeMode.system);
    });
  });
}

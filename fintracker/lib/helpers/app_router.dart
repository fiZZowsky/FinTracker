import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/view/finanses_page.dart';
import '../ui/view/home_page.dart';
import '../ui/view/scanner_page.dart';
import '../ui/view/settings_page.dart';
import '../ui/widgets/responsive_nav_shell.dart';
import '../ui/view/receipt_edit_page.dart';
import '../data/models/receipt_model.dart';

class AppRouter {
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: GlobalKey<NavigatorState>(),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ResponsiveNavShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/scanner',
            builder: (context, state) => const ScannerPage(),
          ),
          GoRoute(
            path: '/finanses',
            builder: (context, state) => const FinansesPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/receipt-edit',
        builder: (context, state) {
          final receipt = state.extra as ReceiptModel?;

          if (receipt == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/');
            });
            return const Scaffold(
                body: Center(child: Text('Błąd: Brak danych paragonu')));
          }

          return ReceiptEditPage(receipt: receipt);
        },
      ),
    ],
  );
}

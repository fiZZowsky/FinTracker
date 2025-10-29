import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/view/finanses_page.dart';
import '../ui/view/home_page.dart';
import '../ui/view/scanner_page.dart';
import '../ui/view/settings_page.dart';
import '../ui/widgets/responsive_nav_shell.dart';

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
    ],
  );
}

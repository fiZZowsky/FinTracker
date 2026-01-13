import 'package:fintracker/data/models/receipt_model.dart';
import 'package:fintracker/ui/view/finanses_page.dart';
import 'package:fintracker/ui/view/home_page.dart';
import 'package:fintracker/ui/view/receipt_details_page.dart';
import 'package:fintracker/ui/view/receipt_edit_page.dart';
import 'package:fintracker/ui/view/scanner_page.dart';
import 'package:fintracker/ui/view/settings_page.dart';
import 'package:fintracker/ui/widgets/responsive_nav_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/view/login_page.dart';
import '../ui/view_models/auth_view_model.dart';

class AppRouter {
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/',
      navigatorKey: GlobalKey<NavigatorState>(),
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isLoggedIn = authViewModel.isLoggedIn;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        if (isLoggedIn && isLoggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
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
            GoRoute(
              path: '/receipt-edit',
              builder: (context, state) {
                final receipt = state.extra as ReceiptModel?;
                if (receipt == null) {
                  return ReceiptEditPage(
                      receipt: ReceiptModel(
                          id: 0,
                          storeName: '',
                          totalAmount: 0,
                          dateShopping: DateTime.now(),
                          storeLogo: null));
                }
                return ReceiptEditPage(receipt: receipt);
              },
            ),
            GoRoute(
              path: '/receipt-details/:id',
              builder: (context, state) {
                final idString = state.pathParameters['id'];
                final id = int.tryParse(idString ?? '');
                if (id == null)
                  return const Scaffold(body: Center(child: Text('Error ID')));
                return ReceiptDetailsPage(receiptId: id);
              },
            ),
          ],
        ),
      ],
    );
  }
}

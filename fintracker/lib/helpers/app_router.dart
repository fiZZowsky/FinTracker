import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/view/splash_screen.dart';
import '../ui/view/login_page.dart';
import '../ui/view/home_page.dart';
import '../ui/view/finanses_page.dart';
import '../ui/view/scanner_page.dart';
import '../ui/view/settings_page.dart';
import '../ui/view/account_page.dart';
import '../ui/view/manage_categories_page.dart';
import '../ui/view/manage_stores_page.dart';
import '../ui/view/receipt_details_page.dart';
import '../ui/view/receipt_edit_page.dart';
import '../ui/widgets/responsive_nav_shell.dart';
import '../ui/view_models/auth_view_model.dart';
import '../data/models/receipt_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authViewModel,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
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
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/finanses',
              builder: (context, state) => const FinansesPage(),
            ),
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerPage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'account',
                  builder: (context, state) => const AccountPage(),
                ),
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const ManageCategoriesPage(),
                ),
                GoRoute(
                  path: 'stores',
                  builder: (context, state) => const ManageStoresPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/receipt-details/:id',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ReceiptDetailsPage(receiptId: id);
          },
        ),
        GoRoute(
          path: '/receipt-edit',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final receipt = state.extra as ReceiptModel;
            return ReceiptEditPage(receipt: receipt);
          },
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authViewModel.isLoggedIn;
        final isInitialized = authViewModel.isAppInitialized;

        final location = state.uri.toString();
        final isLoggingIn = location == '/login';
        final isSplash = location == '/';

        if (isSplash) {
          if (isInitialized) {
            return isLoggedIn ? '/home' : '/login';
          }
          return null;
        }
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },
    );
  }
}

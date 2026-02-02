import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/loading_view_model.dart';
import '../view_models/navigation_guard_view_model.dart';

class ResponsiveNavShell extends StatelessWidget {
  final Widget child;

  const ResponsiveNavShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return _buildMobileLayout(context, child);
  }

  Widget _buildMobileLayout(BuildContext context, Widget child) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),
        onDestinationSelected: (index) => _onNavTap(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homePage,
          ),
          NavigationDestination(
            icon: const Icon(Icons.qr_code_scanner),
            selectedIcon: const Icon(Icons.qr_code_scanner),
            label: l10n.scannerPage,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.finansesPage,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsPage,
          ),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    if (location == '/scanner') return 1;
    if (location == '/finanses') return 2;
    if (location == '/settings') return 3;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        _navigateTo(context, '/');
        break;
      case 1:
        _navigateTo(context, '/scanner');
        break;
      case 2:
        _navigateTo(context, '/finanses');
        break;
      case 3:
        _navigateTo(context, '/settings');
        break;
    }
  }

  void _navigateTo(BuildContext context, String location) async {
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (currentRoute == location) return;

    final guard = context.read<NavigationGuardViewModel>();
    final bool canGo = await guard.canNavigate(context);

    if (!context.mounted) return;

    if (!canGo) {
      return;
    }

    final loadingVM = context.read<LoadingViewModel>();

    loadingVM.show();
    context.go(location);

    await Future.delayed(const Duration(milliseconds: 300));
    loadingVM.hide();
  }
}

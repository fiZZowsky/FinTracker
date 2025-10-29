import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/theme_view_model.dart';

class ResponsiveNavShell extends StatelessWidget {
  final Widget child;

  const ResponsiveNavShell({required this.child, super.key});

  Widget _buildThemeToggleButton(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        final isDark = themeVM.isDarkMode(context);

        return IconButton(
          icon: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          ),
          onPressed: () {
            themeVM.toggleTheme(!isDark);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _isDesktop(context);
    final bool isWeb = kIsWeb;

    if (isWeb) {
      return _buildWebLayout(context, child);
    } else if (isDesktop) {
      return _buildDesktopLayout(context, child);
    } else {
      return _buildMobileLayout(context, child);
    }
  }

  bool _isDesktop(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.windows;
  }

  // web layout
  Widget _buildWebLayout(BuildContext context, Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTracker'),
        actions: [
          _buildWebNavItem(context, label: 'Home', location: '/'),
          _buildWebNavItem(context, label: 'Finanses', location: '/finanses'),
          const SizedBox(width: 20),
          _buildThemeToggleButton(context),
          const SizedBox(width: 20),
        ],
      ),
      body: child,
    );
  }

  Widget _buildWebNavItem(BuildContext context,
      {required String label, required String location}) {
    return TextButton(
      onPressed: () => context.go(location),
      style: TextButton.styleFrom(
        backgroundColor: _location(context) == location
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : Colors.transparent,
      ),
      child: Text(label),
    );
  }

  // desktop layout
  Widget _buildDesktopLayout(BuildContext context, Widget child) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateDesktopIndex(context),
            onDestinationSelected: (index) => _onDesktopNavTap(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: Text('Finanses'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildThemeToggleButton(context),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  // mobile layout
  Widget _buildMobileLayout(BuildContext context, Widget child) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateMobileIndex(context),
        onDestinationSelected: (index) => _onMobileNavTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finanses',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _location(BuildContext context) =>
      GoRouterState.of(context).uri.toString();

  // mobile logic
  int _calculateMobileIndex(BuildContext context) {
    final location = _location(context);
    if (location == '/') return 0;
    if (location == '/scanner') return 1;
    if (location == '/finanses') return 2;
    if (location == '/settings') return 3;
    return 0;
  }

  void _onMobileNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/scanner');
        break;
      case 2:
        context.go('/finanses');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  // desktop logic
  int _calculateDesktopIndex(BuildContext context) {
    final location = _location(context);
    if (location == '/') return 0;
    if (location == '/finanses') return 1;
    if (location == '/settings') return 2;
    return 0;
  }

  void _onDesktopNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/finanses');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
}

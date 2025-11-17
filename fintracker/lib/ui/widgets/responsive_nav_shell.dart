import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/loading_view_model.dart';
import '../view_models/locale_view_model.dart';
import '../view_models/navigation_guard_view_model.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTracker'),
        actions: [
          _buildWebNavItem(context, label: l10n.homePage, location: '/'),
          _buildWebNavItem(context,
              label: l10n.finansesPage, location: '/finanses'),
          const SizedBox(width: 20),
          _buildLanguageMenuButton(context),
          _buildThemeToggleButton(context),
          const SizedBox(width: 20),
        ],
      ),
      body: child,
    );
  }

  Widget _buildLanguageMenuButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeVM = context.read<LocaleViewModel>();

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (Locale locale) {
        localeVM.setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('pl'),
          child: Text(l10n.languagePolish),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Text(l10n.languageEnglish),
        ),
      ],
    );
  }

  Widget _buildWebNavItem(BuildContext context,
      {required String label, required String location}) {
    return TextButton(
      onPressed: () => _navigateTo(context, location),
      style: TextButton.styleFrom(
        backgroundColor: _location(context) == location
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: Text(label),
    );
  }

  // desktop layout
  Widget _buildDesktopLayout(BuildContext context, Widget child) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateDesktopIndex(context),
            onDestinationSelected: (index) => _onDesktopNavTap(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(l10n.homePage),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: const Icon(Icons.account_balance_wallet),
                label: Text(l10n.finansesPage),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(l10n.settingsPage),
              ),
            ],
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateMobileIndex(context),
        onDestinationSelected: (index) => _onMobileNavTap(context, index),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: l10n.homePage,
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: l10n.scannerPage,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: l10n.finansesPage,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: l10n.settingsPage,
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
        _navigateTo(context, '/');
        break;
      case 1:
        _navigateTo(context, '/finanses');
        break;
      case 2:
        _navigateTo(context, '/settings');
        break;
    }
  }

  void _navigateTo(BuildContext context, String location) async {
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (currentRoute == location) return;
    final guard = context.read<NavigationGuardViewModel>();
    final bool canGo = await guard.canNavigate(context);

    if (!canGo) {
      return;
    }

    final loadingVM = context.read<LoadingViewModel>();
    Future(() async {
      loadingVM.show();
      if (context.mounted) {
        context.go(location);
      }
      await Future.delayed(const Duration(milliseconds: 300));
      loadingVM.hide();
    });
  }
}

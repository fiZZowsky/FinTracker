import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'helpers/app_router.dart';
import 'helpers/notification_service.dart';
import 'helpers/service_locator.dart';
import 'helpers/provider_setup.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view_models/theme_view_model.dart';
import 'ui/view_models/locale_view_model.dart';
import 'ui/view_models/auth_view_model.dart';
import 'ui/view_models/connectivity_view_model.dart';
import 'ui/widgets/global_loader_overlay.dart';
import 'ui/view/no_internet_page.dart';

void main() {
  setupLocator();

  runApp(
    MultiProvider(
      providers: getGlobalProviders(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(authViewModel);
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final localeViewModel = context.watch<LocaleViewModel>();

    return MaterialApp.router(
      title: 'FinTracker',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: getIt<NotificationService>().scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      locale: localeViewModel.locale,
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, routerChild) {
        return Consumer<ConnectivityViewModel>(
          builder: (context, connectivityVM, child) {
            if (routerChild == null) return const SizedBox();

            return Stack(
              children: [
                routerChild,
                const GlobalLoaderOverlay(),
                if (!connectivityVM.hasInternet)
                  MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeViewModel.themeMode,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: localeViewModel.locale,
                    home: const NoInternetScreen(),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

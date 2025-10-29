import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view_models/theme_view_model.dart';
import 'ui/view_models/loading_view_model.dart';
import 'ui/view_models/locale_view_model.dart';
import 'ui/widgets/global_loader_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeViewModel()),
        ChangeNotifierProvider(create: (context) => LoadingViewModel()),
        ChangeNotifierProvider(create: (context) => LocaleViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final localeViewModel = context.watch<LocaleViewModel>();

    return MaterialApp.router(
      title: 'FinTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      locale: localeViewModel.locale,
      routerConfig: AppRouter.router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, router) {
        return Stack(
          children: [
            router!,
            const GlobalLoaderOverlay(),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view_models/theme_view_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp.router(
      title: 'FinTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}

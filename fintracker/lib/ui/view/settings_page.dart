import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/locale_view_model.dart';
import '../../helpers/notification_service.dart';
import '../../helpers/service_locator.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final themeVM = context.watch<ThemeViewModel>();
    final localeVM = context.watch<LocaleViewModel>();

    final isDark = themeVM.isDarkMode(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text(l10n.themeSwitch),
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
            ),
            value: isDark,
            onChanged: (value) {
              themeVM.toggleTheme(value);
            },
          ),
          ListTile(
            title: Text(l10n.themeSwitchSystem),
            leading: const Icon(Icons.settings_brightness),
            trailing: themeVM.themeMode == ThemeMode.system
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              themeVM.setThemeMode(ThemeMode.system);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
            child: Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioListTile<Locale>(
            title: Text(l10n.languagePolish),
            value: const Locale('pl'),
            groupValue: localeVM.locale,
            onChanged: (value) {
              localeVM.setLocale(value!);
              getIt<NotificationService>().showNotification(
                  'languageChangedToPl',
                  type: NotificationType.success);
            },
          ),
          RadioListTile<Locale>(
            title: Text(l10n.languageEnglish),
            value: const Locale('en'),
            groupValue: localeVM.locale,
            onChanged: (value) {
              localeVM.setLocale(value!);
              getIt<NotificationService>().showNotification(
                  'languageChangedToEn',
                  type: NotificationType.success);
            },
          ),
        ],
      ),
    );
  }
}

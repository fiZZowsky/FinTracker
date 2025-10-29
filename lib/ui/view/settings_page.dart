import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/theme_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        final isDark = themeVM.isDarkMode(context);

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SwitchListTile(
              title: const Text('Tryb ciemny'),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              value: isDark,
              onChanged: (value) {
                themeVM.toggleTheme(value);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Użyj ustawień systemowych'),
              leading: const Icon(Icons.settings_brightness),
              trailing: themeVM.themeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                themeVM.setThemeMode(ThemeMode.system);
              },
            ),
          ],
        );
      },
    );
  }
}

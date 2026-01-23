import 'package:fintracker/l10n/app_localizations.dart';
import 'package:fintracker/ui/view_models/finanses_view_model.dart';
import 'package:fintracker/ui/view_models/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/locale_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../../helpers/notification_service.dart';
import '../../helpers/service_locator.dart';
import '../../data/models/ocr_engine_type.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeVM = context.watch<ThemeViewModel>();
    final localeVM = context.watch<LocaleViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isDark = themeVM.isDarkMode(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, l10n.accountManagement),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                authVM.userName?.isNotEmpty == true
                    ? authVM.userName![0].toUpperCase()
                    : 'U',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            title: Text(authVM.userName ?? l10n.user),
            subtitle: Text(authVM.userName ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/account'),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.appearance),
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
          _buildSectionHeader(context, l10n.language),
          RadioListTile<Locale>(
            title: Text(l10n.languagePolish),
            value: const Locale('pl'),
            groupValue: localeVM.locale,
            onChanged: (value) {
              if (value != null) {
                localeVM.setLocale(value);
                getIt<NotificationService>().showNotification(
                    l10n.operationSuccess,
                    type: NotificationType.success);
              }
            },
          ),
          RadioListTile<Locale>(
            title: Text(l10n.languageEnglish),
            value: const Locale('en'),
            groupValue: localeVM.locale,
            onChanged: (value) {
              if (value != null) {
                localeVM.setLocale(value);
                getIt<NotificationService>().showNotification(
                    l10n.operationSuccess,
                    type: NotificationType.success);
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.settingsFinanceSection),
          Consumer<FinansesViewModel>(
            builder: (context, finansesVM, child) {
              return ListTile(
                title: Text(l10n.budgetLimitSetting),
                subtitle: Text(
                    '${finansesVM.monthlyBudgetLimit.toStringAsFixed(0)} PLN'),
                leading: const Icon(Icons.savings_outlined),
                trailing: const Icon(Icons.edit),
                onTap: () => _showBudgetEditDialog(context, finansesVM),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.manageCategories),
          ListTile(
            title: Text(l10n.manageCategories),
            leading: const Icon(Icons.category_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categories'),
          ),
          ListTile(
            title: Text(l10n.manageStores),
            leading: const Icon(Icons.store_mall_directory_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/stores'),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.ocrSettingsTitle),
          Consumer<SettingsViewModel>(
            builder: (context, vm, child) {
              return ListTile(
                title: Text(l10n.ocrSettingsTitle),
                subtitle:
                    Text(_getOcrEngineName(context, vm.selectedOcrEngine)),
                leading: const Icon(Icons.document_scanner_outlined),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _showOcrSelectionDialog(context, vm),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AuthViewModel>().logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getOcrEngineName(BuildContext context, OcrEngineType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case OcrEngineType.tesseractOCR:
        return l10n.ocrEngineTesseract;
      case OcrEngineType.azureAIVision:
        return l10n.ocrEngineAzure;
      case OcrEngineType.googleMlKit:
        return l10n.ocrEngineGoogleMlKit;
      case OcrEngineType.googleGeminiAI:
        return l10n.ocrEngineGoogleGemini;
    }
  }

  void _showOcrSelectionDialog(BuildContext context, SettingsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.ocrSettingsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: OcrEngineType.values.map((engine) {
                return RadioListTile<OcrEngineType>(
                  title: Text(_getOcrEngineName(context, engine)),
                  value: engine,
                  groupValue: vm.selectedOcrEngine,
                  onChanged: (value) {
                    if (value != null) {
                      vm.setOcrEngine(value);
                      Navigator.pop(ctx);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showBudgetEditDialog(BuildContext context, FinansesViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final controller =
        TextEditingController(text: vm.monthlyBudgetLimit.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.setBudgetTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.amountLabel,
            border: const OutlineInputBorder(),
            suffixText: 'PLN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newLimit = double.tryParse(controller.text);
              if (newLimit != null && newLimit > 0) {
                vm.updateBudgetLimit(newLimit);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

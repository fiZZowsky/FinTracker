import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../view_models/auth_view_model.dart';
import '../../helpers/notification_service.dart';
import '../../helpers/service_locator.dart';
import '../widgets/custom_loader.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountManagement),
      ),
      body: authVM.isLoading
          ? const Center(child: CustomLoader())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(context, authVM),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.changePassword),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    l10n.deleteAccount,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthViewModel vm) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            vm.userName?.isNotEmpty == true
                ? vm.userName![0].toUpperCase()
                : 'U',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          vm.userName ?? '',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  decoration: InputDecoration(labelText: l10n.currentPassword),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? l10n.fieldRequired : null,
                ),
                TextFormField(
                  controller: newController,
                  decoration: InputDecoration(labelText: l10n.newPassword),
                  obscureText: true,
                  validator: (v) =>
                      v!.length < 6 ? l10n.passwordTooShort : null,
                ),
                TextFormField(
                  controller: confirmController,
                  decoration:
                      InputDecoration(labelText: l10n.confirmNewPassword),
                  obscureText: true,
                  validator: (v) =>
                      v != newController.text ? l10n.passwordsDoNotMatch : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final authVM = context.read<AuthViewModel>();
                Navigator.pop(ctx);

                final success = await authVM.changePassword(
                  currentController.text,
                  newController.text,
                  confirmController.text,
                );

                if (success) {
                  getIt<NotificationService>().showNotification(
                      l10n.passwordChangedSuccess,
                      type: NotificationType.success);
                } else {
                  getIt<NotificationService>().showNotification(
                      l10n.unknownError,
                      type: NotificationType.error);
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmationTitle),
        content: Text(l10n.deleteAccountConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<AuthViewModel>().deleteAccount();
              if (success) {
              } else {
                getIt<NotificationService>().showNotification(l10n.unknownError,
                    type: NotificationType.error);
              }
            },
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

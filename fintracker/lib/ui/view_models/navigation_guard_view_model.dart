import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NavigationGuardViewModel extends ChangeNotifier {
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  void setEditing(bool isEditing) {
    if (_isEditing == isEditing) return;
    _isEditing = isEditing;
    debugPrint("NavigationGuard: Stan edycji = $_isEditing");
  }

  Future<bool> canNavigate(BuildContext context) async {
    if (!_isEditing) {
      return true;
    }

    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(l10n.confirm),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setEditing(false);
      return true;
    }

    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/manage_categories_view_model.dart';
import '../widgets/custom_loader.dart';
import '../../l10n/app_localizations.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageCategoriesViewModel>().fetchCategories();
    });
  }

  void _showCategoryDialog({int? id, String? currentName}) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing
            ? '${l10n.edit} ${l10n.receiptCategory}'
            : l10n.addCategory),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.receiptCategory,
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final vm = context.read<ManageCategoriesViewModel>();
              bool success;
              if (isEditing) {
                success = await vm.editCategory(id, name);
              } else {
                success = await vm.addCategory(name);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.operationError)),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManageCategoriesViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageCategories),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: vm.isLoading
          ? const Center(child: CustomLoader())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.categories.length,
              itemBuilder: (context, index) {
                final category = vm.categories[index];

                final isDefault = category.isDefault;

                return Card(
                  color: isDefault
                      ? theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5)
                      : theme.cardColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isDefault ? Icons.lock_outline : Icons.person_outline,
                      color:
                          isDefault ? Colors.grey : theme.colorScheme.primary,
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight:
                            isDefault ? FontWeight.normal : FontWeight.bold,
                        color: isDefault ? Colors.grey[700] : null,
                      ),
                    ),
                    subtitle: isDefault
                        ? Text(l10n.defaultCategory,
                            style: TextStyle(fontSize: 10))
                        : null,
                    trailing: isDefault
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showCategoryDialog(
                                  id: category.id,
                                  currentName: category.name,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(l10n.delete),
                                      content: Text(
                                          '${l10n.delete} "${category.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(l10n.delete,
                                              style: const TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await vm.deleteCategory(category.id);
                                  }
                                },
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }
}
